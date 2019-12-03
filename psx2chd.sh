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
# - RetroPie, any version.
# - mame-tools)

# Globals
# If the script is called via sudo, detect the user who called it and the homedir.
user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"

home="$(eval echo ~$user)"

# Variables
readonly RP_DIR="$home/RetroPie"
readonly RP_CONFIG_DIR="/opt/retropie/configs"
readonly SCRIPT_VERSION="0.1.1" # https://semver.org/
readonly SCRIPT_DIR="$(cd "$(dirname $0)" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_FULL="$SCRIPT_DIR/$SCRIPT_NAME"
readonly SCRIPT_TITLE="PSX2CHD"
readonly SCRIPT_DESCRIPTION="A tool for compressing PSX games into CHD format."
readonly ROMS_DIR="$RP_DIR/roms/psx"
readonly CHD_SCRIPT=$ROMS_DIR/chdscript.sh
readonly GIT_REPO_URL="https://github.com/kashaiahyah85/RetroPie-psx2chd"
readonly GIT_SCRIPT_URL="https://github.com/kashaiahyah85/RetroPie-psx2chd/blob/master/psx2chd.sh"

# Dialogs
BACKTITLE="$SCRIPT_DESCRIPTION"

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
function checkDeps() {
	echo "Checking for dependencies..."
	if [[ "$OSTYPE" == "darwin"* ]]
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
		sudo apt-get install -y dialog mame-tools
	fi
}

function cleanUp() {
    rm -f "$CHD_SCRIPT"
    clear
}

function fixNames() {
    cd $ROMS_DIR
    for OLD_NAME in *[0-9]\).chd
    do
        dialogInfo "Fixing filenames for multi-disc games,\nPlease wait..."
        NEW_NAME="${OLD_NAME/\ \(Disc\ /.CD}"
        NEW_NAME="${NEW_NAME/\).chd/}"
        mv "$OLD_NAME" "${NEW_NAME}"
    done
}

function generateM3U() {
    cd $ROMS_DIR
    for ROM in *.CD[0-9]
    do
        dialogInfo "Generating M3U for multi-disc game:\n\n$(basename -- \"$ROM\" | grep cd[0-9])"
        ls -1v | grep $ROM.CD[0-9] >> $(basename -- "$ROM").m3u
    done
}

function compressRoms() {
    dialogMsg "This tool will compress any bin/cue psx roms."
    cd $ROMS_DIR
    for ROM in *.cue
    do
        FILE_IN=$(basename -- "$ROM" | grep .cue)
        FILE_OUT="${FILE_IN%.*}.chd"
        BAK_FILE="${FILE_IN%.*}.cuebak"
         cd $ROMS_DIR
         echo chdman createcd -i \"$FILE_IN\" -o \"$FILE_OUT\" > $CHD_SCRIPT
         dialogInfo "Found \"${FILE_IN%.*}\"\n\n $(sh $CHD_SCRIPT | grep \%)"
         dialogInfo "Found \"${FILE_IN%.*}\"\n\n Complete."
         cleanUp
    done
}

function main() {
    checkDeps
    cleanUp
    compressRoms
    fixNames
    generateM3U
    cleanUp
}

main
exit 0
