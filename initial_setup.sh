#!/bin/bash


# GETTING THE SYSTEM READY
echo "Starting init script"

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing unattended upgrades..."
sudo apt install unattended-upgrades

echo "Importing datenpiloten SSH keys..."
ssh-import-id-gh datenpiloten

# UFW CONFIG

echo "Allowing ports..."

echo "Allowing wireguard connection port..."
sudo ufw allow 51820

echo "Allowing zabbix agent port..."
sudo ufw allow 10050

echo "Allowing SMB port..."
sudo ufw allow 445

echo "Allowing ssh port..."
sudo ufw allow ssh

echo "Activating UFW (firewall)"
sudo ufw enable

# DEACTIVATING SSH PASSWORD LOGIN

#!/bin/bash

# Backup existing SSH configuration files
echo "Backing up SSH configuration files..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo cp /etc/ssh/sshd_config.d/50-cloud-init.conf /etc/ssh/sshd_config.d/50-cloud-init.conf.bak 2>/dev/null

# Update the main sshd_config file
echo "Updating /etc/ssh/sshd_config..."
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Update the cloud-init SSH configuration override
CLOUD_INIT_CONF="/etc/ssh/sshd_config.d/50-cloud-init.conf"
if [ -f "$CLOUD_INIT_CONF" ]; then
    echo "Updating $CLOUD_INIT_CONF..."
    sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' "$CLOUD_INIT_CONF"
    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$CLOUD_INIT_CONF"
else
    echo "Creating $CLOUD_INIT_CONF to disable password authentication..."
    echo "PasswordAuthentication no" | sudo tee "$CLOUD_INIT_CONF" > /dev/null
fi

# Restart the SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Confirm changes
echo "Verifying configuration..."
sudo sshd -T | grep -i passwordauthentication

echo "Password authentication has been disabled. Ensure key-based authentication is set up to avoid being locked out."



# DOCKER
echo "Installing docker..."
if curl -sSL https://get.docker.com | sh; then
	echo "Docker installed successfully."
        sudo usermod -aG docker $(whoami)
else
	echo "Docker installation failed."
fi
