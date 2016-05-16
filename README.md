# django-bare-bones
Start up configuration for Django based projects.

The projects is configured to use [Vagrant](https://www.vagrantup.com/) for local development and [fabric](http://www.fabfile.org/) for deployment. The project also has some default templates based on [Foundation](http://foundation.zurb.com/) and it uses [RequireJS](http://www.requirejs.org/) for JavaScript loading and optimisation.

# Getting started
1. Clone this repository: `git clone git@github.com:kingsdigitallab/django-bare-bones.git`
2. Go into the `django-bare-bones` directory
3. Run the bootstrap command to set up the project name and the user name in the configuration files: `./bootstrap.sh PROJECT_NAME USERNAME`
5. The bootstrap script also:
    * disconnects from this repository by removing the `.git` directory; the new project can then added to its own repository
    * and renames the project directory to `PROJECT_NAME-django`.
6. Go into the new project directory `cd ../PROJECT_NAME-django`
7. Remove the bootstrap script `rm bootstrap.sh`
8. Edit settings and configuration files.

# Release 0.2.6
* Issue fixing

# Release 0.2.5
* flake8 pre-commit hook added to git during provisioning
    * **Note**:flake8 needs to be installed in the OS where the commits are being done

# Release 0.2.4
* Removed Modernizr
* Cleaned up Foundation dependencies
* Added comments to set up scss for Foundation and FontAwesome

# Release 0.2.3
* Added more default Python requirements

# Release 0.2.2
* Fixed ansible deprecation issues
* Fixed issues setting postgres authentication

# Release 0.2.1
* Added missing reference to requirejs script from the base template
* Removed references to wagtail/wagtailbase

# Release 0.2
* Updated requirejs configuration to work with babeljs
* Updated the fabric script to work with git
* Added CI configuration files for tox and travis
