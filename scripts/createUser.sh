#!/bin/bash

passwordLoop () {
	PROMPT="Enter Password"
	PASS=$(whiptail --title "Create User" --passwordbox "$PROMPT" 8 60 3>&1 1>&2 2>&3)
	exitStatus=$?
	[[ "$exitStatus" == 1 ]] && return;
	CONFIRM_PASS=$(whiptail --title "Create User" --passwordbox "Confirm Password" 8 60 3>&1 1>&2 2>&3)
	ATTEMPTS=1

	while [[ "$PASS" != "$CONFIRM_PASS" ]]; do
		if [ $ATTEMPTS -gt 4 ]; then
			return
		elif [ $ATTEMPTS -gt 0 ]; then
			PROMPT="$PROMPT: ** Passwords did not match **"
		fi
		PASS=$(whiptail --title "Create User" --passwordbox "$PROMPT" 8 60 3>&1 1>&2 2>&3)
		exitStatus=$?
		[[ "$exitStatus" == 1 ]] && return;
		CONFIRM_PASS=$(whiptail --title "Create User" --passwordbox "Confirm Password" 8 60 3>&1 1>&2 2>&3)
		exitStatus=$?
		[[ "$exitStatus" == 1 ]] && return;
		ATTEMPTS=$(("$ATTEMPTS"+1))
	done

	echo "$PASS"
}

createUser () {
	NAME=$(whiptail --title "Create User" --inputbox "Enter Username" 8 60 3>&1 1>&2 2>&3)
	exitStatus=$?
	[[ "$exitStatus" == 1 ]] && return;
	PASS=$(passwordLoop)
	mkdir "/home/$NAME"
	useradd -d "/home/$NAME" -p "$(openssl passwd -6 "$PASS")" "$NAME"
	echo "Added user $NAME" >> log.txt
}