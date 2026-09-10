#!/bin/bash
set -euo pipefail

# publish
echo -e "\n\n=============================================================="
echo -e "\t[SLAVE] PULLING CHANGES"
git pull -q

# mcu restart
echo -e "\n\n=============================================================="
echo -e "\t[SLAVE] MCU RESTART"
curl -s -X POST http://localhost:7125/printer/firmware_restart
sleep 5

# printer restart
echo -e "\n\n=============================================================="
echo -e "\t[SLAVE] PRINTER RESTART"
curl -s -X POST http://localhost:7125/printer/restart
sleep 5

# moonraker restart
echo -e "\n\n=============================================================="
echo -e "\t[SLAVE] MOONRAKER RESTART"
curl -s -X POST http://localhost:7125/server/restart
sleep 5

# complete
echo -e "\n\n=============================================================="
echo -e "\t[SLAVE] DEPLOYMENT COMPLETE"
exit 0