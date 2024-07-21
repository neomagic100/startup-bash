#!/bin/bash

RED='\033[0;31m'
LIGHTRED='\033[1;31m'
CLEAR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LIGHTBLUE='\033[1;34m'

function lower() {
	if [ $# -ne 1 ]; then
		echo "Needs 1 argument"
	else
		echo "${1,,}"
	fi
}

function upper() {
	if [ $# -ne 1 ]; then
		echo "Needs 1 argument"
	else
		echo "${1^^}"
	fi
}

function str_equal_nocase() {
	if [ $# -ne 2 ]; then
		echo "Needs 2 arguments"
	else
		if [[ $(lower "$1") == $(lower "$2") ]]; then
			echo 1
		else
			echo 0
		fi
	fi 
}

function colorStringToCode() {
	if [ $# -ne 1 ]; then
		echo "Needs 1 argument"
	fi

	color=$(lower "$1")
	case $color in

		"red")
			FONTCOLOR="$RED"
			;;
		"lightred")
			FONTCOLOR="$LIGHTRED"
			;;
		"green")
			FONTCOLOR="$GREEN"
			;;
		"blue")
			FONTCOLOR="$BLUE"
			;;
		"lightblue")
			FONTCOLOR="$LIGHTBLUE"
			;;
		*)
			FONTCOLOR="$CLEAR"
			;;
	esac

	echo "$FONTCOLOR"
}

function font() {
	if [ $# -eq 0 ]; then
		echo "Needs at least 1 argument"
	elif [ $# -eq 1 ]; then
		echo -e "$1"
	elif [ $# -eq 2 ]; then
		FONTCOLOR=$(colorStringToCode "$2")
		echo -e "${FONTCOLOR}${1}${CLEAR}"
	fi
}
