# blue-sushi recipes — available as `ujust <name>`

# Update the system image
system-update:
    sudo bootc upgrade
    echo "Update queued. Reboot to apply: ujust system-reboot"

# Reboot (to apply an update)
system-reboot:
    sudo systemctl reboot

# Roll back to the previous image and reboot
system-rollback:
    sudo bootc rollback
    sudo systemctl reboot

# Show deployment status
system-status:
    bootc status

# Remove old/unused deployments
system-clean:
    sudo bootc cleanup

# Connect to Tailscale (authenticate once per device)
tailscale-up:
    sudo tailscale up --ssh

# Disconnect from Tailscale
tailscale-down:
    sudo tailscale down

# Show Tailscale status
tailscale-status:
    tailscale status

# Update Framework firmware
firmware-update:
    sudo fwupdmgr refresh
    sudo fwupdmgr update

# File-to-file copies: `cp -r` into an already-existing config dir would
# nest the files one level too deep, where the app then ignores them.
# Copy the image's default configs into ~/.config (existing files untouched).
init-configs:
    mkdir -p ~/.config/niri ~/.config/noctalia ~/.config/darkman ~/.config/ghostty
    cp -n /usr/etc/skel/.config/niri/config.kdl ~/.config/niri/config.kdl || true
    cp -n /usr/etc/skel/.config/noctalia/config.toml ~/.config/noctalia/config.toml || true
    cp -n /usr/etc/skel/.config/darkman/config.yaml ~/.config/darkman/config.yaml || true
    cp -n /usr/etc/skel/.config/ghostty/config ~/.config/ghostty/config || true
    echo "Default configs copied (-n: existing files untouched)."