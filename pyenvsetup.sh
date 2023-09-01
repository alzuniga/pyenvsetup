#!/bin/bash
: '
   File:           environment_setup
   Author:         Al Zuniga
   Purpose:        Setup a Python programming environment
   Usage:          Checks user system for required Python software and
                   modules, and installs any missing Python software and/or
                   modules.
   Requirements:   Requires root/sudo privileges
   Date:           2023-08-23
   Copyright:      Copyright 2023 Al Zuniga
   License:        MIT
   License Summary:
                   Permission is hereby granted, free of charge, to any
                   person obtaining a copy of this software and associated
                   documentation files (the “Software”), to deal in the
                   Software without restriction, including without limitation
                   the rights to use, copy, modify, merge, publish, distribute,
                   sublicense, and/or sell copies of the Software,
                   and to permit persons to whom the Software is furnished to
                   do so, subject to the following conditions:

                   The above copyright notice and this permission notice shall
                   be included in all copies or substantial portions of
                   the Software.

                   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
                   KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
                   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
                   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
                   OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
                   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
                   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
                   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'


# Constant Declarations
declare +i -r SCRIPT_NAME="PYENVSETUP"
declare +i -r SCRIPT_VERSION="0.02 alpha"


: '
MAIN: Script entry point

PARAMETERS: none

RETURNS: none
'

function main(){
    clear
    echo -e "$SCRIPT_NAME version: $SCRIPT_VERSION\n\n"
    check_user_privilege
    upd_upgrd_all_pkgs
}


: '
CHECK_USER_PRIVILEGE: verify super user privileges

PARAMETERS: none

RETURNS: none
'

function check_user_privilege(){
    if [ "$EUID" = 0 ]; then
        echo -e "[+] ROOT PRIVILEGES: Running with root/sudo.\n"
    else
        echo -e "[-] NO PRIVILEGES: Requires root/sudo access!\n"
        sudo -k
        if sudo true; then
            echo -e "\n[+] ROOT PRIVILEGES: Running with sudo.\n"
        else
            echo -e "[-] NO PRIVILEGES: Requires root/sudo access!\n"
            echo -e "Exiting...\n"
            exit
        fi
    fi
}

: '
UPD__UPGRD_ALL_PKGS: Gets a list of upgradeable packages and upgrades them.

PARAMETERS: none

RETURNS: none
'

function upd_upgrd_all_pkgs(){
    # Update package manager
    echo -e "\n##### PACKAGE MANAGER UPDATE #####\n"
    echo -e "[+] Updating the package manager...\n"
    sudo apt update > /dev/null 2>&1

    # List packages to be upgrade
    echo -e "\n##### PACKAGE MANAGER UPGRADE #####\n"
    upgradeable_packages=$(sudo apt list -u -q 2>/dev/null | grep "/" | cut -d "/" -f1)
    
    if [ "$updgradeable_packages" != "" ]; then
        echo -e "[+] Upgradeable Packages:\n"
        echo -e "$upgradeable_packages\n"

        # Prompt user whether or not to continue with upgrade
        while true; do
            echo -e "\n"
            read -p "[+] [C/c]ontinue with upgrade [any other key to exit]?: " continue_upgrade
            if [ "${continue_upgrade,,}" == "c"   ]; then
                echo -e "[+] Updating packages. This may take a few minutes...\n"
                #sudo apt upgrade -y
                sudo apt upgrade --simulate # Debugging/Testing
                break
            else
                echo -e "\n[!] Skipping package upgrades."
                break
            fi
        done
    else
        echo -e "[+] No packages to upgrade.\n"
    fi
        
}

# Start script
main