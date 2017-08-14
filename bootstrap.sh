#!/bin/bash

# This is the bootstrap script for new projects.
#
# All variables used in this script are prefixed with BS_
# for clarity, variables used elsewhere omit this prefix.
# For example, inline settings in this script is
# BS_PH_SETTINGS_INLINE, and in other files it is
# PH_SETTINGS_INLINE.

# Partly for my own sanity

# Also note, this script can take these arguments:
# --help : Prints help
# --local : clones your local working copy rather than cloning from git
# --no-dep-check : Skips the dependency checking
# 
# Important: --no-dep-check should be used for debugging only!

# Check for help flag:
if [[ "${@#--help}" != "$@" ]] ; then
    echo
    echo "This script creates a new django-based project, built around the KDL infrastructure. It uses Vagrant for provisioning and Fabric for deployment If run with no parameters, the script will check all dependencies and clone a new django-bare-bones instane from git."
    echo 
    echo "Bootstrap takes the following arguments:"
    echo
    echo "--help         : Displays this help message"
    echo "--local        : Copies your local working copy instead of cloning from git"
    echo "--no-dep-check : Disables dependency checking*"
    echo
    echo "* Use with extreme caution - this will cause the script to fail if a dependency is not installed. Never use for production-ready projects."
    echo
    exit
fi

# PLACEHOLDERS:

BS_PH_SETTINGS_INLINE=""
BS_PH_SETTINGS_MODULES=""
BS_PH_INSTALLED_APPS=""
BS_PH_URLS=""
BS_PH_MIDDLEWARE=""
BS_PH_REQUIREMENTS=""
BS_PH_URL_IMPORTS=""
BS_PH_BOWER_FRAMEWORK=""
BS_PH_CONTEXT_PROCESSORS=""

# Captures sigint/sigterm
trap control_c SIGINT
trap control_c SIGTERM

function control_c {
    killall whiptail # Just in case...
    echo
    echo "#############################################"
    echo "Quitting. You may need to delete the project"
    echo "folder."
    echo "#############################################"
    echo
    exit
}

# Checks if the cancel button was pressed in whiptail, and
# if so, exits. Run this **directly** after calling 
# whiptail.
function whiptail_check_cancel {
    exitcode=$?
    if [ $exitcode = 1 ]; then
        echo
        echo "#############################################"
        echo "Quitting. You may need to delete the project"
        echo "folder."
        echo "#############################################"
        echo
        exit
    fi
}

# Variable replacements:

# Key/Name need refactoring, built the "UI" before checking existing
# values

# $PROJECT_TITLE = $BS_PROJECT_NAME
# $PROJECT_NAME = $BS_PROJECT_KEY
# $DIGGER_ID = $BS_DIGGER_ID <-- Module specific
# $LDAP_GROUP = $BS_LDAP_GROUP <-- Module Specific

# Define our system variables
TITLE="New KDL Project Setup"

# Get current git branch of django-bare-bones
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)


# Stop homebrew automatically updating itself...
export HOMEBREW_NO_AUTO_UPDATE=1

# Check for the --no-dep-check flag. If --no-dep-check is given, we assume
# all dependencies are met. This may cause errors. Use with caution
if [[ "${@#--no-dep-check}" != "$@" ]] ; then
    echo "- WARNING: Running without dependency checks. This may cause errors."
else
    # Check that vagrant is installed, and is the correct version.
    echo "- Checking Vagrant version"
    if ! [[ $(which vagrant) ]] ; then
        echo
        echo "#############################################"
        echo "Vagrant not detected, please install Vagrant"
        echo "from https://www.vagrantup.com"
        echo "#############################################"
        echo
        exit 1
    else
        vagrant_version="$(vagrant --version | cut -d' ' -f2)"
        if [ "$vagrant_version" \< "1.9" ] ; then 
            echo
            echo "#############################################"
            echo "Vagrant 1.9 or later is required, please"
            echo "update Vagrant from https://www.vagrantup.com"
            echo "#############################################"
            echo
            exit 1
        fi
    fi
    # OS-Specific Dependencies
    # OS X
    if [[ "$OSTYPE" == "darwin"* ]]; then

        # Check if Homebrew is installed
        if ! [[ $(which brew) ]] ; then
            # Install Homebrew
            echo "- Installing Homebrew (this will only need to be done once)"
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
        fi

        # Check if Whiptail is installed
        if ! [[ $(which whiptail) ]] ; then
            # Install Whiptail
            echo "- Installing Whiptail (this will only need to be done once)"
            brew install newt;
        fi

        # Check if npm is installed
        if ! [[ $(which npm) ]] ; then
            # Install Whiptail
            echo "- Installing Node :(this will only need to be done once)"
            brew install npm;
        fi
    else    

    # Linux
    # Check if npm is installed
        if ! [[ $(which npm) ]] ; then
            # Install Whiptail
            echo "- Installing Node :(this will only need to be done once)"
            sudo apt-get update
            sudo apt-get -y install npm
        fi
    fi

    # Ansible 
    echo "- Checking for Ansible updates"
    pip install --user --upgrade ansible

    if ! [[ $(which autopep8) ]] ; then
        # Install Autopep8
        echo "- Installing Autopep8"
        pip install --user autopep8
    fi

    if ! [[ $(which isort) ]] ; then
        # Install Isort
        echo "- Installing Isort"
        pip install --user isort
    fi

    # NodeJS Dependencies
    if ! [[ $(which bower) ]] ; then
        npm install -g bower
    fi
fi

# Get project info (dont accept blank entries here!)
BS_PROJECT_KEY=""
while [[ $BS_PROJECT_KEY == "" ]] ; do
    BS_PROJECT_KEY=$(whiptail --title "$TITLE" --inputbox "Choose a project key.\n\nThis should be the short project name which is used as the VM name." 10 40 3>&1 1>&2 2>&3)
    whiptail_check_cancel 
done

BS_PROJECT_TITLE=""
while [[ $BS_PROJECT_TITLE == "" ]] ; do
    BS_PROJECT_TITLE=$(whiptail --title "$TITLE" --inputbox "Choose a project title.\n\nThis is a slightly more verbose name, used as the project title." 10 40 3>&1 1>&2 2>&3)
    whiptail_check_cancel
done

# Get project options
BS_SELECTIONS=$(whiptail --title "$TITLE" --checklist "Select Project Options:" 20 78 8 \
"digger" "Enable the ActiveCollab Digger (Requires AC UID)" off \
"geodjango" "Enable geodjango and GIS" off \
"ldap" "Authenticate with the KDL LDAP server" on \
"wagtail" "Use the Wagtail CMS" off \
"wagtailsearch" "Use the Wagtail Search Engine (Requires Wagtail)" off \
"haystack" "Use the Haystack Search Engine." off  3>&1 1>&2 2>&3)
whiptail_check_cancel

# Get frontend framework choice
BS_BOWER_FRAMEWORK=$(whiptail --title "$TITLE" --menu "Select UI Framework:" 20 78 8 \
"bulma" "Bulma CSS: http://bulma.io" \
"foundation-sites" "Foundation (Full): http://foundation.zurb.com" \
"none" "Don't install any UI Framework" 3>&1 1>&2 2>&3)
whiptail_check_cancel

# Declare functions for options:

# Digger
function func_digger {
    BS_DIGGER_USER_ID=$(whiptail --title "$TITLE" --inputbox "Enter the Activecollab User ID to use for Digger in $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3);
    whiptail_check_cancel
    BS_DIGGER_PROJECT_ID=$(whiptail --title "$TITLE" --inputbox "Enter the Activecollab Project ID to use for Digger in $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3);
    whiptail_check_cancel

    export BS_DIGGER_USER_ID=$BS_DIGGER_USER_ID
    export BS_DIGGER_PROJECT_ID=$BS_DIGGER_PROJECT_ID
}

# LDAP
function func_ldap {
    BS_LDAP_GROUP=$(whiptail --title "$TITLE" --inputbox "Enter the LDAP group for $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3)
    whiptail_check_cancel
    export BS_LDAP_GROUP=$BS_LDAP_GROUP
}

# Get Selected Options
BS_SELECTIONS=$(echo "$BS_SELECTIONS" | tr -d \")
IFS=' ' read -r -a BS_PROJECT_OPTIONS <<< "$BS_SELECTIONS"


# Build up our placeholder text...
echo "- Collecting required modules"
for option in "${BS_PROJECT_OPTIONS[@]}"
do
    # Installed apps, urls, context_processors and middleware require indentation
    BS_PH_CONTEXT_PROCESSORS=$"$BS_PH_CONTEXT_PROCESSORS\n$(cat .modules/$option/context_processors)"
    BS_PH_SETTINGS_INLINE=$"$BS_PH_SETTINGS_INLINE\n$(cat .modules/$option/settings_inline)"
    BS_PH_SETTINGS_MODULES=$"$BS_PH_SETTINGS_MODULES\n$(cat .modules/$option/settings_modules)"
    BS_PH_INSTALLED_APPS=$"$BS_PH_INSTALLED_APPS\n$(cat .modules/$option/installed_apps)"
    BS_PH_URLS=$"$BS_PH_URLS\n$(cat .modules/$option/urls)"
    BS_PH_MIDDLEWARE=$"$BS_PH_MIDDLEWARE\n$(cat .modules/$option/middleware)"
    BS_PH_REQUIREMENTS=$"$BS_PH_REQUIREMENTS\n$(cat .modules/$option/requirements)"
    BS_PH_URL_IMPORTS=$"$BS_PH_URL_IMPORTS\n$(cat .modules/$option/url_imports)"
done

# Build bower placeholder
echo "- Building bower requirements"
if [[ "$BS_BOWER_FRAMEWORK" != "none" ]]; then
    BS_PH_BOWER_FRAMEWORK="    \"$BS_BOWER_FRAMEWORK\": null,"
fi

# Call option-specific functions
echo "- Setting up selected applications"
for option in "${BS_PROJECT_OPTIONS[@]}"
do
    case $option in
        ldap)
            func_ldap
            ;;

        digger)
            func_digger
            ;;
    esac
done

export BS_PH_CONTEXT_PROCESSORS=$BS_PH_CONTEXT_PROCESSORS
export BS_PH_SETTINGS_INLINE=$BS_PH_SETTINGS_INLINE
export BS_PH_SETTINGS_MODULES=$BS_PH_SETTINGS_MODULES
export BS_PH_INSTALLED_APPS=$BS_PH_INSTALLED_APPS
export BS_PH_URLS=$BS_PH_URLS
export BS_PH_MIDDLEWARE=$BS_PH_MIDDLEWARE
export BS_PH_REQUIREMENTS=$BS_PH_REQUIREMENTS
export BS_PH_URL_IMPORTS=$BS_PH_URL_IMPORTS
export BS_PH_BOWER_FRAMEWORK=$BS_PH_BOWER_FRAMEWORK

# Here we go!
cd ../

# Check for the --local flag. If --local is given, we copy locally
# rather than cloning fresh:
if [[ "${@#--local}" != "$@" ]] ; then
    echo "- Copying local development environment as we saw --local"
    cp -R django-bare-bones "$BS_PROJECT_KEY-django"
    cd "$BS_PROJECT_KEY-django"
else
    # Clone a new bare-bones for this project (not copying
    # In case of local changes - that way it's clean)
    echo "- Downloading files. Using branch $GIT_BRANCH"
    git clone https://github.com/kingsdigitallab/django-bare-bones.git "$BS_PROJECT_KEY-django"
    cd "$BS_PROJECT_KEY-django"
    git checkout "$GIT_BRANCH"
fi

# Placeholders
echo "- Adding settings to $BS_PROJECT_KEY"
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_CONTEXT_PROCESSORS:$ENV{BS_PH_CONTEXT_PROCESSORS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_SETTINGS_INLINE:$ENV{BS_PH_SETTINGS_INLINE}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_SETTINGS_MODULES:$ENV{BS_PH_SETTINGS_MODULES}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_INSTALLED_APPS:$ENV{BS_PH_INSTALLED_APPS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_URLS:$ENV{BS_PH_URLS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_MIDDLEWARE:$ENV{BS_PH_MIDDLEWARE}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_REQUIREMENTS:$ENV{BS_PH_REQUIREMENTS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_URL_IMPORTS:$ENV{BS_PH_URL_IMPORTS}:g' {} \;
perl -pi -e 's:\$PH_BOWER_FRAMEWORK:$ENV{BS_PH_BOWER_FRAMEWORK}:g' bower.json


export BS_PROJECT_KEY=$BS_PROJECT_KEY
export BS_PROJECT_TITLE=$BS_PROJECT_TITLE


# Generic Replacements
echo "- Replacing project variables"
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PROJECT_NAME:$ENV{BS_PROJECT_KEY}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PROJECT_TITLE:$ENV{BS_PROJECT_TITLE}:g' {} \;

find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$DIGGER_USER_ID:$ENV{BS_DIGGER_USER_ID}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$DIGGER_PROJECT_ID:$ENV{BS_DIGGER_PROJECT_ID}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$LDAP_GROUP:$ENV{BS_LDAP_GROUP}:g' {} \;

# Fix newlines
echo "- Fixing new lines"
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\\n:\n:g' {} \;


# Check if a catch-all URL exists and move it if needed
echo "- Cleaning up URLs"

# Find any catch all URLs
LINE_COUNTER=1
while read line; do
    let LINE_COUNTER=LINE_COUNTER+1
    if [[ $line =~ "url(r''" ]] ; then
        export BS_CATCH_ALL_URL=$line
        LINE_COUNTER+="d"
        sed -i".bak" "$LINE_COUNTER" project_name/urls.py
        rm project_name/urls.py.bak
        break
    fi
done <project_name/urls.py

if [ -z ${BS_CATCH_ALL_URL+x} ]; then
    # No catch all URL, remove the placeholder
    perl -pi -e 's:\$PH_CATCH_ALL_URL::g' project_name/urls.py
else
    # Move the catch all url
    perl -pi -e 's:\$PH_CATCH_ALL_URL:$ENV{BS_CATCH_ALL_URL}:g' project_name/urls.py
fi

# Run bower
echo "- Running Bower"
bower install

# Tidy Up
echo "- Tidying up"
rm -rf .git
rm -rf .modules
rm README.md
mv README_TEMPLATE.md README.md

echo "- Autopep8"
find . -type f -name '*.py' -not -path './.*' -exec autopep8 --aggressive --in-place {} \;
echo "- Sorting imports in Python files"
find . -type f -name '*.py' -not -path './.*' -exec isort --atomic {} \;

# Rename the project
echo "- Setting project name"
mv project_name "$BS_PROJECT_KEY"

# Remove ourself from the project
echo "- Removing bootstrap"
rm -f bootstrap.sh

# Final notification
echo "-$BS_PROJECT_KEY-django created!"
whiptail --title "$TITLE" --msgbox "Configuration complete. You can now provision your Vagrant VM, $BS_PROJECT_KEY-django" 20 70 0
