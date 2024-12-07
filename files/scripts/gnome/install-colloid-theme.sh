#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Skeleton dir for future HOME dir
export HOME="/etc/skel/"

# Install
git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
git checkout b9f3d5200032242d808c93065e32f8dd7407ece4
cd Colloid-gtk-theme
mkdir -p /etc/skel/.themes
sudo ./install.sh --dest /etc/skel/.themes --tweaks rimless --libadwaita
flatpak override --filesystem=xdg-config/gtk-3.0
flatpak override --filesystem=xdg-config/gtk-4.0
cd ..
rm -rf Colloid-gtk-theme
