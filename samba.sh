#!/bin/bash

# Enable command tracing
set -x

# Prompt for environment variables
read -p "Enter the Samba username (default: sambauser): " SMB_USER
SMB_USER=${SMB_USER:-sambauser}

read -p "Enter the share name (default: box): " SHARE_NAME
SHARE_NAME=${SHARE_NAME:-box}

read -p "Enter the share path (default: /srv/samba/$SHARE_NAME): " SHARE_PATH
SHARE_PATH=${SHARE_PATH:-/srv/samba/$SHARE_NAME}

read -p "Enter the Samba password (leave blank to auto-generate): " SMB_PASSWORD
SMB_PASSWORD=${SMB_PASSWORD:-$(openssl rand -base64 12)}

# Confirm the input
echo "Configuration:"
echo "Samba username: $SMB_USER"
echo "Share name: $SHARE_NAME"
echo "Share path: $SHARE_PATH"
echo "Generated password: $SMB_PASSWORD"
read -p "Proceed with this configuration? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
	    echo "Aborted by user."
	        exit 1
fi

# Install Samba
echo "Installing Samba..."
sudo apt update && sudo apt install -y samba

# Add a new system user for Samba
echo "Creating system user $SMB_USER..."
sudo useradd -M -s /usr/sbin/nologin "$SMB_USER"

# Set the Samba password for the user
echo -e "$SMB_PASSWORD\n$SMB_PASSWORD" | sudo smbpasswd -a "$SMB_USER"
sudo smbpasswd -e "$SMB_USER"

# Create the share directory
echo "Creating share directory at $SHARE_PATH..."
sudo mkdir -p "$SHARE_PATH"
sudo chown -R "$SMB_USER:$SMB_USER" "$SHARE_PATH"
sudo chmod -R 0770 "$SHARE_PATH"

# Write the Samba configuration
echo "Setting up Samba configuration..."
sudo bash -c "cat > /etc/samba/smb.conf" <<EOL
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   netbios name = $(hostname)
   security = user
   map to guest = Bad User
   dns proxy = no

[$SHARE_NAME]
   path = $SHARE_PATH
   valid users = $SMB_USER
   read only = no
   browsable = yes
EOL

# Restart Samba services
echo "Restarting Samba services..."
sudo systemctl restart smbd
sudo systemctl enable smbd

# Output credentials
echo "Samba setup complete!"
echo "Share Name: $SHARE_NAME"
echo "Path: $SHARE_PATH"
echo "Username: $SMB_USER"
echo "Password: $SMB_PASSWORD"

