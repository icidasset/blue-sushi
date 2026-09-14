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

# Copy the image's default configs into ~/.config (for existing accounts;
# skel only applies to new users). Existing files are left untouched.
init-configs:
    mkdir -p ~/.config
    cp -rn /usr/etc/skel/.config/niri ~/.config/niri || true
    cp -rn /usr/etc/skel/.config/noctalia ~/.config/noctalia || true
    cp -rn /usr/etc/skel/.config/darkman ~/.config/darkman || true
    cp -rn /usr/etc/skel/.config/ghostty ~/.config/ghostty || true
    echo "Default configs copied (-n: existing files untouched)."