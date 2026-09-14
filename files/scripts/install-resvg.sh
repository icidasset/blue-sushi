#!/usr/bin/env bash
set -euo pipefail

# resvg — SVG rendering for yazi previews.
# Not packaged in Fedora; use the official prebuilt Linux binary from
# GitHub releases: https://github.com/linebender/resvg/releases
VERSION=v0.48.1
curl -fLsS --retry 5 -o /tmp/resvg.tar.gz \
  "https://github.com/linebender/resvg/releases/download/${VERSION}/resvg-linux-x86_64.tar.gz"
tar -xzf /tmp/resvg.tar.gz -C /usr/bin
chmod +x /usr/bin/resvg