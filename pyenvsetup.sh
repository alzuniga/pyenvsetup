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
declare +i -r SCRIPT_VERSION="0.03 alpha"


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
    is_python_installed
}


: '
CHECK_USER_PRIVILEGE: Verify super user privileges

PARAMETERS: none

RETURNS: none
'

function check_user_privilege(){
    echo -e "\n##### USER PRIVILEGE CHECK #####\n"

    if [[ "$EUID" -eq 0 ]]; then
        echo -e "[+] ROOT PRIVILEGES: Running with root/sudo.\n"
    else
        echo -e "[-] NO PRIVILEGES: Requires root/sudo access!\n"
        sudo -k
        if sudo true; then
            echo -e "\n[+] ROOT PRIVILEGES: Running with sudo.\n"
        else
            echo -e "[-] NO PRIVILEGES: Requires root/sudo access!\n"
            echo -e "Exiting...\n"
            exit 1
        fi
    fi
}

: '
IS_PYTHON_INSTALLED: Check if Python3 is installed on system.

PARAMETERS: none

RETURNS: none
'

function is_python_installed(){
    echo -e "\n##### PYTHON INSTALLATION CHECK #####\n"
    packages=()
    
    # Check for Python3 installation
    if [[ "$(which python3)" ]]; then
        echo "[+] INSTALLED: $(which python3)"
    else
        packages+=("python3")
    fi

    if [[ "$(which pip)" || "$(which pip3)" ]]; then
        echo "[+] INSTALLED: $(which pip || which pip3)"
    else
        packages+=("python3-pip")
    fi

    if [[ ${#packages[@]} ]]; then
        echo -e "[-] NOT FOUND: ${packages[@]}"

        while true; do
            echo -e "\n"
            read -p "Install ${packages[@]} (Y/n)?: " continue_install

            if [[ "${continue_install,,}" == "y" ]]; then
                echo -e "\n[+] Installing ${packages[@]}. This may take a few minutes..."
                # sudo apt install python3 python3-pip -y
                sudo apt install -s ${packages[@]} 2>/dev/null | grep -Ei "[0-9]+ newly installed"  # Debugging/Testing
                break
            else
                echo -e "\n[!] Skipping ${packages[@]} installation."
                echo -e "[-] MISSING: ${packages[@]} required, but not installed.\n"
                echo -e "Exiting...\n"
                exit 1
            fi
        done
    fi

    return 0
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
    
    if [[ -n "$updgradeable_packages" ]]; then
        echo -e "[+] Upgradeable Packages:\n"
        echo -e "$upgradeable_packages\n"

        # Prompt user whether or not to continue with upgrade
        while true; do
            echo -e "\n"
            read -p "Continue with upgrade (Y/n)?: " continue_upgrade
            if [[ "${continue_upgrade,,}" == "y" ]]; then
                echo "[+] Updating packages. This may take a few minutes..."
                #sudo apt upgrade -y
                sudo apt upgrade --simulate # Debugging/Testing
                echo -e "[+] Packages updated.\n"
                break
            else
                echo -e "[!] Skipping package upgrades.\n"
                break
            fi
        done
    else
        echo -e "[+] No packages to upgrade.\n"
    fi
    
    return 0
}

# Start script
main