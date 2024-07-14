#!/bin/bash

makeAliases () {
	if ! [ -f $HOME_PATH/.bash_aliases ]; then
		cp aliases.sh /root/.bash_aliases
		cd $HOME_PATH || return

		echo \
		"if [ -f $HOME_PATH/.bash_aliases ]; then
    		. $HOME_PATH/.bash_aliases
		fi" >> .bashrc
		
		cd "$LOCAL_DIR" || return
	else 
		# ELSE CLAUSE UNTESTED

		aliasFile="$HOME_PATH/.bash_aliases"
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
	echo "Added bash aliases" >> log.txt
	source $HOME_PATH/.bashrc
}