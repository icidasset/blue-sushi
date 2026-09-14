#!/usr/bin/env bash
set -euo pipefail

# Apple cursor theme (ful1e5/apple_cursor) — not in Fedora/COPR.
# Installs the "macOS" variant into /usr/share/icons.
VERSION=v2.0.1
curl -fLsS --retry 5 -o /tmp/apple-cursors.tar.xz \
  "https://github.com/ful1e5/apple_cursor/releases/download/${VERSION}/macOS.tar.xz"
tar -xJf /tmp/apple-cursors.tar.xz -C /usr/share/icons