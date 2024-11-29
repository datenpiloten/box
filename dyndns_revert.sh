#!/bin/bash

# Stop and remove the cron job
echo "Removing cron job for domain-connect-dyndns..."
crontab -l | grep -v "domain-connect-dyndns" | crontab -

# Uninstall domain-connect-dyndns
echo "Uninstalling domain-connect-dyndns..."
pip3 uninstall -y domain-connect-dyndns

# Clean up configuration files
echo "Cleaning up configuration files..."
CONFIG_DIR="/root/dyndns"
if [ -d "$CONFIG_DIR" ]; then
	    sudo rm -rf "$CONFIG_DIR"
	        echo "Removed $CONFIG_DIR."
	else
		    echo "No configuration directory found at $CONFIG_DIR."
fi

# Clean up Python dependencies if installed via pip
echo "Removing Python dependencies (if necessary)..."
pip3 uninstall -y pyOpenSSL cryptography

# Clean up additional directories if needed
echo "Checking for user-specific installations..."
USER_BIN_DIR="$HOME/.local/bin"
if [ -d "$USER_BIN_DIR" ]; then
	    find "$USER_BIN_DIR" -name "domain-connect-dyndns" -exec rm -f {} \;
	        echo "Removed domain-connect-dyndns from $USER_BIN_DIR."
fi

echo "Revert complete. Dynamic DNS setup has been removed."
