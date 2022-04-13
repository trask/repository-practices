#!/bin/bash -e

# TODO update the current version
sed -Ei "s/version='[^']+'/version='$1'/" setup.py
