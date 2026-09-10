#!/bin/bash
set -euo pipefail

echo "--> Pulling newest changes from Git repository..."
git pull -q

echo "--> Restarting Klipper via Moonraker API..."

# These send POST requests to the local Moonraker instance on the printer.
# This is more robust than restarting systemd services directly.
curl -s -X POST http://localhost:7125/printer/firmware_restart
sleep 5 # Wait a moment for the firmware restart to process before the next command.

curl -s -X POST http://localhost:7125/printer/restart

echo "\n--> Restart commands sent successfully via Moonraker."
echo "--> Remote operations complete."
exit 0