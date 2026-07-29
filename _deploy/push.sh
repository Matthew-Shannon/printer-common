#!/bin/bash

git add .
git commit -m "updates"
git push

# You can now call the updater for any printer
# bash ./_deploy/updater.sh artemisprinter.lan biqu
# bash ./_deploy/updater.sh charlieprinter.lan biqu
bash ./_deploy/updater.sh dennisprinter.lan biqu
