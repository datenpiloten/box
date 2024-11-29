#!/bin/bash

# Prompt for confirmation
read -p "This will revert the Samba setup, remove users, and delete share directories. Proceed? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
	    echo "Aborted."
	        exit 1
fi

# Prompt for environment variables
read -p "Enter the Samba username to remove (default: sambauser): " SMB_USER
SMB_USER=${SMB_USER:-sambauser}

read -p "Enter the share name to remove (default: box): " SHARE_NAME
SHARE_NAME=${SHARE_NAME:-box}

read -p "Enter the share path to delete (default: /srv/samba/$SHARE_NAME): " SHARE_PATH
SHARE_PATH=${SHARE_PATH:-/srv/samba/$SHARE_NAME}

# Remove Samba user
echo "Removing Samba user $SMB_USER..."
sudo smbpasswd -x "$SMB_USER"
sudo userdel "$SMB_USER" 2>/dev/null

# Remove the share directory
if [[ -d "$SHARE_PATH" ]]; then
	    echo "Deleting share directory $SHARE_PATH..."
	        sudo rm -rf "$SHARE_PATH"
	else
		    echo "Share directory $SHARE_PATH does not exist."
fi

# Reset Samba configuration to default
DEFAULT_SMB_CONF="/usr/share/samba/smb.conf"
if [[ -f "$DEFAULT_SMB_CONF" ]]; then
	    echo "Restoring the default Samba configuration..."
	        sudo cp "$DEFAULT_SMB_CONF" /etc/samba/smb.conf
	else
		    echo "Default Samba configuration file not found. Resetting to minimal default."
		        sudo bash -c "cat > /etc/samba/smb.conf" <<EOL
			[global]
   workgroup = WORKGROUP
   server string = Samba Server
   security = user
EOL
fi

# Restart Samba services
echo "Restarting Samba services..."
sudo systemctl restart smbd nmbd

# Confirmation of completion
echo "Revert complete. Samba setup has been reverted."

