#!/bin/bash

git add .
git commit -m "updates"
git push

# bash ./_deploy/updater.sh artemisprinter.lan biqu
bash ./_deploy/updater.sh charlieprinter.lan biqu
# bash ./_deploy/updater.sh dennisprinter.lan biqu