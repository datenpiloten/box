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

echo "Activating UFW (firewall)"
sudo ufw enable

echo "Allowing ports..."

echo "Allowing wireguard connection port..."
sudo ufw allow 51820

echo "Allowing zabbix agent port..."
sudo ufw allow 10050

echo "Allowing ssh port..."
sudo ufw allow 22

# DEACTIVATING SSH PASSWORD LOGIN

sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo systemctl reload sshd

if systemctl is-active --quiet sshd; then
  echo "SSH service reloaded successfully. Password authentication is disabled."
else
  echo "Failed to reload SSH service! Restoring the backup configuration."
  sudo mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
  sudo systemctl reload sshd
fi

# DOCKER
echo "Installing docker..."
if curl -sSL https://get.docker.com | sh; then
	echo "Docker installed successfully."
        sudo usermod -aG docker $(whoami)
else
	echo "Docker installation failed."
