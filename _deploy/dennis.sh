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

# Execute commands on the remote printer
# The -t option allocates a pseudo-terminal, which is often required for sudo commands.
sshpass -p "${SSH_PASSWORD}" ssh -o StrictHostKeyChecking=accept-new -tt "${PRINTER_USER}@${PRINTER_HOST}" << EOF
    echo "Navigating to Klipper config repository: ${KLIPPER_CONFIG_REPO_PATH}"
    cd "${KLIPPER_CONFIG_REPO_PATH}" || { echo "Error: Directory not found or not accessible. Exiting remote session."; exit 1; }

    echo "Pulling newest changes from Git repository..."
    git pull || { echo "Error: Git pull failed. Please check your repository configuration and network connection. Exiting remote session."; exit 1; }


    exit
EOF

echo "Restarting Klipper via Moonraker API..."
# These send POST requests to the Moonraker instance on the printer to restart Klipper.

echo "Restart commands sent successfully via Moonraker."
echo "Remote operations complete."

curl -s -X POST http://${PRINTER_HOST}:7125/printer/firmware_restart || { echo "Error: FIRMWARE_RESTART call failed. Is curl installed and is Moonraker running?"; exit 1; }
sleep 5
curl -s -X POST http://${PRINTER_HOST}:7125/printer/restart || { echo "Error: RESTART call failed. Is curl installed and is Moonraker running?"; exit 1; }

# Check the exit status of the ssh command
if [ $? -eq 0 ]; then
    echo "Successfully connected and performed operations on ${PRINTER_HOST}."
else
    echo "An error occurred during the SSH session or remote commands."
fi

# Clear the password from memory for security
unset SSH_PASSWORD

exit