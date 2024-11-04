#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please try again with sudo or as the root user."
    exit 1
fi

# Check if SSH is installed
if ! command -v sshd >/dev/null 2>&1; then
    echo "OpenSSH server is not installed. Installing..."
    apt update && apt install -y openssh-server
    if [ $? -ne 0 ]; then
        echo "Failed to install OpenSSH server. Exiting."
        exit 1
    fi
else
    echo "OpenSSH server is already installed."
fi

# Modify SSH configuration to allow root login
SSH_CONFIG="/etc/ssh/sshd_config"
if grep -q "^#PermitRootLogin" "$SSH_CONFIG"; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
elif grep -q "^PermitRootLogin" "$SSH_CONFIG"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
else
    echo "PermitRootLogin yes" >> "$SSH_CONFIG"
fi
echo "Root login enabled in SSH configuration."

# Restart SSH service to apply changes
echo "Restarting SSH service..."
systemctl restart ssh

# Check if SSH service restarted successfully
if systemctl is-active --quiet ssh; then
    echo "SSH service restarted successfully."
else
    echo "Failed to restart SSH service."
    exit 1
fi

echo "Script completed."
