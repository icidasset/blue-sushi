#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Skeleton dir for future HOME dir
export HOME="/etc/skel/"

# Install
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
git checkout 092d17fb1abaf0ea15eefc15d2e145a3737b45ea
cd WhiteSur-icon-theme
sudo ./install.sh
rm -rf WhiteSur-icon-theme
