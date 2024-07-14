#!/bin/bash

RUN_ALL="Yes"
RUN_NONE="No"
RUN_SOME="Some"

TEXT_APT="Install Apt Packages"
TEXT_USER="Create New User"
TEXT_SSH="Setup SSH"
TEXT_ALIASES="Add Common Aliases"
TEXT_FORWARD_IP="Forward IP"

OP_APT="1"
OP_USER="2"
OP_SSH="3"
OP_ALIASES="4"
OP_FORWARD_IP="5"

export USER="None"
export EMAIL="None"
PROFILE="root"
HOME_PATH="/root"
export LOCAL_DIR=$(pwd -P)

source "$HOME_PATH/startup-bash/scripts/createUser.sh"
source "$HOME_PATH/startup-bash/scripts/networking.sh"
source "$HOME_PATH/startup-bash/scripts/aliases.sh"
source "$HOME_PATH/startup-bash/scripts/networking.sh"

if [ -f "user.txt" ]; then
	USER=$(sed -n 's/^Name=\(.*\)/\1/p' < "user.txt")
	EMAIL=$(sed -n 's/^Email=\(.*\)/\1/p' < "user.txt")
	echo
	echo "Running script for $USER ($EMAIL)" >> log.txt
fi

installApt () {
	apt install -y git ssh openssh-server procps adduser useradd openssl 2>&1 1>log.txt 2>/dev/null
	if [[ "$USER" != "None" ]] && [[ "$EMAIL" != "None" ]]; then
		git config --global user.name "$USER"
		git config --global user.email "$EMAIL"
	fi

	echo "Installed git ssh openssh-server procps adduser useradd openssl" >> log.txt
}

runMainMenu () {
	timeout 10s ba
	choice=$(whiptail --title "Linux Bash Setup" --menu "Run Preselected Scripts?" 12 50 3 \
		"Yes" "Run all" \
		"No" "Skip all" \
		"Some" "Select which scripts" 3>&1 1>&2 2>&3)
	echo "$choice"
}

runChoiceMenu() {
	choices=$(whiptail --separate-output --title "Linux Bash Setup" --checklist "Choose options" 12 50 6 \
  		"$OP_APT" "$TEXT_APT" ON \
  		"$OP_SSH" "$TEXT_SSH" ON \
		"$OP_USER" "$TEXT_USER" OFF \
  		"$OP_ALIASES" "$TEXT_ALIASES" ON \
		"$OP_FORWARD_IP" "$TEXT_FORWARD_IP" OFF 3>&1 1>&2 2>&3)
	echo $choices
}

runScripts() {
	# Input
	if [ $# -gt 0 ]; then
		if [[ "$1" == "ALL" ]]; then
			echo "Installing all scripts (Press CTRL+C to cancel)..."
			sleep 3
			installApt
			enableSSH
			createUser
			makeAliases
			editConf
		else
			for op in "$@"; do
				if [[ "$op" == "$OP_APT" ]]; then
					installApt
				elif [[ "$op" == "$OP_USER" ]]; then
					
					createUser
				elif [[ "$op" == "$OP_SSH" ]]; then
					
					enableSSH
				elif [[ "$op" == "$OP_ALIASES" ]]; then
					
					makeAliases
				elif [[ "$op" == "$OP_FORWARD_IP" ]]; then
					
					editConf
				fi
			done
		fi		
	fi

	echo "Done"
}

waitForKeypress() {
    echo "Press any key within 10 seconds to run the input prompt..."
    read -n 1 -t 10 keypress
    if [ $? -eq 0 ]; then
        echo 0
    else
        echo 1
    fi
}

main () {
	useInput=$(waitForKeypress)
	apt update 2>&1 1>log.txt 2>/dev/null
	apt install -y whiptail 2>/dev/null

	if [[ "$useInput" == 0 ]]; then
		runOption=$(runMainMenu)
	else
		runOption="$RUN_ALL"
	fi

	if [[ "$runOption" == "$RUN_ALL" ]]; then
		runScripts "ALL"
	elif [[ "$runOption" == "$RUN_NONE" ]]; then
		echo "Done"
		echo
	elif [[ "$runOption" == "$RUN_SOME" ]]; then
		choices=$(runChoiceMenu)
		runScripts $choices
	fi

	echo "Completed scripts" >> log.txt
	echo "Completed scripts..."
	echo
}

main
