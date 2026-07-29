#!/bin/bash

# Configuration
PRINTER_USER="biqu"
SSH_PASSWORD="biqu"
PRINTER_HOST="dennisprinter.lan"
KLIPPER_CONFIG_REPO_PATH="/home/${PRINTER_USER}/printer-common"

echo "Attempting to connect to ${PRINTER_USER}@${PRINTER_HOST}..."

# Check if sshpass is installed. If not, provide instructions.
# 'sshpass' is required for non-interactive password entry.
if ! command -v sshpass &> /dev/null
then
    echo "Error: 'sshpass' is not installed on your local machine."
    echo "Please install it to use this script for password-based SSH authentication."
    echo "  On Debian/Ubuntu: sudo apt-get install sshpass"
    echo "  On macOS (with Homebrew): brew install sshpass"
    echo "Alternatively, set up SSH keys on your printer to avoid needing sshpass and password prompts entirely."
    unset SSH_PASSWORD # Clear the password from memory
    exit 1
fi

# dennis
# -rwxr-xr-x 1 root root 901896 Jul  5 02:17 /usr/local/bin/klipper_mcu

# artemis
# -rwxr-xr-x 1 root root 901896 Jul  5 02:35 /usr/local/bin/klipper_mcu

# Execute commands on the remote printer
# The -t option allocates a pseudo-terminal, which is often required for sudo commands.
sshpass -p "${SSH_PASSWORD}" ssh -o StrictHostKeyChecking=accept-new -tt "${PRINTER_USER}@${PRINTER_HOST}" << EOF
    echo "Navigating to Klipper config repository: ${KLIPPER_CONFIG_REPO_PATH}"
    cd "${KLIPPER_CONFIG_REPO_PATH}" || { echo "Error: Directory not found or not accessible. Exiting remote session."; exit 1; }

    echo "Pulling newest changes from Git repository..."
    git pull || { echo "Error: Git pull failed. Please check your repository configuration and network connection. Exiting remote session."; exit 1; }

    echo "Calling UTIL_RESTART macro via Moonraker API..."
    # This sends a request to the local Moonraker instance on the printer to run the UTIL_RESTART gcode macro.
    curl -s -X POST -H "Content-Type: application/json" -d '{"script":"UTIL_RESTART"}' http://${PRINTER_HOST}:7125/printer/gcode/script || { echo "Error: Failed to call Moonraker API. Is curl installed and is Moonraker running?"; exit 1; }
    echo

    echo "Restart command sent successfully via Moonraker."
    echo "Remote operations complete."
EOF

# Check the exit status of the ssh command
if [ $? -eq 0 ]; then
    echo "Successfully connected and performed operations on ${PRINTER_HOST}."
else
    echo "An error occurred during the SSH session or remote commands."
fi

# Clear the password from memory for security
unset SSH_PASSWORD

exit