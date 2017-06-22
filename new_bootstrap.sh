#!/bin/bash

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
PROJECT_KEY=$(whiptail --title "$TITLE" --inputbox "Choose a project key.\n\nThis should be the short project name which is used as the VM name." 10 40 3>&1 1>&2 2>&3)
PROJECT_TITLE=$(whiptail --title "$TITLE" --inputbox "Choose a project title.\n\nThis is a slightly more verbose name, used as the project title." 10 40 3>&1 1>&2 2>&3)

# Get project options
SELECTIONS=$(whiptail --title "$TITLE" --checklist "Select Project Options:" 20 78 4 \
"digger" "Enable the ActiveCollab Digger (Requires AC UID)" off \
"ldap" "Authenticate with the KDL LDAP server" on  3>&1 1>&2 2>&3)


# Declare functions for options:

# Digger
function func_digger {
    DIGGER_UID=$(whiptail --title "$TITLE" --inputbox "Enter the Activecollab UserID to use for Digger in $PROJECT_KEY." 10 40 3>&1 1>&2 2>&3);
}

# LDAP 
function func_ldap {
    LDAP_GROUP=$(whiptail --title "$TITLE" --inputbox "Enter the LDAP group for $PROJECT_KEY." 10 40 3>&1 1>&2 2>&3)
}

# Iterate through and process options
IFS=' ' read -r -a PROJECT_OPTIONS <<< "$SELECTIONS"
for option in "${PROJECT_OPTIONS[@]}"
do
    case $option in
        *ldap*)
            func_ldap
            ;;

        *digger*)
            func_digger
            ;;
    esac
done
