# django-bare-bones
Start up configuration for Django based projects.

The projects is configured to use [Vagrant](https://www.vagrantup.com/) for local development and [fabric](http://www.fabfile.org/) for deployment. The project also has some default templates based on [Foundation](http://foundation.zurb.com/) and it uses [RequireJS](http://www.requirejs.org/) for JavaScript loading and optimisation.

# Getting started
1. Clone this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Go into the `django-bare-bones` directory
3. Run the bootstrap command to set up the project name and the user
4.  name in the configuration files: `./bootstrap.sh PROJECT_NAME USERNAME`
5. The bootstrap script also:
    * disconnects from this repository by removing the `.git` directory; the new project can then added to its own repository
    * and renames the project directory to `PROJECT_NAME-django`.
6. Go into the new project directory `cd ../PROJECT_NAME-django`
7. Remove the bootstrap script `rm bootstrap.sh`
8. Edit settings and configuration files.

# Release 0.2
* Updated requirejs configuration to work with babeljs
* Updated the fabric script to work with git
* Added CI configuration files for tox and travis
