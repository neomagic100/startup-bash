#!/bin/bash

RUN_ALL="Yes"
RUN_NONE="No"
RUN_SOME="Some"

TEXT_APT="Install Apt Packages"
TEXT_USER="Create New User"
TEXT_SSH="Setup SSH"
OP_APT="1"
OP_USER="2"
OP_SSH="3"

USER="None"
EMAIL="None"

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
	apt install -y git ssh openssh-server procps 2>&1 1>log.txt 2>/dev/null
	if [[ "$USER" != "None" ]] && [[ "$EMAIL" != "None" ]]; then
		git config --global user.name "$USER"
		git config --global user.email "$EMAIL"
	fi
}

enableSSH () {
	systemctl enable ssh 2>&1 3>&1 1>log.txt 2>/dev/null
	if ! [ -f /etc/ssh/sshd_config ]; then
		touch /etc/sysctl.d/99-sysctl.conf
	fi

	LOGIN_PERMITTED=$(egrep ^"PermitRootLogin yes" < /etc/ssh/sshd_config)
	
	if [[ $LOGIN_PERMITTED == "" ]]; then
		echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
		systemctl restart sshd
	fi

}

runMainMenu () {
	choice=$(whiptail --title "Linux Bash Setup" --menu "Run Preselected Scripts?" 12 50 3 \
		"Yes" "Run all" \
		"No" "Skip all" \
		"Some" "Select which scripts" 3>&1 1>&2 2>&3)
	clear
	echo "$choice"
}

runChoiceMenu() {
	choices=$(whiptail --separate-output --checklist "Choose options" 10 35 5 \
  		"$OP_APT" "$TEXT_APT" ON \
  		"$OP_SSH" "$TEXT_SSH" ON \
  		"$OP_USER" "$TEXT_USER" OFF 3>&1 1>&2 2>&3)
	echo $choices
}

runScripts() {
	# Input
	if [ $# -gt 0 ]; then
		if [[ "$1" == "ALL" ]]; then
			installApt
			enableSSH
		else
			for op in "$@"; do
				if [[ "$op" == "$OP_APT" ]]; then
					installApt
				elif [[ "$op" == "$OP_SSH" ]]; then
					enableSSH
				elif [[ "$op" == "$OP_USER" ]]; then
					break
				fi		
			done
		fi
	else
		echo "Done"
	fi
}

main () {
	# Option to opt out of running
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
