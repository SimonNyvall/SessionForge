# Session Forge

Session Forge is a tool designed to enhance the management of tmux sessions, offering a user-friendly interface for session creation and management. This tool primarily addresses the limitations of `Alacritty`, a terminal emulator that does not support tabs, and provides a solution for those who frequently forget to start a tmux session. By streamlining the session management process, Session Forge makes it easier to organize and navigate multiple terminal sessions, bringing tab-like functionality to terminal environments where it's otherwise absent.

<img width="500px" src="./images/Screenshot from 2023-12-27 18-28-41.png" />

## Table of Contents

- [Installation](#installation)
- [Features / Usage](#features-usage)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Installation

In the root of the repository, there is an `install.sh` script that places a copy of the Session Forge script in the `/bin` directory. The installation process also appends a line to the `.bashrc` file, ensuring that the script executes every time a shell starts.

Session Forge oversees the installation of fzf and tmux. If fzf or tmux is not installed, you can install them manually or let the script handle the installation.

## Features/Usage

If the tmux server is not running, the script will automatically create a `main` session for you. Upon opening a new terminal window, you will be presented with several options:

- Choose an existing session to enter (with a session preview on the right).
- Create a new session.
  - When creating a new session, you will be prompted to enter a session name, which can only contain upper/lower case letters and numbers.
  - To return to the options menu, press the `backspace key`.
- Close the terminal.

<div align="center">
    <img width="200px" src="./images/Screenshot from 2023-12-27 18-28-41.png" /> &nbsp;&nbsp;
    <img width="200px" src="./images/Screenshot from 2023-12-27 18-28-50.png" /> &nbsp;&nbsp;
    <img width="200px" src="./images/Screenshot from 2023-12-27 18-28-57.png" /> &nbsp;&nbsp;
</div>

## Configuration

Currently, the configuration options are limited. In `~/.config/sessionForge/`, there is a config file that allows the user to customize the greeting message for new sessions.

## Dependencies

- `tmux`: Terminal multiplexer, essential for session management.
- `fzf`: Command-line fuzzy finder, used for session selection.
- `git`: Required for installing `fzf` if not already installed.
- Bash shell: The script is written for Bash and may not be compatible with other shells.

## Contributing

Contributions are welcome! If you'd like to contribute to Session Forge, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Commit your changes with clear, descriptive messages.
4. Push the branch to your fork.
5. Submit a pull request.

For bug reports and feature requests, please use the issue tracker in the repository.

## License

Session Forge is licensed under the MIT License. For the full license text, please see the [LICENSE](LICENSE) file in the repository.

## Acknowledgements

Special thanks to the tmux and fzf projects for their inspiring tools which play a crucial role in Session Forge. Additional gratitude to all contributors who have offered suggestions, fixes, and improvements to make this tool better.
