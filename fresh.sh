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

export LOCAL_DIR=$(pwd -P)

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
	choice=$(whiptail --title "Linux Bash Setup" --menu "Run Preselected Scripts?" 12 50 3 \
		"Yes" "Run all" \
		"No" "Skip all" \
		"Some" "Select which scripts" 3>&1 1>&2 2>&3)
	echo "$choice"
}

runChoiceMenu() {
	choices=$(whiptail --separate-output --checklist "Choose options" 12 50 6 \
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
					source /root/scripts/createUser.sh
					createUser
				elif [[ "$op" == "$OP_SSH" ]]; then
					source /root/scripts/networking.sh
					enableSSH
				elif [[ "$op" == "$OP_ALIASES" ]]; then
					source /root/scripts/aliases.sh
					makeAliases
				elif [[ "$op" == "$OP_FORWARD_IP" ]]; then
					source /root/scripts/networking.sh
					editConf
				fi
			done
		fi		
	fi

	echo "Done"
}

main () {
	apt update 2>&1 1>log.txt 2>/dev/null
	apt install -y whiptail 2>/dev/null

	runOption=$(runMainMenu)

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

echo "Starting" >> log.txt
echo "Starting." 
main
