#!/usr/bin/env bash
set -euo pipefail

# WhiteSur icon theme (vinceliuice) — not in Fedora/COPR; install from source.
# install.sh defaults: WhiteSur, WhiteSur-light, WhiteSur-dark (blue variant)
# into /usr/share/icons when run as root.
curl -fLsS --retry 5 -o /tmp/whitesur.tar.gz \
  "https://codeload.github.com/vinceliuice/WhiteSur-icon-theme/tar.gz/refs/heads/master"
mkdir -p /tmp/whitesur
tar -xzf /tmp/whitesur.tar.gz --strip-components=1 -C /tmp/whitesur
/tmp/whitesur/install.sh