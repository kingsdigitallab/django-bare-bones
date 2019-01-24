#!/usr/bin/env python
import os.path
import sys
from functools import wraps

from django.conf import settings as django_settings
from django.core.management.utils import get_random_secret_key
from fabric.api import (cd, env, prefix, prompt, put, quiet, require, run,
                        settings, sudo, task)
from fabric.colors import green, yellow
from fabric.contrib import django
from fabric.utils import abort

# put project directory in path
project_root = os.path.abspath(os.path.dirname(__file__))
sys.path.append(project_root)

# -------------------------------
''' SETTINGS VARIABLES: read from your Django settings files.
All optional.

Please keep this file generic, all hard-coded values should go to settings.

FABRIC_SERVER_NAME: short name of the server to deploy to (e.g. ncse2)
    default: PROJECT_NAME
FABRIC_GATEWAY: e.g. myusername@my.ssh.proxy.com
    default: don't use a gateway, acces remote server directly
FABRIC_USER: name of user used to execute command on remote server
    default: name of user who started fab

'''


# The name of the Django app for this project
# Folder that contains settings/local.py
def find_project_name():
    ret = None
    for name in os.listdir(project_root):
        if os.path.exists(os.path.join(
            project_root, name, 'settings', 'local.py')):
            if ret is not None:
                raise Exception('Ambiguous project name')
            ret = name
    if not ret:
        raise Exception('Could not find your Django project folder')
    return ret


PROJECT_NAME = find_project_name()
django.project(PROJECT_NAME)

SERVER_NAME = getattr(django_settings, 'FABRIC_SERVER_NAME', PROJECT_NAME)

# Git repository pointer
REPOSITORY = 'https://github.com/kingsdigitallab/{}-django.git'.format(
    PROJECT_NAME)

env.gateway = 'ssh.kdl.kcl.ac.uk'
# Host names used as deployment targets
env.hosts = ['{}.kdl.kcl.ac.uk'.format(SERVER_NAME)]
# Absolute filesystem path to project 'webroot'
env.root_path = '/vol/{}/webroot/'.format(SERVER_NAME)
# Absolute filesystem path to project Django root
env.django_root_path = '/vol/{}/webroot/'.format(SERVER_NAME)
# Absolute filesystem path to Python virtualenv for this project
# TODO: create symlink to .venv within project folder
# env.envs_path = os.path.join(env.root_path, 'envs')
# -------------------------------

# Set FABRIC_GATEWAY = 'username@proxy.x' in local.py
# if you are behind a proxy.
FABRIC_GATEWAY = getattr(django_settings, 'FABRIC_GATEWAY', None)
if FABRIC_GATEWAY:
    env.forward_agent = True
    env.gateway = FABRIC_GATEWAY

# Name of linux user who deploys on the remote server
env.user = django_settings.FABRIC_USER


def server(func):
    """Wraps functions that set environment variables for servers"""

    @wraps(func)
    def decorated(*args, **kwargs):
        try:
            env.servers.append(func)
        except AttributeError:
            env.servers = [func]

        return func(*args, **kwargs)

    return decorated


@task
@server
def dev():
    env.srvr = 'dev'
    set_srvr_vars()


@task
@server
def stg():
    env.srvr = 'stg'
    set_srvr_vars()


@task
@server
def liv():
    env.srvr = 'liv'
    set_srvr_vars()


def set_srvr_vars():
    # Absolute filesystem path to the django project root
    # Contains manage.py
    env.path = os.path.join(env.root_path, env.srvr, 'django',
                            '{}-django'.format(PROJECT_NAME))
    env.within_virtualenv = 'source {}'.format(
        os.path.join(get_virtual_env_path(), 'bin', 'activate'))


@task
def setup_environment(version=None):
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)
    clone_repo()
    create_virtualenv()
    update(version)
    install_requirements()


@task
def create_virtualenv():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)
    env_vpath = get_virtual_env_path()
    with quiet():
        if run('ls {}'.format(env_vpath)).succeeded:
            print(
                green('virtual environment at [{}] exists'.format(env_vpath)))
            return

    # All we need is a .venv dir in the project folder;
    # 'pipenv install' will set it up first time
    print(yellow('setting up virtual environment in [{}]'.format(env_vpath)))
    run('mkdir {}'.format(env_vpath))


def get_virtual_env_path():
    '''Returns the absolute path to the python virtualenv for the server
    (dev, stg, live) we are working on.
    E.g. /vol/tvof/webroot/.../.venv
    '''
    return os.path.join(env.path, '.venv')


@task
def clone_repo():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)
    with quiet():
        if run('ls {}'.format(os.path.join(env.path, '.git'))).succeeded:
            print(green(('repository at'
                         ' [{}] exists').format(env.path)))
            return

    print(yellow('cloneing repository to [{}]'.format(env.path)))
    run('git clone {} {}'.format(REPOSITORY, env.path))


@task
def install_requirements():

    require('srvr', 'path', provided_by=env.servers)

    create_virtualenv()

    fix_permissions('virtualenv')

    with cd(env.path):
        check_pipenv()
        run('pipenv sync')
        run('pipenv clean')


@task
def check_pipenv():
    with quiet():
        if run('which pipenv').failed:
            abort('pipenv is missing, '
                  'please install it as root with "pip install pipenv"')


@task
def reinstall_requirement(which):
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path):
        check_pipenv()
        run('pipenv uninstall --all --clear')

    install_requirements()


@task
def deploy(version=None):
    update(version)
    install_requirements()
    upload_local_settings()
    own_django_log()
    fix_permissions()
    migrate()
    collect_static()
    # update_index()
    # clear_cache()
    touch_wsgi()
    check_deploy()


@task
def update(version=None):
    require('srvr', 'path', provided_by=env.servers)

    if version:
        # try specified version first
        to_version = version
    elif not version and env.srvr in ['local', 'vagrant', 'dev']:
        # if local, vagrant or dev deploy to develop branch
        to_version = 'develop'
    else:
        # else deploy to master branch
        to_version = 'master'

    with cd(env.path):
        run('git pull')
        run('git checkout {}'.format(to_version))


@task
def upload_local_settings():
    require('srvr', 'path', provided_by=env.servers)

    with cd(env.path):
        with settings(warn_only=True):
            if run('ls {}/settings/local.py'.format(PROJECT_NAME)).failed:
                db_host = prompt('Database host: ')
                db_pwd = prompt('Database password: ')

                put('{}/settings/local_{}.py'.format(PROJECT_NAME, env.srvr),
                    '{}/settings/local.py'.format(PROJECT_NAME), mode='0664')

                run('echo >> {}/settings/local.py'.format(PROJECT_NAME))
                run('echo '
                    '"DATABASES[\'default\'][\'PASSWORD\'] = \'{}\'" >>'
                    '{}/settings/local.py'.format(db_pwd, PROJECT_NAME))
                run('echo '
                    '"DATABASES[\'default\'][\'HOST\'] = \'{}\'" >>'
                    '{}/settings/local.py'.format(db_host, PROJECT_NAME))
                run('echo '
                    '"SECRET_KEY = \'{}\'" >>'
                    '{}/settings/local.py'.format(
                        get_random_secret_key(), PROJECT_NAME))


@task
def own_django_log():
    """ make sure logs/django.log is owned by www-data"""
    require('srvr', 'path', provided_by=env.servers)

    with quiet():
        log_path = os.path.join(env.path, 'logs', 'django.log')
        if run('ls {}'.format(log_path)).succeeded:
            sudo('chown www-data:www-data {}'.format(log_path))
            sudo('chmod g+rw {}'.format(log_path))


@task
def fix_permissions(category='static'):
    '''
    Reset the permissions on various paths.
    category: determines which set of paths to work on:
        'static' (default): django static path + general project path
        'virtualenv': fix the virtualenv permissions
    '''
    require('srvr', 'path', provided_by=env.servers)

    processed = False

    dir_names = ['static', 'logs', 'django_cache']

    with cd(env.path), quiet():
        if category == 'static':
            processed = True

            for dir_name in dir_names:
                if run('ls "{}"'.format(dir_name)).succeeded:
                    sudo('setfacl -R -m g:www-data:rwx "{}"'.format(dir_name))
                    sudo('setfacl -R -d -m g:www-data:rwx "{}"'.
                         format(dir_name))
                    sudo('setfacl -R -m g:kdl-staff:rwx "{}"'.format(dir_name))
                    sudo('setfacl -R -d -m g:kdl-staff:rwx "{}"'.
                         format(dir_name))
                    sudo('chgrp -Rf kdl-staff "{}"'.format(dir_name))
                    sudo('chmod -Rf g+w "{}"'.format(dir_name))

        if category == 'virtualenv':
            path = get_virtual_env_path()
            sudo('chgrp -Rf kdl-staff {}'.format(path))
            sudo('chmod -Rf g+rw {}'.format(path))
            processed = True

    if not processed:
        raise Exception(
            'fix_permission(category="{}"): unrecognised category name.'.
            format(category)
        )


@task
def migrate(app=None):
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path), prefix(env.within_virtualenv):
        run('./manage.py migrate {}'.format(app if app else ''))


@task
def collect_static(process=False):
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path):
        run('npm i')

    if env.srvr in ['local', 'vagrant']:
        print(yellow('Do not run collect_static on local servers'))
        return

    with cd(env.path), prefix(env.within_virtualenv):
        run('./manage.py collectstatic {process} --noinput'.format(
            process=('--no-post-process' if not process else '')))


@task
def update_index():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path), prefix(env.within_virtualenv):
        run('./manage.py update_index')


@task
def clear_cache():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path), prefix(env.within_virtualenv):
        run('./manage.py clear_cache')


@task
def touch_wsgi():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(os.path.join(env.path, PROJECT_NAME)), \
            prefix(env.within_virtualenv):
        run('touch wsgi.py')


@task
def check_deploy():
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    if env.srvr in ['stg', 'liv']:
        with cd(env.path), prefix(env.within_virtualenv):
            run('./manage.py check --deploy')
