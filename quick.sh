#!/bin/bash

HOME_PATH="/root"
LOCAL_APP_PATH="startup-bash/"
START_PATH="$HOME_PATH"

NETWORKING_PATH="scripts/networking.sh"
ALIASES_PATH="scripts/createAliases.sh"
FONT_PATH="scripts/colorText.sh"

sudoCheck() {
	if command -v sudo &> /dev/null; then
		echo "sudo"
	else
		echo ""
	fi
}

installApt () {
	$(sudoCheck) apt update
	yes | $(sudoCheck) apt install git ssh openssh-server procps adduser openssl
	# if [[ "$USER" != "None" ]] && [[ "$EMAIL" != "None" ]]; then
	# 	git config --global user.name "$USER"
	# 	git config --global user.email "$EMAIL"
	# fi

	echo "Installed git ssh openssh-server procps adduser openssl" >> log.txt
}

if [ $# -gt 0 ]; then
	if [ -d "$1" ]; then
		START_PATH="$1"
		HOME_PATH="/$(echo $START_PATH | cut -d'/' -f2)/$(echo $START_PATH | cut -d'/' -f3)"
	else
		$(font "If an argument is specified, use an existing path as HOME_PATH.\nPath not valid: $1" "Red")
	fi
fi

if [[ "${START_PATH: -1}" != "/" ]]; then
	START_PATH="$START_PATH/"
fi

localHome=$(basename "$START_PATH")

if [[ "${localHome: -1}" != "/" ]]; then
	localHome="$localHome/"
fi

if [[ "$localHome" != "$LOCAL_APP_PATH" ]]; then
	APP_PATH="${START_PATH}${LOCAL_APP_PATH}"
else
	APP_PATH="$START_PATH"
fi

if [[ "${APP_PATH: -1}" != "/" ]]; then
	APP_PATH="$APP_PATH/"
fi

source "${APP_PATH}${NETWORKING_PATH}"
source "${APP_PATH}${ALIASES_PATH}"
source "${APP_PATH}${FONT_PATH}"

makeAliases
echo "Made aliases"
installApt
echo "Installed Packages"
enableSSH
echo "Enabled SSH"

if [ -f "$HOME/.bashrc" ]; then
	source "$HOME/.bashrc" &> bashrc_debug.log
	echo "Sourced .bashrc"
else
	echo ".bashrc file not found."
fi

echo "Done."
echo
