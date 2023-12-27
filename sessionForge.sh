#!/usr/bin/env bash

check_dependencies() {
	# Check if fzf is installed
	if ! command -v fzf >/dev/null 2>&1; then
		echo -n "It would appear that fzf is not installed. Would you like to install it? (y/N): "
		read -r install_fzf

		if [[ $install_fzf =~ ^[Yy]$ ]]; then
			echo "Installing fzf..."
			git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
			~/.fzf/install
		else
			echo "fzf is required for this script to work. Exiting..."
			exit 0
		fi
	fi

	# Check if tmux is installed
	if ! command -v tmux >/dev/null 2>&1; then
		echo "It would appear that tmux is not installed. Would you like to install it? (y/N): "
		read -r install_tmux

		if [[ $install_tmux =~ ^[Yy]$ ]]; then
			echo "Installing tmux..."
			sudo apt install tmux

			options=("Arch Linux" "Debian/Ubuntu" "Fedora" "RHEL/CentOS" "macOS (Homebrew)" "macOS (MacPorts)" "openSUSE" "Exit")
			select opt in "${options[@]}"; do
				case $opt in
				"Arch Linux")
					echo "Installing tmux using pacman..."
					sudo pacman -S tmux
					break
					;;
				"Debian/Ubuntu")
					echo "Installing tmux using apt..."
					sudo apt install tmux
					break
					;;
				"Fedora")
					echo "Installing tmux using dnf..."
					sudo dnf install tmux
					break
					;;
				"RHEL/CentOS")
					echo "Installing tmux using yum..."
					sudo yum install tmux
					break
					;;
				"macOS (Homebrew)")
					echo "Installing tmux using Homebrew..."
					brew install tmux
					break
					;;
				"macOS (MacPorts)")
					echo "Installing tmux using MacPorts..."
					sudo port install tmux
					break
					;;
				"openSUSE")
					echo "Installing tmux using zypper..."
					sudo zypper install tmux
					break
					;;
				"Exit")
					echo "tmux is required for this script to work. Exiting..."
					exit 0
					;;
				*) echo "Invalid option $REPLY" ;;
				esac
			done
		else
			echo "tmux is required for this script to work. Exiting..."
			exit 0
		fi
	fi
}

check_config() {
	local config_dir="$HOME/.config/sessionForge"
	local config_file="$config_dir/config"

	# Check if the config directory exists
	if [ ! -d "$config_dir" ]; then
		echo "Config directory does not exist. Creating it..."
		mkdir -p "$config_dir"
	fi

	# Check if the config file exists
	if [ ! -f "$config_file" ]; then
		echo "Config file does not exist. Creating a default one..."
		echo "Welcome to session" >"$config_file"
	fi

	# Read the content of the config file
	config_content=$(<"$config_file")
}

draw_boxed_prompt() {
	local -i lines=$(tput lines)
	local -i cols=$(tput cols)

	local -i box_lines=3
	local -i box_cols=50

	local -i start_row=$(((lines - box_lines) / 2))
	local -i start_col=$(((cols - box_cols) / 2))

	clear

	# Draw the top border of the box
	tput cup "$start_row" "$start_col"
	echo -n "┌"
	for i in $(seq $((box_cols - 2))); do echo -n "─"; done
	echo "┐"

	# Draw the sides of the box
	for i in $(seq $((box_lines - 2))); do
		tput cup $((start_row + i)) "$start_col"
		echo -n "│"
		tput cup $((start_row + i)) $((start_col + box_cols - 1))
		echo "│ 󰈮"
	done

	# Draw the bottom border of the box
	tput cup $((start_row + box_lines - 1)) "$start_col"
	echo -n "└"
	for i in $(seq $((box_cols - 2))); do echo -n "─"; done
	echo "┘"

	# Position the cursor for the read command
	tput cup $((start_row + 1)) $((start_col + 2))
}

tmux_forge() {
	if [ -z "$TMUX" ]; then
		if [ -z "$(pgrep tmux)" ]; then
			tmux new -s "main"
		else
			# Define the "New session" and "Exit" options
			new_session_option="New session "
			exit_option="Exit terminal  (q)"

			# List existing sessions and add the new session and exit options
			tmux_sessions=$(tmux list-sessions)
			tmux_sessions_with_options=$(echo -e "$tmux_sessions\n\033[0;32m$new_session_option\033[0m\n\033[0;31m$exit_option\033[0m")

			chosen_option=$(echo "$tmux_sessions_with_options" | fzf --ansi --height 100% --reverse \
				--preview 'if [[ "{}" == *"'"$new_session_option"'"* ]]; then 
                           printf "%*s" $(( (10 - ${#new_session_option}) / 2 )) ""; 
                           echo -ne "\033[0;32mCreate a new tmux session\033[0m"; 
                       elif [[ "{}" == *"'"$exit_option"'"* ]]; then 
                           printf "%*s" $(( (23 - ${#exit_option}) / 2 )) ""; echo -ne "\033[0;31mExit terminal\033[0m"; 
                       else 
                           tmux capture-pane -pt "$(echo "{}" | awk -F: "{print \$1}" | cut -c 2-):1"; fi' \
				--header "Select a session, start a 'New session', or 'Exit terminal'")

			case $chosen_option in
			"New session ")
				prompt_for_session_name() {
					local session_name=""
					local key
					local -i key_code
					local prompt_text="Enter session name: "

					while true; do
						draw_boxed_prompt
						echo -ne "$prompt_text"
						session_name=""
						while IFS= read -r -n1 -s key; do
							key_code=$(printf '%d' "'$key")

							if [[ $key == "" ]]; then # Enter key (empty input)
								echo
								break
							elif [[ $key_code == 127 ]]; then # Backspace key
								if [[ -z $session_name ]]; then
									echo
									tmux_forge
									return
								else
									session_name=${session_name%?}
									echo -ne "\b \b"
								fi
							elif [[ $key =~ [a-zA-Z0-9] ]]; then
								session_name+=$key
								echo -n "$key"
							fi
						done

						if [[ -n $session_name ]]; then
							break
						else
							prompt_text="\033[0;31mYou must enter a session name: \033[0m"
						fi
					done

					clear
					tmux new -s "$session_name"
				}

				clear
				prompt_for_session_name
				;;
			"Exit terminal  (q)")
				clear
				kill -9 $PPID
				;;
			*)
				# Attach to the selected session
				local session_name=$(echo "$chosen_option" | awk '{print $1}' | rev | cut -c 2- | rev)

				if [[ $chosen_option == *"(attached)"* ]]; then
					draw_boxed_prompt
					echo -ne "\033[33mAlready attached. Reattach? (y/N): \033[0m"
					read -r attach_answer

					if [[ $attach_answer =~ ^[Yy]$ ]]; then
						tmux attach-session -t "$session_name"
					else
						tmux_forge
					fi
				else
					tmux attach-session -t "$session_name"
				fi
				;;
			esac
		fi
	else
		clear
		echo -e "$config_content \033[0;32m$(tmux display-message -p '#{session_name}')\033[0m"
	fi
}

check_dependencies

check_config

tmux_forge
