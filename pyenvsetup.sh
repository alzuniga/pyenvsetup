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
declare +i -r SCRIPT_VERSION="0.05 Alpha"


: '
MAIN: Script entry point

PARAMETERS: none

RETURNS: none
'

function main(){
    clear
    echo -e "$SCRIPT_NAME version: $SCRIPT_VERSION"
    echo -e "-------------------------------\n"

    # Check if user has root/sudo privileges
    check_user_privilege

    # Make sure packages are up-to-date
    # Run apt update and apt upgrade
    upd_upgrd_all_pkgs

    # Check if Python3 and Pip are installed
    is_python_installed

    # Install virtualenv
    install_virtualenv


    echo -e "\n##### INSTALLATION COMPLETE #####\n"
    echo -e "[+] Your Python environment is now setup.\n"
    python3 --version
    echo "$(python3 -m pip --version | grep -Eo '^pip [0-9]+\.[0-9]+\.[0-9]+')"
    echo "$(python3 -m virtualenv --version | grep -Eo '^virtualenv [0-9]+\.[0-9]+\.[0-9]+')"
    echo -e "\n"
}


: '
CHECK_USER_PRIVILEGE: Verify super user privileges

PARAMETERS: none

RETURNS: none
'

function check_user_privilege(){
    echo -e "\n##### USER PRIVILEGE CHECK #####\n"

    if [[ "$EUID" -eq 0 ]]; then
        echo "[-] INCORRECT USER LEVEL: Running with root/sudo."
        echo "[!] Do not run ${SCRIPT_NAME} as root/sudo."
        echo -e "    ${SCRIPT_NAME} will ask for sudo privileges as needed.\n"
        echo -e "Exiting...\n"
        exit 1
    else
        echo -e "[+] CORRECT USER LEVEL: Running as a normal user.\n"
        sudo -k
    fi
}

: '
INSTALL_VIRTUALENV: Installs virtualenv for creating virtual environments.

PARAMETERS: none

RETURNS: none
'

function install_virtualenv(){
    echo -e "\n##### INSTALLING VIRTUALENV #####\n"
    read -p "Install virtualenv (Y/n)?: " continue_install

        if [[ "${continue_install,,}" == "y" ]]; then
            python_version=$(python3 --version | grep -Eo '3\.[0-9]{1,2}')
            file_path="/usr/lib/python$python_version"

            # For systems with EXTERNALLY-MANAGED enabled
            if [[ -f "$file_path/EXTERNALLY-MANAGED" ]]; then
                echo -e "[+] Disabling EXTERNALLY-MANAGED\n"
                sudo mv "$file_path/EXTERNALLY-MANAGED" \
                    "$file_path/DISABLED_EXTERNALLY-MANAGED"

                echo -e "\n[+] Installing virtualenv. This may take a few minutes..."            
                sudo -E -u $USER pip install --user virtualenv

                # Re-enable EXTERNALLY-MANAGED
                echo -e "[+] Enabling EXTERNALLY-MANAGED\n"
                sudo mv "$file_path/DISABLED_EXTERNALLY-MANAGED" \
                    "$file_path/EXTERNALLY-MANAGED"
            else
                sudo -E -u $USER pip install --user virtualenv
            fi
        else
            echo -e "\n[!] Skipping virtualenv installation."
            echo -e "[-] RECOMMENDED: virtualenv recommended, but not installed.\n"
            echo -e "Exiting...\n"
            exit 1
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

    # Check for Pip installation
    if [[ "$(which pip)" || "$(which pip3)" ]]; then
        echo "[+] INSTALLED: $(which pip || which pip3)"
    else
        packages+=("python3-pip")
    fi

    # Install missing packages/dependcies
    if (( ${#packages[@]} )); then
        echo -e "[-] NOT FOUND: ${packages[@]}"

        while true; do
            echo -e "\n"
            read -p "Install ${packages[@]} (Y/n)?: " continue_install

            if [[ "${continue_install,,}" == "y" ]]; then
                echo -e "\n[+] Installing ${packages[@]}. This may take a few minutes..."
                sudo apt -y install $(echo ${packages[@]})
                sudo -K
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
                sudo apt -y upgrade
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