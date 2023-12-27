#!/usr/bin/env bash

cp ./sessionForge.sh /bin/sessionForge.sh

line_to_add="/bin/sessionForge.sh"

# The path to the .bashrc file
bashrc="$HOME/.bashrc"

# Check if the line already exists in the .bashrc file
if ! grep -qF -- "$line_to_add" "$bashrc"; then
	echo "$line_to_add" >>"$bashrc"
	echo "Line added to .bashrc: $line_to_add"
else
	echo "Line already exists in .bashrc"
fi
