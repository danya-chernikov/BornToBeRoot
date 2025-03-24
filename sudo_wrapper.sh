#!/bin/bash

# Log directory
declare -r LOG_DIR="/var/log/sudo"

# Function to handle logging on SIGINT
ctrlc_handler() {
	echo "Command was interrupted (Ctrl+C)" | /usr/bin/sudo tee -a "$log_file"
	exit 1
}

# Create a unique log file for each logged command
log_file="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_$(whoami)_$(echo "$1" | sed 's/[^a-zA-Z0-9_-]//g').log"

# Log the command
echo "Command: $@" | /usr/bin/sudo tee "$log_file" > /dev/null

# In case if SIGINT (Ctrl+C) signal was trapped call the correspondent handler
trap ctrlc_handler SIGINT

# Execute the command, log the output, and print it to the terminal
/usr/bin/sudo "$@" 2>&1 | /usr/bin/sudo tee -a "$log_file"
exit_code="${PIPESTATUS[0]}"

exit "$exit_code"
