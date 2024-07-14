#!/bin/bash

RUN_ALL="Yes"
RUN_NONE="No"
RUN_SOME="Some"

TEXT_APT="Install Apt Packages"
TEXT_USER="Create New User"
TEXT_SSH="Setup SSH"
TEXT_ALIASES="Add Common Aliases"

OP_APT="1"
OP_USER="2"
OP_SSH="3"
OP_ALIASES="4"

USER="None"
EMAIL="None"

LOCAL_DIR=$(pwd -P)

if [ -f "user.txt" ]; then
	USER=$(sed -n 's/^Name=\(.*\)/\1/p' < "user.txt")
	EMAIL=$(sed -n 's/^Email=\(.*\)/\1/p' < "user.txt")
fi

editConf () {
	if ! [ -f /etc/sysctl.d/99-sysctl.conf ]; then
		touch /etc/sysctl.d/99-sysctl.conf
	fi

	IPV4=$(egrep ^net.ipv4.ip_forward < /etc/sysctl.d/99-sysctl.conf)
	IPV6=$(egrep ^net.ipv6.conf.all.forwarding < /etc/sysctl.d/99-sysctl.conf)

	if [[ $IPV4 == "" ]]; then
		echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-sysctl.conf
	fi

	if [[ $IPV6 == "" ]]; then
		echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/99-sysctl.conf
	fi
	
	sudo sysctl -p
}

installApt () {
	apt install -y git ssh openssh-server procps adduser useradd openssl 2>&1 1>log.txt 2>/dev/null
	if [[ "$USER" != "None" ]] && [[ "$EMAIL" != "None" ]]; then
		git config --global user.name "$USER"
		git config --global user.email "$EMAIL"
	fi
}

createUser () {
	NAME=$(whiptail --title "Create User" --inputbox "Enter Username" 8 60 3>&1 1>&2 2>&3)
	PASS="dummy"
	CONFIRM_PASS="dummy1"
	ATTEMPTS=0

	while [[ "$PASS" != "$CONFIRM_PASS" ]]; do
		PROMPT="Enter Password"
		if [ $ATTEMPTS -gt 4 ]; then
			exit 5
		elif [ $ATTEMPTS -gt 0 ]; then
			PROMPT="$PROMPT: ** Passwords did not match **"
		fi
		PASS=$(whiptail --title "Create User" --passwordbox "$PROMPT" 8 60 3>&1 1>&2 2>&3)
		CONFIRM_PASS=$(whiptail --title "Create User" --passwordbox "Confirm Password" 8 60 3>&1 1>&2 2>&3)
		ATTEMPTS=$(("$ATTEMPTS"+1))
	done

	mkdir "/home/$NAME"
	useradd -d "/home/$NAME" -p "$(openssl passwd -6 "$PASS")" "$NAME"
}

enableSSH () {
	editConf

	LOGIN_PERMITTED=$(egrep ^"PermitRootLogin yes" < /etc/ssh/sshd_config)
	
	if [[ $LOGIN_PERMITTED == "" ]]; then
		echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
		systemctl restart sshd
	fi

	systemctl enable ssh 2>&1 3>&1 1>log.txt 2>/dev/null
}

makeAliases () {
	if ! [ -f /root/.bash_aliases ]; then
		cp aliases.sh /root/.bash_aliases
		cd /root || return

		echo \
		"if [ -f ~/.bash_aliases ]; then
    		. ~/.bash_aliases
		fi" >> .bashrc
		
		cd "$LOCAL_DIR" || return
	else 
		# ELSE CLAUSE UNTESTED

		aliasFile="$LOCAL_DIR/.bash_aliases"
		index=0
		arr=()
		while read -r line; do
			arr+=("$line")
			index=$(($index+1))
		done < "$aliasFile"

		for line in "${arr[@]}"; do
			aliasExists=$(grep "$line" < .bash_aliases)
			if [[ $aliasExists != " " ]]; then
				echo "$line" >> .bash_aliases
			fi
		done
	fi

	source /root/.bashrc
}

runMainMenu () {
	choice=$(whiptail --title "Linux Bash Setup" --menu "Run Preselected Scripts?" 12 50 3 \
		"Yes" "Run all" \
		"No" "Skip all" \
		"Some" "Select which scripts" 3>&1 1>&2 2>&3)
	echo "$choice"
}

runChoiceMenu() {
	choices=$(whiptail --separate-output --checklist "Choose options" 10 35 5 \
  		"$OP_APT" "$TEXT_APT" ON \
  		"$OP_SSH" "$TEXT_SSH" ON \
		"$OP_USER" "$TEXT_USER" OFF \
  		"$OP_ALIASES" "$TEXT_ALIASES" ON 3>&1 1>&2 2>&3)
	echo "$choices"
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
		else
			for op in "$@"; do
				if [[ "$op" == "$OP_APT" ]]; then
					installApt
				fi
			done

			for op in "$@"; do
				if [[ "$op" == "$OP_SSH" ]]; then
					enableSSH
				elif [[ "$op" == "$OP_USER" ]]; then
					createUser
				elif [[ "$op" == "$OP_ALIASES" ]]; then
					makeAliases
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
		runScripts "$choices"
	fi

	clear

	echo "Completed scripts..."
	echo
}

main
