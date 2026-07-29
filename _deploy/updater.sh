#!/bin/bash

# A generic script to connect to a Klipper printer, pull the latest git changes,
# and restart the services via the Moonraker API.

# --- Validation ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <printer_host> <printer_user>"
    echo "Example: $0 dennisprinter.lan biqu"
    exit 1
fi

# --- Configuration ---
PRINTER_HOST="$1"
PRINTER_USER="$2"
KLIPPER_CONFIG_REPO_PATH="/home/${PRINTER_USER}/printer-common"
SSH_PASSWORD=${PRINTER_USER}

echo "Attempting to connect to ${PRINTER_USER}@${PRINTER_HOST}..."

# --- Password Management ---
# Check if sshpass is installed. If not, provide instructions.
# 'sshpass' is required for non-interactive password entry.
if ! command -v sshpass &> /dev/null; then
    echo "Error: 'sshpass' is not installed on your local machine."
    echo "Please install it to use this script for password-based SSH authentication."
    echo "  On Debian/Ubuntu: sudo apt-get install sshpass"
    echo "  On macOS (with Homebrew): brew install sshpass"
    echo "Alternatively, set up SSH keys on your printer for a more secure, passwordless experience."
    exit 1
fi

# --- Remote Execution ---
# The -tt option forces a pseudo-terminal, which is useful for scripting.
# The 'heredoc' (<< EOF) sends the enclosed block of commands to the remote machine.
sshpass -p "${SSH_PASSWORD}" ssh -o StrictHostKeyChecking=accept-new -tt "${PRINTER_USER}@${PRINTER_HOST}" 'bash -s' << EOF
    # Exit immediately if a command exits with a non-zero status.
    set -e

    echo "--> Navigating to Klipper config repository: ${KLIPPER_CONFIG_REPO_PATH}"
    cd "${KLIPPER_CONFIG_REPO_PATH}"

    echo "--> Pulling newest changes from Git repository..."
    git pull

    echo "--> Restarting Klipper via Moonraker API..."
    # These send POST requests to the local Moonraker instance on the printer.
    # This is more robust than restarting systemd services directly.
    curl -s -X POST http://localhost:7125/printer/firmware_restart
    
    # Wait a moment for the firmware restart to process before the next command.
    sleep 5
    
    curl -s -X POST http://localhost:7125/printer/restart

    echo "--> Restart commands sent successfully via Moonraker."
    echo "--> Remote operations complete."
    exit 0
EOF

# --- Final Status Check ---
if [ $? -eq 0 ]; then
    echo "Successfully connected and performed operations on ${PRINTER_HOST}."
else
    echo "An error occurred during the SSH session or remote commands."
fi

# Clear the password from memory for security
unset SSH_PASSWORD

exit 0