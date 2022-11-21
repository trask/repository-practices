#!/bin/bash -e

# this script is required by prepare-release-branch.sh and prepare-patch-release.sh

# TODO replace with your logic
sed -Ei "s/version='[^']+'/version='$1'/" setup.py
