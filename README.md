# django-bare-bones
Start up configuration for KDL Django based projects.

This project is configured to use [Vagrant](https://www.vagrantup.com/) for local development and [Dabric](http://www.fabfile.org/) for deployment. The project also includes some default templates based on [Foundation](http://foundation.zurb.com/).

Pre-configured options include [LDAP Authentication](https://github.com/kingsdigitallab/django-kdl-ldap), [ActiveCollab Digger](https://github.com/kingsdigitallab/django-activecollab-digger), [Wagtail](https://wagtail.io) and [Haystack](http://haystacksearch.org)

## Getting started
1. Clone this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Go into the `django-bare-bones` directory
3. Run the bootstrap command and follow the prompts to set up the project: `./bootstrap.sh`
4. The bootstrap script also:
    * disconnects from this repository by removing the `.git` directory; the new project can then added to its own repository
    * renames the project directory to `PROJECT_NAME-django`.
5. Enter the new project directory `cd ../PROJECT_NAME-django`
6. Edit settings and configuration files.

Shortcut: Use the following command to automatically clone and run the script:

`git clone git@github.com:kingsdigitallab/django-bare-bones.git && cd django-bare-bones && ./bootstrap.sh`

## Requirements
To use this script successfully you will need the following on the **host** machine:
* Ansible >= 2.3.1.0
* Vagrant >= 1.9.1
* VirtualBox >= 5.0

## Vagrant VM
To provision a new local development virtual machine, run the command `vagrant up`. 

The default virtual machine is configured with:
* 1 Core, 2GB RAM
* Ubuntu 16.04 LTS
* Python 3
* ElasticSearch 5/Java 8 (256-2048M Heap)

## Changelog

#### Release 0.3.2
* Added fix for SSH hanging upon login with virtualbox provider.

#### Release 0.3.1
* Fixed django version to 1.10. 1.11 has a breaking change for wagtail. We should try to keep these app
versions fixed where possible.

#### Release 0.3
* Fixed installation of setuptools which is failing due to (not) missing dependencies. Hopefully this is a temporary bug with setuptools. Fixed dependencies are in requirements-setuptools-fix.txt.

#### Release 0.2.9
* Grouped all control variables into one block near the beginning of the script to simplify the project-based customisation
* Shorten the output of the pip install process
* Improved the fix_permissions task to also reset permission on the virtual env
* Added more file/folder exclusions to flake8
* Django Errors are sent by email to ADMINS by default
* local.py:FABRIC_GATEWAY = 'username@proxy.x' to let fabric work behind proxy

#### Release 0.2.8
* Added more file exclusions to flake8 (especially django templates)

#### Release 0.2.7
* Vagrant
    * Removed node tasks from ansible playbook
    * Updated the flake8 tasks to be compatible with the latest versions of flake8
* Fabric, added a task to fix the permissions of the project directory on the server
* Modified urls to be compatible with Django 1.10
* Other minor fixes

#### Release 0.2.6
* Issue fixing

#### Release 0.2.5
* flake8 pre-commit hook added to git during provisioning
    * **Note**:flake8 needs to be installed in the OS where the commits are being done

#### Release 0.2.4
* Removed Modernizr
* Cleaned up Foundation dependencies
* Added comments to set up scss for Foundation and FontAwesome

#### Release 0.2.3
* Added more default Python requirements

#### Release 0.2.2
* Fixed ansible deprecation issues
* Fixed issues setting postgres authentication

#### Release 0.2.1
* Added missing reference to requirejs script from the base template
* Removed references to wagtail/wagtailbase

#### Release 0.2
* Updated requirejs configuration to work with babeljs
* Updated the fabric script to work with git
* Added CI configuration files for tox and travis
