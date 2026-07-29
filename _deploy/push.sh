#!/bin/bash
git add .
git commit -m "updates"
git push

#bash ./_deploy/artemis.sh
#bash ./_deploy/charlie.sh
bash ./_deploy/dennis.sh

