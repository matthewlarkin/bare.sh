#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../../" && { [ -f lib/init ] && source lib/init || echo "Cannot find lib/init" && exit 1; }

# User Creation and SSH Configuration on Ubuntu 22.04 VPS
# This is the first part of the VPS hardening process (before security-setup.sh)
# This step is intended to be run as root once you have logged in to the VPS

echo "🌿 Step 1: User Creation and SSH Configuration 🌿"

# Create a Non-Root User
read -p "Enter a new username to create: " my_new_user
adduser $my_new_user
usermod -aG sudo $my_new_user

# Set Up SSH for New User
mkdir -p /home/$my_new_user/.ssh
cp /root/.ssh/authorized_keys /home/$my_new_user/.ssh/
chown -R $my_new_user:$my_new_user /home/$my_new_user/.ssh
chmod 700 /home/$my_new_user/.ssh
chmod 600 /home/$my_new_user/.ssh/authorized_keys

# Create the server-admin directory in the new user's home
sudo mkdir -p /home/$my_new_user/bare.sh
sudo chown -R $my_new_user:$my_new_user /home/$my_new_user/bare.sh
sudo cp -r /root/bare.sh/* /home/$my_new_user/bare.sh/


# Secure SSH Configuration
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

printf "\n\n${green}SSH configuration updated.${reset} Please log in as the new user to continue with the setup."
