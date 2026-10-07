#!/bin/sh
# Compiles the blue-sushi mouse side-button daemon bundled at
# /usr/local/bin/blue-sushi-mouse.c. Needs a C compiler in the build image;
# when one is missing the image stays usable — the side buttons just send
# raw events and no F24/F13 keys arrive.
set -eu
compiler="$(command -v gcc || command -v cc || true)"
if [ -n "$compiler" ]; then
  "$compiler" -O2 -Wall -o /usr/local/bin/blue-sushi-mouse /usr/local/bin/blue-sushi-mouse.c
  chmod 755 /usr/local/bin/blue-sushi-mouse
else
  echo "no C compiler found; blue-sushi-mouse not built" >&2
fi