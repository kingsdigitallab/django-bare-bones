# django-bare-bones
Start up configuration for KDL Django based projects.

This project uses the technologies outlined in our [Technology Stack](https://stackshare.io/kings-digital-lab/django) and is configured to use [Vagrant](https://www.vagrantup.com/) for local development and [Fabric](http://www.fabfile.org/) for deployment. The project also includes the choice of [Bulma](http://bulma.io) or [Foundation](http://foundation.zurb.com/).

Pre-configured options include [LDAP Authentication](https://github.com/kingsdigitallab/django-kdl-ldap), [GeoDjango](https://docs.djangoproject.com/en/1.11/ref/contrib/gis/), [ActiveCollab Digger](https://github.com/kingsdigitallab/django-activecollab-digger), [Wagtail](https://wagtail.io) and [Haystack](http://haystacksearch.org)

## Getting started
1. Clone this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Go into the `django-bare-bones` directory
3. Run the bootstrap command and follow the prompts to set up the project: `./bootstrap.sh`
4. The bootstrap script will then:
  * Check your development environment, and install/update tools as necessary
    * Clone a new copy of the repo into PROJECT_KEY-django. It will use the same branch you are on now.
    * Populate settings, URLs and apps selected during the installation
    * Remove all git configurations from the project, so that it can be added to a new repo
    * Add a correct readme file to the project
5. Enter the new project directory `cd ../PROJECT_NAME-django`
6. Edit local settings and configuration files as needed

#### Arguments
Bootstrap.sh accepts the following arguments:

* `--help`: Displays help text
* `--local`: Copies your local working copy of django-bare-bones rather than cloning from git.
* `--no-dep-check`: Disables dependency checking. Use with extreme caution - this will cause the script to fail if a dependency is not installed. Never use for production-ready projects.

## Requirements
To use this script successfully you will need the following on the **host** machine:

* Python >= 3
* Ansible >= 2.3
* Vagrant >= 1.9
* VirtualBox >= 5.0

## Vagrant VM
To provision a new local development virtual machine, run the command `vagrant up`. To SSH into the virtual machine, run `vagrant ssh`.

The provisioning script will create a default superuser login:

username: `vagrant`
password: `vagrant`

If you selected `kdl-ldap` in the bootstrap script, all members of the `kdl-staff` ldap group can login as superuser. All members of the group entered in the bootstrap script will be able to login as staff. Note: LDAP authentication will only work within the college firewall.

The default virtual machine is configured with:
* 1 Core, 2GB RAM
* Ubuntu 16.04 LTS
* Python 3
* ElasticSearch 5/Java 8 (256-2048M Heap)


## Deployment

Detailed instructions for initial deployment are available in the shared drive under `Group Share/Systems/Servers`.

For an initial deployment:
* Run `fab <instance> setup_environment`
* Run `fab <instance> deploy:<branch>` as normal - the script will prompt for further details as required
* Update UWSGI configuration to reference the newly deployed application

For an update deployment:
* Run `fab <instance> deploy:<branch>`

## Known Issues:

* Ctrl-c does not work when a whiptail window is visible. Cancel button replicates this functionality


## Changelog

#### Release 0.5 (Geoffroy Noel)
* Tested with Django 2.1.5 & Wagtail 2.4
* __Replaced pip with pipenv & bower with npm__, please familiarise yourself with those two tools

* Please make sure __you install python packages with pipenv and NOT pip from now on__
* requirements.txt and requirements-dev.txt are no longer used. Pipfiles replace them.
* please ensure that Pipfile and Pipfile-lock are added to the repository
* NEVER edit pipfile-lock directly, this file is generated by pipenv lock / install
* Before deploying to a server check that the pipenv is installed by root (pip install pipenv)

* Replaced bower with npm. __Please use npm i X to install a new js / css library__.
* reason: bower is deprecated and npm is more deterministic when deploying versions to servers
* __libraries are installed into node_modules folder__, which is excluded from repo with .gitignore, node_modules therefore replaces assets/vendors
* package.json and package-lock.json now replace bower.json, they are generated from npm commands
* __make sure those two files are added to your github repo__
* before deploying with fabfile make sure __npm is installed on the VM__

* vue.js is now included by default
* google analytics only loaded when GA_ID is set
* __NOTE that wagtail 2.4 no longer supports front-end search page__
* http://docs.wagtail.io/en/latest/releases/2.0.html#deprecated-search-view

#### Release 0.4.1
* Django 2 support

#### Release 0.4
* Complete rewrite with improved UI

#### Release 0.3.2
* Added fix for SSH hanging upon login with virtualbox provider.

#### Release 0.3.1
* Fixed django version to 1.10. 1.11 has a breaking change for wagtail. We should try to keep these app
versions fixed where possible.

#### Release 0.3
* Fixed installation of setuptools which is failing due to (not) missing dependencies. Hopefully this is a temporary bug with setuptools. Fixed dependencies are in requirements-setuptools-fix.txt.
