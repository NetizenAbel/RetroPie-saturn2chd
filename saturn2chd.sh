#!/usr/bin/env bash

# saturn2chd.sh
#
# RetroPie Saturn2CHD
# A tool for compressing saturn games into CHD format.
#
# Author: kashaiahyah85
# Repository: https://github.com/kashaiahyah85/RetroPie-saturn2chd)
# License: MIT https://github.com/kashaiahyah85/RetroPie-saturn2chd/blob/master/LICENSE)
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
readonly SCRIPT_DESCRIPTION="A tool for compressing Saturn games into CHD format."
readonly ROMS_DIR="$RP_DIR/saturn"
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
        --menu "$text\\n\\nChoose an option." 17 75 10 "$@" \
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
# dialogInfo "Please wait. Compressing $Saturn_ROM..."
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
		if [[ "$(command -v chdman)" != "" ]]
		then
			dialogInfo "Mame-Tools installed, continuing"
		else
			echo "Something is wrong with mame-tools."
			brew install dialog chdman || exit
		fi
	else
		sudo apt-get install -y dialog mame-tools
	fi
}

function buildM3us() {
    dialogInfo "Writing M3U files for converted multi-disc games."
    cd "${ROMS_DIR}" || exit

    for DISC in *Disc\ [0-9]* 
    do
	FIXED=${DISC/\ \(Disc\ [0-9]\)/}
	dialogInfo "Renaming $DISC to ${FIXED}"
	mv "$DISC" "${FIXED}"
    done

    dialogInfo "Writing M3U files for converted multi-disc games."
    for M3U in *.m3u
    do
	    rm -f "$M3U"
    done

    for DISC in *CD[0-9]
    do
	    echo "$DISC" >> "${DISC/CD[0-9]/m3u}"
    done
}

function compressRoms() {
    dialogMsg "This tool will compress any bin/cue saturn roms."
    cd "${ROMS_DIR}" || exit
    for ROM in *.cue
    do
        FILE_IN=$(basename -- "$ROM" | grep .cue)
        FILE_OUT="${FILE_IN%.*}.chd"
         cd "$ROMS_DIR" || exit
         echo chdman createcd -np 4 -i \""$FILE_IN"\" -o \""$FILE_OUT"\" > "$CHD_SCRIPT"
	 (sh "$CHD_SCRIPT") 2>&1| dialog --progressbox "${FILE_IN%.*}" 5 80 || exit
	 rm -f "$CHD_SCRIPT"
    done
}

function main() {
    checkDeps || exit
    compressRoms || exit
    buildM3us || exit
}

main
exit 0
