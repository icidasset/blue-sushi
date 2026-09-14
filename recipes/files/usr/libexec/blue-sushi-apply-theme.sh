#!/usr/bin/env bash
# blue-sushi theme flipper — called by Noctalia's theme_mode_changed hook.
# Applies dark/light to GTK apps and the ghostty terminal theme.
set -uo pipefail

mode="${1:-dark}"

# GTK4/libadwaita apps follow color-scheme.
gsettings set org.gnome.desktop.interface color-scheme "prefer-${mode}"

# GTK3 apps follow gtk-theme.
if [[ "${mode}" == "dark" ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
else
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
fi

# Ghostty terminal theme (dark: rose-pine, light: rose-pine-dawn).
if [[ "${mode}" == "dark" ]]; then
  ghost_theme="rose-pine"
else
  ghost_theme="rose-pine-dawn"
fi
config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
mkdir -p "$(dirname "${config}")"
if grep -q '^theme' "${config}" 2>/dev/null; then
  sed -i "s/^theme = .*/theme = ${ghost_theme}/" "${config}"
else
  printf 'theme = %s\n' "${ghost_theme}" >> "${config}"
fi

# Switch running ghostty windows live when the CLI supports it;
# otherwise the config change applies on the next reload/launch.
ghostty +change-theme "${ghost_theme}" >/dev/null 2>&1 || true