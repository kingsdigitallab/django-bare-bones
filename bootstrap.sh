#!/bin/bash

# This is the bootstrap script for new projects.
# 
# All variables used in this script are prefixed with BS_
# for clarity, variables used elsewhere omit this prefix.
# For example, inline settings in this script is 
# BS_PH_SETTINGS_INLINE, and in other files it is 
# PH_SETTINGS_INLINE.

# Partly for my own sanity

# PLACEHOLDERS:

BS_PH_SETTINGS_INLINE=""
BS_PH_SETTINGS_MODULES=""
BS_PH_INSTALLED_APPS=""
BS_PH_URLS=""
BS_PH_MIDDLEWARE=""
BS_PH_REQUIREMENTS=""
BS_PH_SIGNAL_HANDLERS=""


# Variable replacements:

# Key/Name need refactoring, built the "UI" before checking existing
# values

# $PROJECT_TITLE = $BS_PROJECT_NAME
# $PROJECT_NAME = $BS_PROJECT_KEY
# $DIGGER_ID = $BS_DIGGER_ID <-- Module specific
# $LDAP_GROUP = $BS_LDAP_GROUP <-- Module Specific

# Define our system variables
TITLE="New KDL Project Setup"

# First of all, check if we're on OS X:
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Homebrew is installed
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        echo "Installing Homebrew (this will only need to be done once)"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
    fi

    # Check if Whiptail is installed
    if [ ! -f /usr/local/bin/whiptail ]; then
        # Install Whiptail
        echo "Installing Whiptail (this will only need to be done once)"
        brew install newt;
    fi

    # Dependency Installation Finished
fi

# Get project info
BS_PROJECT_KEY=$(whiptail --title "$TITLE" --inputbox "Choose a project key.\n\nThis should be the short project name which is used as the VM name." 10 40 3>&1 1>&2 2>&3)
BS_PROJECT_TITLE=$(whiptail --title "$TITLE" --inputbox "Choose a project title.\n\nThis is a slightly more verbose name, used as the project title." 10 40 3>&1 1>&2 2>&3)

# Get project options
BS_SELECTIONS=$(whiptail --title "$TITLE" --checklist "Select Project Options:" 20 78 8 \
"digger" "Enable the ActiveCollab Digger (Requires AC UID)" off \
"ldap" "Authenticate with the KDL LDAP server" on \
"wagtail" "Use the Wagtail CMS" off \
"wagtailsearch" "Use the Wagtail Search Engine (Requires Wagtail)" off \
"haystack" "Use the Haystack Search Engine." off  3>&1 1>&2 2>&3)


# Declare functions for options:

# Digger
function func_digger {
    BS_DIGGER_USER_ID=$(whiptail --title "$TITLE" --inputbox "Enter the Activecollab User ID to use for Digger in $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3);
    BS_DIGGER_PROJECT_ID=$(whiptail --title "$TITLE" --inputbox "Enter the Activecollab Project ID to use for Digger in $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3);

    export BS_DIGGER_USER_ID=$BS_DIGGER_USER_ID
    export BS_DIGGER_PROJECT_ID=$BS_DIGGER_PROJECT_ID
}

# LDAP 
function func_ldap {
    BS_LDAP_GROUP=$(whiptail --title "$TITLE" --inputbox "Enter the LDAP group for $BS_PROJECT_KEY." 10 40 3>&1 1>&2 2>&3)
    export BS_LDAP_GROUP=$BS_LDAP_GROUP
}

# Get Selected Options
BS_SELECTIONS=$(echo "$BS_SELECTIONS" | tr -d \")
IFS=' ' read -r -a BS_PROJECT_OPTIONS <<< "$BS_SELECTIONS"


# Build up our placeholder text...
for option in "${BS_PROJECT_OPTIONS[@]}"
do
    # Installed apps, urls and middleware require indentation
    BS_PH_SETTINGS_INLINE=$"$BS_PH_SETTINGS_INLINE\n$(cat .modules/$option/settings_inline)" 
    BS_PH_SETTINGS_MODULES=$"$BS_PH_SETTINGS_MODULES\n$(cat .modules/$option/settings_modules)" 
    BS_PH_INSTALLED_APPS=$"$BS_PH_INSTALLED_APPS\n$(cat .modules/$option/installed_apps)" 
    BS_PH_URLS=$"$BS_PH_URLS\n$(cat .modules/$option/urls)" 
    BS_PH_MIDDLEWARE=$"$BS_PH_MIDDLEWARE\n$(cat .modules/$option/middleware)" 
    BS_PH_REQUIREMENTS=$"$BS_PH_REQUIREMENTS\n$(cat .modules/$option/requirements)" 
    BS_PH_SIGNAL_HANDLERS=$"$BS_PH_SIGNAL_HANDLERS\n$(cat .modules/$option/signal_handlers)" 
done

# Call option-specific functions
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

export BS_PH_SETTINGS_INLINE=$BS_PH_SETTINGS_INLINE
export BS_PH_SETTINGS_MODULES=$BS_PH_SETTINGS_MODULES
export BS_PH_INSTALLED_APPS=$BS_PH_INSTALLED_APPS
export BS_PH_URLS=$BS_PH_URLS
export BS_PH_MIDDLEWARE=$BS_PH_MIDDLEWARE
export BS_PH_REQUIREMENTS=$BS_PH_REQUIREMENTS
export BS_PH_SIGNAL_HANDLERS=$BS_PH_SIGNAL_HANDLERS


# Placeholders
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_SETTINGS_INLINE:$ENV{BS_PH_SETTINGS_INLINE}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_SETTINGS_MODULES:$ENV{BS_PH_SETTINGS_MODULES}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_INSTALLED_APPS:$ENV{BS_PH_INSTALLED_APPS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_URLS:$ENV{BS_PH_URLS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_MIDDLEWARE:$ENV{BS_PH_MIDDLEWARE}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_REQUIREMENTS:$ENV{BS_PH_REQUIREMENTS}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PH_SIGNAL_HANDLERS:$ENV{BS_PH_SIGNAL_HANDLERS}:g' {} \;


export BS_PROJECT_KEY=$BS_PROJECT_KEY
export BS_PROJECT_NAME=$BS_PROJECT_NAME

# Take backup
tar -zcf ../.django-bare-bones.tar.gz .

# Generic Replacements
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PROJECT_NAME:$ENV{BS_PROJECT_KEY}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$PROJECT_TITLE:$ENV{BS_PROJECT_NAME}:g' {} \;

find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$DIGGER_USER_ID:$ENV{BS_DIGGER_USER_ID}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$DIGGER_PROJECT_ID:$ENV{BS_DIGGER_PROJECT_ID}:g' {} \;
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\$LDAP_GROUP:$ENV{BS_LDAP_GROUP}:g' {} \;

# Fix newlines
find . -path ./.git -prune -o -type f \( ! -iname "*.sh" \) -exec perl -pi -e 's:\\n:\n:g' {} \;


# Tidy Up
rm -rf .git
rm -rf .modules

mv project_name "$BS_PROJECT_KEY"
cd ..
mv django-bare-bones "$BS_PROJECT_KEY-django"
mkdir django-bare-bones && cd django-bare-bones 
tar -zxf ../.django-bare-bones.tar.gz && rm ../.django-bare-bones.tar.gz
rm -f "../$BS_PROJECT_KEY-django/bootstrap.sh"



whiptail --title "$TITLE" --msgbox "Configuration complete. Please remember to add any required local settings." 20 70 0