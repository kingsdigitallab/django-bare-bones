# django-bare-bones
Start up configuration for KDL Django based projects.

This project is configured to use [Vagrant](https://www.vagrantup.com/) for local development and [Fabric](http://www.fabfile.org/) for deployment. The project also includes the choice of [Bulma](http://bulma.io) or [Foundation](http://foundation.zurb.com/).

Pre-configured options include [LDAP Authentication](https://github.com/kingsdigitallab/django-kdl-ldap), [ActiveCollab Digger](https://github.com/kingsdigitallab/django-activecollab-digger), [Wagtail](https://wagtail.io) and [Haystack](http://haystacksearch.org)

## Getting started
1. Clone this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Go into the `django-bare-bones` directory
3. Run the bootstrap command and follow the prompts to set up the project: `./bootstrap.sh`
4. The bootstrap script will then:
	* Check your development environment, and install/update tools as necessary
    * Clone a new copy of the repo into PROJECT_KEY-django. It will use the same branch you are on now.
    * Populate settings, URLs and apps selected during the installation
    * Configure bower for the selected frontend framework and compile them into /assets/vendor
    * Remove all git configurations from the project, so that it can be added to a new repo
    * Add a correct readme file to the project
5. Enter the new project directory `cd ../PROJECT_NAME-django`
6. Edit local settings and configuration files as needed

#### Arguments
Bootstrap.sh accepts the following arguments:

* `--help`: Displays help text
* `--local`: Copies your local working copy of django-bare-bones rather than cloning from git. 
* `--nodepcheck`: Disables dependency checking. Use with extreme caution - this will cause the script to fail if a dependency is not installed. Never use for production-ready projects.

## Requirements
To use this script successfully you will need the following on the **host** machine:
* Ansible >= 2.3
* NodeJS
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

## Known Issues:

* Ctrl-c does not work when a whiptail window is visible. Cancel button replicates this functionality


## Changelog

#### Release 0.3.2
* Added fix for SSH hanging upon login with virtualbox provider.

#### Release 0.3.1
* Fixed django version to 1.10. 1.11 has a breaking change for wagtail. We should try to keep these app
versions fixed where possible.

#### Release 0.3
* Fixed installation of setuptools which is failing due to (not) missing dependencies. Hopefully this is a temporary bug with setuptools. Fixed dependencies are in requirements-setuptools-fix.txt.
