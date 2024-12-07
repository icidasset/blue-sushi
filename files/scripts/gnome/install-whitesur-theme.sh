#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Skeleton dir for future HOME dir
export HOME="/etc/skel/"

# Install
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
git checkout 7d073f781d4bce0e04daec2523d825a14a7234ce
cd WhiteSur-gtk-theme
mkdir -p /etc/skel/.themes
sudo ./install.sh --silent-mode --dest /etc/skel/.themes --round --highdefinition --shell -panelheight bigger --libadwaita
flatpak override --filesystem=xdg-config/gtk-3.0
flatpak override --filesystem=xdg-config/gtk-4.0
sudo ./tweaks.sh --silent-mode --flatpak --color Dark
cd ..
rm -rf WhiteSur-gtk-theme
