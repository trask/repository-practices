#!/bin/bash -e

# TODO get the current version
sed -n "s/.*version='\([^']\+\)'/\1/p" setup.py
