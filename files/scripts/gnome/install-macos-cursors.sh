#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Install
mkdir apple_cursor
cd apple_cursor
wget -O macOS.tar.xz https://github.com/ful1e5/apple_cursor/releases/download/v2.0.1/macOS.tar.xz
tar -xvf macOS.tar.xz
mkdir -p /etc/skel/.icons
mv macOS* /etc/skel/.icons/
