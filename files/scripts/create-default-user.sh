#!/usr/bin/env bash
set -euo pipefail

if ! getent passwd toko >/dev/null; then
    useradd --create-home --groups wheel --shell /bin/bash --skel /usr/etc/skel toko
    printf '%s\n' 'toko:password' | chpasswd
fi