#!/bin/bash
set -euo pipefail

echo "--> Pulling newest changes from Git repository..."
git pull -q

# Sends an M112/firmware restart signal to reset the MCU (microcontroller board) connection
echo "Sending firmware restart command to Klipper via Moonraker..."
curl -s -X POST http://localhost:7125/printer/firmware_restart
sleep 5 # Wait a moment for the firmware restart to process before the next command.

# Restarts the main Klipper host software service without resetting the microcontroller hardware
echo "Restarting Klipper via Moonraker API..."
curl -s -X POST http://localhost:7125/printer/restart
sleep 3 # Allow Klipper to finish restarting before restarting Moonraker.

# Restarts the Moonraker web server daemon itself
echo "Restarting Moonraker web server via Moonraker API..."
curl -s -X POST http://localhost:7125/server/restart

echo "\n--> Restart commands sent successfully via Moonraker."
echo "--> Remote operations complete."
exit 0