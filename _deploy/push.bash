#!/bin/bash
git add .
git commit -m "updates"
git push

#bash ./_deploy/artemis.bash
#bash ./_deploy/charlie.bash
bash ./_deploy/dennis.bash

