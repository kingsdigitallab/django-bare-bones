#!/usr/bin/env python
import os.path
import sys
from functools import wraps

from django.conf import settings as django_settings
from django.core.management.utils import get_random_secret_key
from fabric.api import (cd, env, prompt, put, quiet, require, run,
                        settings, sudo, task)
from fabric.colors import green, yellow
from fabric.contrib import django
from fabric.utils import abort
from fabric.contrib.files import exists

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
FABRIC_DEV_PACKAGES: dev python packages from github to install outside venv
    default: empty
    example:
    {
        'git': 'https://github.com/kingsdigitallab/django-kdl-wagtail.git',
        'folder_git': 'django-kdl-wagtail',
        'folder_package': 'kdl_wagtail',
        'branch': 'develop',
        # which fab servers should use this?
        'servers': ['lcl', 'dev'],
    }
]
    Note: to let pipenv manage your package instead, you'll need to:
        - delete the two package folders in your project dir
        - pipenv uninstall PACKAGE && pipenv install PACKAGE

'''


def find_project_name():
    '''
    The name of the Django app for this project
    Folder that contains settings/local.py
    '''
    ret = None
    for name in os.listdir(project_root):
        path = os.path.join(project_root, name, 'settings', 'local.py')
        if os.path.exists(path):
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
    env.gateway = FABRIC_GATEWAY

# Name of linux user who deploys on the remote server
env.user = django_settings.FABRIC_USER
env.forward_agent = True

env.dev_packages = getattr(django_settings, 'FABRIC_DEV_PACKAGES', [])


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
def lcl():
    env.srvr = 'lcl'
    env.user = 'vagrant'
    env.gateway = None
    env.hosts = ['127.0.0.1']
    set_srvr_vars()


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
    if is_vagrant():
        env.path = '/vagrant'
    else:
        env.path = os.path.join(
            env.root_path, env.srvr, 'django', '{}-django'.format(PROJECT_NAME)
        )

    env.within_virtualenv = 'pipenv run '


@task
def setup_environment(version=None):
    require('srvr', provided_by=env.servers)

    clone_repo()
    update(version)
    install_requirements()


@task
def clone_repo():
    require('srvr', 'path', provided_by=env.servers)

    git_path = os.path.join(env.path, '.git')
    if remote_path_exists(git_path):
        print(green(('repository at [{}] exists').format(env.path)))
        return

    print(yellow('cloning repository to [{}]'.format(env.path)))
    run('git clone {} {}'.format(REPOSITORY, env.path))


@task
def install_requirements():
    require('srvr', 'path', provided_by=env.servers)

    create_virtualenv()
    fix_permissions('virtualenv')

    dev_flag = ''
    if is_vagrant():
        dev_flag = '-d'

    with cd(env.path):
        check_pipenv()
        run('pipenv sync {}'.format(dev_flag))
        run('pipenv clean')

        run('npm ci')


@task
def create_virtualenv():
    '''
    Create the pipenv venv if it is not there yet.
    If within vagrant we create it in vagrant home folder.
    If remote server, we create it within the project folder.
    '''
    require('srvr', 'path', provided_by=env.servers)

    check_pipenv()
    with cd(env.path):
        venv_path = get_virtual_env_path()
        if venv_path is not None:
            print(green('virtual environment already exists'))
        else:
            print(yellow('setting up virtual environment'))

            dev_flag = ''
            if is_vagrant():
                dev_flag = '-d'

            # with pipenv we don't really need to set up the venv
            # it will be done automatically when we call pipenv install / sync
            if not is_vagrant() and not exists('.venv'):
                run('mkdir .venv')
            if not exists('Pipfile'):
                run('pipenv install --three {}'.format(dev_flag))
            if not exists('Pipfile.lock'):
                run('pipenv lock {}'.format(dev_flag))


@task
def reinstall_requirement():
    require('srvr', 'path', provided_by=env.servers)

    with cd(env.path):
        check_pipenv()
        run('pipenv uninstall --all --clear')

    install_requirements()


@task
def deploy(version=None):
    update(version)
    install_requirements()
    upload_local_settings()
    migrate()
    collect_static()
    # update_index()
    # clear_cache()
    touch_wsgi()
    check_deploy()
    fix_permissions()
    own_django_log()


@task
def update(version=None):
    require('srvr', 'path', provided_by=env.servers)

    if version:
        # try specified version first
        to_version = version
    elif env.srvr in ['local', 'vagrant', 'dev', 'lcl']:
        # if local, vagrant or dev deploy to develop branch
        to_version = 'develop'
    else:
        # else deploy to master branch
        to_version = 'master'

    with cd(env.path):
        run('git pull')
        run('git checkout {}'.format(to_version))

    update_dev_packages()


@task
def update_dev_packages():
    '''pull all the dev packages'''

    for package in env.dev_packages:
        if env.srvr.lower() in package['servers']:
            path_git = os.path.join(env.path, package['folder_git'])
            path_package = os.path.join(env.path, package['folder_package'])

            # clone package
            with cd(env.path):
                if not exists(path_git):
                    run('git clone -b {} --single-branch {}'.format(
                        package['branch'], package['git']
                    ))

            # pull package
            with cd(os.path.join(env.path, package['folder_git'])):
                run('git pull')

            # create symlink
            with cd(env.path):
                if not exists(path_package):
                    run('ln -s {}'.format(os.path.join(
                        path_git, package['folder_package']
                    )))


@task
def upload_local_settings():
    if is_vagrant():
        return

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
    if is_vagrant():
        return

    require('srvr', 'path', provided_by=env.servers)

    with quiet():
        log_path = os.path.join(env.path, 'logs', 'django.log')
        if exists(log_path):
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
    if is_vagrant():
        return

    require('srvr', 'path', provided_by=env.servers)

    processed = False

    with cd(env.path), quiet():
        if category == 'static':
            processed = True

            dir_names = ['static', 'logs', 'django_cache']

            for dir_name in dir_names:
                if exists(dir_name):
                    sudo('setfacl -R -m g:www-data:rwx "{}"'.format(dir_name))
                    sudo('setfacl -R -d -m g:www-data:rwx "{}"'.
                         format(dir_name))
                    sudo('setfacl -R -m g:kdl-staff:rwx "{}"'.format(dir_name))
                    sudo('setfacl -R -d -m g:kdl-staff:rwx "{}"'.
                         format(dir_name))
                    sudo('chgrp -Rf kdl-staff "{}"'.format(dir_name))
                    sudo('chmod -Rf g+w "{}"'.format(dir_name))

        if category == 'virtualenv':
            processed = True

            path = get_virtual_env_path()
            if path is not None:
                sudo('chgrp -Rf kdl-staff {}'.format(path))
                sudo('chmod -Rf g+rw {}'.format(path))

    if not processed:
        raise Exception(
            'fix_permission(category="{}"): unrecognised category name.'.
            format(category)
        )


@task
def touch_wsgi():
    if is_vagrant():
        return

    require('srvr', 'path', provided_by=env.servers)

    with cd(os.path.join(env.path, PROJECT_NAME)):
        run('touch wsgi.py')


# =======================================================================
# Django commands

@task
def migrate(app=None):
    run_django_command('migrate {}'.format(app if app else ''))


@task
def collect_static(process=False):
    if is_vagrant():
        return

    cmd = 'collectstatic {process} --noinput'.format(
        process=('--no-post-process' if not process else '')
    )

    run_django_command(cmd)


@task
def update_index():
    run_django_command('update_index')


@task
def clear_cache():
    run_django_command('clear_cache')


@task
def check_deploy():
    require('srvr', provided_by=env.servers)

    if env.srvr in ['stg', 'liv']:
        run_django_command('check --deploy')

# =======================================================================
# Helper functions


def is_vagrant():
    '''Return True if the task runs within local vagrant env.
    Return False if the task runs within a remote server.
    '''
    return env.srvr in ['local', 'vagrant', 'lcl']


def remote_path_exists(path):
    '''Returns True if remote path exists (folder or file)
    path can be relative or absolute.
    '''
    return exists(path)


def run_django_command(command):
    require('srvr', 'path', 'within_virtualenv', provided_by=env.servers)

    with cd(env.path):
        run('{} python manage.py {}'.format(env.within_virtualenv, command))


def get_virtual_env_path():
    '''Returns the absolute path to the python virtualenv for the server
    (dev, stg, live) we are working on.
    E.g. /vol/tvof/webroot/.../.venv

    return None if no venv is associated to the project folder.
    '''
    require('srvr', 'path')

    with cd(env.path), settings(warn_only=True):
        ret = run('PIPENV_VERBOSITY=-1 pipenv --venv')
        if not ret.succeeded:
            ret = None

    return ret


def check_pipenv():
    with quiet():
        if run('which pipenv').failed:
            abort('pipenv is missing, '
                  'please install it as root with "pip install pipenv"')
