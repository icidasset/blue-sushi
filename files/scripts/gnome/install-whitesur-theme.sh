#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Install
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
sudo ./install.sh --theme all --round --silent-mode
sudo ./tweaks.sh --gdm --silent-mode
flatpak override --filesystem=xdg-config/gtk-3.0
flatpak override --filesystem=xdg-config/gtk-4.0

# TODO
# sudo ./tweaks.sh --flatpak --color Dark
# ./install.sh --libadwaita --silent-mode
