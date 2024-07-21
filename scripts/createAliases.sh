#!/bin/bash
LOCAL_DIR=$(pwd -P)

makeAliases () {
	if ! [ -f "$HOME_PATH/.bash_aliases" ]; then
		cp aliases.sh "$HOME_PATH/.bash_aliases"
		cd $HOME_PATH || return

		echo \
		"if [ -f $HOME_PATH/.bash_aliases ]; then
    		. $HOME_PATH/.bash_aliases
		fi" >> "$HOME_PATH/.bashrc"
		
	else 
		# ELSE CLAUSE UNTESTED
		
		aliasFile="$HOME_PATH/.bash_aliases"
		index=0
		arr=()
		while read -r line; do
			arr+=("$line")
			index=$(($index+1))
		done < "$aliasFile"

		cd "$HOME_PATH" || return

		for line in "${arr[@]}"; do
			if ! grep -Fxq "$line" "$aliasFile"; then
				echo "$line" >> "$HOME_PATH/.bash_aliases"
			fi
		done
	fi

	echo "Added bash aliases" >> "$LOCAL_DIR/log.txt"
	cd "$LOCAL_DIR" || return
}
