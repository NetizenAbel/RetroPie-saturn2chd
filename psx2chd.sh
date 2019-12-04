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
# - dialog mame-tools)

# Globals
# If the script is called via sudo, detect the user who called it and the homedir.
user="$SUDO_USER"
[[ -z "$user" ]] && user="$(id -un)"

home="$(eval echo ~"$user")"

# Variables
readonly RP_DIR="$home/RetroPie"
readonly SCRIPT_DESCRIPTION="A tool for compressing PSX games into CHD format."
readonly ROMS_DIR="$RP_DIR/roms/psx"
readonly CHD_SCRIPT=$ROMS_DIR/chdscript.sh

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
        > /dev/tty
} 2>&1 

# dialogYesNo example of usage:
#dialogYesNo "Do you want to continue?"
function dialogYesNo() {
    dialog --no-mouse --backtitle "$BACKTITLE" --yesno "$@" 15 75 > /dev/tty
} 2>&1

# dialogMsg example of usage
#dialogMsg "Failed to install package_name. Try again later."
function dialogMsg() {
    dialog --no-mouse --ok-label "OK" --backtitle "$BACKTITLE" --msgbox "$@" 20 70 > /dev/tty
} 2>&1

# dialogInfo example of usage:
# dialogInfo "Please wait. Compressing $PSX_ROM..."
function dialogInfo {
    dialog --infobox "$@" 8 50 > /dev/tty
} 2>&1

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
			dialogInfo "Mame-Tools installed, continuing"
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
}

function fixNames() {
    cd "${ROMS_DIR}" || exit
    for OLD_NAME in *[0-9]\).chd
    do
        dialogInfo "Fixing filenames for multi-disc games,\nPlease wait..."
        NEW_NAME="${OLD_NAME/\ \(Disc\ /.CD}"
        NEW_NAME="${NEW_NAME/\).chd/}"
        mv "$OLD_NAME" "${NEW_NAME}"
	rm -f "${NEW_NAME/.CD[0-9]/m3u}"
    done
}

function cleanBins() {
    cd "${ROMS_DIR}" || exit
    for OLD_BIN in *[0-9]\).bin
    do
	dialogInfo "Renaming bins for a test."
	mv "$OLD_BIN" "${OLD_BIN}.bak"
    done
}

function buildM3us() {
    cd "${ROMS_DIR}" || exit
    for DISC in *.CD[0-9]
    do
	dialogInfo "Removing BIN files for converted multi-disc games."
	echo "${DISC}" >> "${DISC/CD[0-9]/m3u}"
    done
}

function compressRoms() {
    dialogMsg "This tool will compress any bin/cue psx roms."
    cd "${ROMS_DIR}" || exit
    for ROM in *.cue
    do
        FILE_IN=$(basename -- "$ROM" | grep .cue)
        FILE_OUT="${FILE_IN%.*}.chd"
         cd "$ROMS_DIR" || exit
         echo chdman createcd -i \""$FILE_IN"\" -o \""$FILE_OUT"\" > "$CHD_SCRIPT"
	 sh "$CHD_SCRIPT" 2>&1| sed 's/Compressing, //' | sed 's/.'[0-9]'% complete... (ratio='[0-9][0-9]'.'[0-9]'%)//'| dialog --gauge "Compressing ${FILE_IN%.*}" 1 70
		#| grep \\% \# | sed 's/Compressing, //' \
		# 2>&1 | dialog --gauge "Compressing \"${FILE_IN%.*}\"" 20 70\
#         dialogInfo "Found \"${FILE_IN%.*}\"\n\n $(sh "$CHD_SCRIPT" | grep \\%)"
#         dialogInfo "Found \"${FILE_IN%.*}\"\n\n Complete."
         cleanUp
    done
}

function main() {
    cleanUp
    checkDeps
    compressRoms
    fixNames
    cleanBins
    buildM3us
}

main
exit 0
