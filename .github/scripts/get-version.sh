#!/bin/bash -e

# this script is required by prepare-release-branch.sh and prepare-patch-release.sh

# TODO replace with your logic
sed -n "s/.*version='\([^']\+\)'/\1/p" setup.py
