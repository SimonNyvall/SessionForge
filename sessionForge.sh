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
	local config_content
	config_content=$(<"$config_file")
	echo "Config content: $config_content"

	sleep 2
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
			tmux_sessions_with_options=$(echo -e "$tmux_sessions\n$new_session_option\n${RED}$exit_option${NC}")

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
				# Prompt for new session name
				draw_boxed_prompt
				echo -ne "Enter session name: "
				read -r session_name

				while [[ $session_name =~ [^a-zA-Z0-9] ]] || [ -z "$session_name" ]; do
					draw_boxed_prompt
					echo -ne "\033[0;31mInvlid session name, try again\033[0m: "
					read -r session_name
				done

				clear

				tmux new -s "$session_name"
				;;
			"Exit terminal  (q)")
				exit 0
				;;
			*)
				# Attach to the selected session
				local session_name=$(echo "$chosen_option" | awk '{print $1}' | rev | cut -c 2- | rev)
				tmux attach-session -t "$session_name"
				;;
			esac
		fi
	else
		clear
		echo "Welcome Sir.Nyvall! . . ."
	fi
}

check_dependencies

tmux_forge