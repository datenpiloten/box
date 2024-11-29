#!/bin/bash

# Enable command tracing
set -x

# Prompt for domain name
read -p "Enter the domain name for dynamic DNS setup: " DOMAIN_NAME

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y software-properties-common python3 python3-pip

# Install domain-connect-dyndns
echo "Installing domain-connect-dyndns..."
sudo pip3 install domain-connect-dyndns
sudo pip3 install --upgrade pyOpenSSL cryptography

# Set up dynamic DNS for the domain
echo "Setting up dynamic DNS for the domain: $DOMAIN_NAME..."
sudo domain-connect-dyndns setup --domain "$DOMAIN_NAME"

# Perform an initial update
echo "Performing an initial DNS update..."
sudo domain-connect-dyndns update --all

# Set up a cron job for regular updates
echo "Setting up cron job for DNS updates..."
CRON_JOB="*/1 * * * * /usr/bin/flock -n /tmp/ipupdate.lck /usr/local/bin/domain-connect-dyndns update --all --config /root/dyndns/settings.txt"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "Setup complete! Dynamic DNS updates are now configured."

