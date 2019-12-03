#!/usr/bin/env bash

# psx2chd.sh
#
# RetroPie PSX2CHD
# A tool for compressing psx games into CHD format.
#
# Author: kashaiahyah85
# Repository: https://github.com/kashaiahyah85/RetroPie-psx2chd)
# License: MIT https://github.com/kashaiahyah85/RetroPie-psx2chd/blob/master/LICENSE)
#
# Requirements:
# - mame-tools

# Globals
# If the script is called via sudo, detect the user who called it and the homedir.
user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"

home="$(eval echo ~$user)"

# Variables
readonly ROMS_DIR="$home/RetroPie/roms/psx"
readonly SCRIPT_VERSION="0.1.0" # https://semver.org/
readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_TITLE="PSX2CHD"
readonly SCRIPT_DESCRIPTION="A tool for compressing PSX games into CHD format."
readonly DEPENDENCIES="mame-tools"
readonly GIT_REPO_URL="https://github.com/kashaiahyah85/RetroPie-psx2chd"
readonly GIT_SCRIPT_URL="https://github.com/kashaiahyah85/RetroPie-psx2chd/blob/master/psx2chd.sh"

# Dialogs
BACKTITLE="$SCRIPT_TITLE: $SCRIPT_DESCRIPTION"

# dialogMenu example of usage:
#options=( tag1 option1 tag2 option2 N optionN )
#dialogMenu "Text describing the options" "${options[@]}"
function dialogMenu() {
    local text="$1"
    shift
    dialog --no-mouse \
        --backtitle "$BACKTITLE" \
        --cancel-label "Back" \
        --ok-label "OK" \
        --menu "$text\n\nChoose an option." 17 75 10 "$@" \
        2>&1 > /dev/tty
}

# dialogYesNo example of usage:
#dialogYesNo "Do you want to continue?"
function dialogYesNo() {
    dialog --no-mouse --backtitle "$BACKTITLE" --yesno "$@" 15 75 2>&1 > /dev/tty
}

# dialogMsg example of usage
#dialogMsg "Failed to install package_name. Try again later."
function dialogMsg() {
    dialog --no-mouse --ok-label "OK" --backtitle "$BACKTITLE" --msgbox "$@" 20 70 2>&1 > /dev/tty
}

# dialogInfo example of usage:
# dialogInfo "Please wait. Compressing $PSX_ROM..."
function dialogInfo {
    dialog --infobox "$@" 8 50 2>&1 >/dev/tty
}

# end of dialog functions ###################################################


# Functions ##################################################################

function is_sudo() {
    [[ "$(id -u)" -eq 0 ]]
}

# Take care of deps
function check_deps() {
	echo "Checking for dependencies..."
	if [[ "$OSTYPE" == "linux-gnu" ]]
	then
		sudo apt-get install -y dialog mame-tools
	elif [[ "$OSTYPE" == "darwin"* ]]
	then
		brew install --verbose dialog mame-tools
		if [[ $(brew list | grep mame-tools) == "mame-tools" ]]
		then
			echo "Mame-Tools installed, continuing"
		else
			echo "Something is wrong with mame-tools."
			exit 1
		fi
	else
		echo "What even is this machine?"
		exit 1
	fi
}

function main() {
    echo "" > ROMLIST.tmp
    for PSX_ROM in "$ROMS_DIR/*.cue"
    do
    dialogYesNo "About to compress: $PSX_ROM\nDo you want to continue?"
    dialogInfo "Please wait. Compressing $PSX_ROM..."

    # The output files are named this way as a sort of temp file, and
    # are renamed appropriately in a later step.
    chdman createcd -i "$PSX_ROM" -o "$PSX_ROM.chd"
    done


}

check_deps
main
