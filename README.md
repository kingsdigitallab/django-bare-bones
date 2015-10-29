# django-bare-bones
Start up configuration for Django 1.8* based projects. The projects is configured to use Vagrant for local development and fabric for deployment.

# Getting started
1. Clone or this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Run the bootstrap command to set up the project name and the user name in the configuration files: `./bootstrap.sh PROJECT_NAME USERNAME`
3. The bootstrap script also:
    * disconnects from this repository by removing the `.git` directory; the new project can then added to its own repository
    * and renames the project directory to `PROJECT_NAME-django`.
