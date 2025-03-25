#!/bin/bash

# Log directory
declare -r LOG_DIR="/var/log/sudo"

# Check for interactive commands that need special handling 
INTERACTIVE_CMDS=("su" "su -" "login" "bash" "zsh" "screen" "tmux")
for cmd in "${INTERACTIVE_CMDS[@]}"; do
	if [[ "$*" == "$cmd" ]]; then
		# Log the command but don't pipe output (would break interactivity)
		log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_$(whoami)_${cmd}.log"
		echo "Command: $@" | /usr/bin/sudo tee "$log_file" > /dev/null
		# Execute directly without piping
		/usr/bin/sudo "$@"
		exit $?
	fi
done

# Pre-authorize sudo
if ! /usr/bin/sudo -v; then
	exit 1
fi

# Function to handle cleanup on SIGINT
ctrlc_handler() {
	echo "Command was interrupted (Ctrl+C)" | /usr/bin/sudo -E tee -a "$log_file"
	exit 1
}

# Create a unique log file for each logged command
log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_$(whoami)_$(echo "$1").log"

# Log the command
echo "Command: $@" | /usr/bin/sudo -E tee "$log_file" > /dev/null

# In case if SIGINT (Ctrl+C) signal was trapped call the correspondent handler
trap ctrlc_handler SIGINT

# Execute the command, log the output, and print it to the terminal
/usr/bin/sudo -E "$@" 2>&1 | /usr/bin/sudo -E tee -a "$log_file"
exit_code="${PIPESTATUS[0]}"

exit "$exit_code"
