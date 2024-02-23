#!/bin/bash

source lib/colors

# Security Tools Installation and Configuration on Ubuntu 22.04 VPS
# This is the second part of the VPS hardening process (after initial-setup.sh)
# This step is intended to be run as the new (non-root) user created in initial-setup.sh

echo "🌿 Step 2: Installing and Configuring Security Tools 🌿"

# Update System Packages
sudo apt update && sudo apt upgrade -y

# Fail2Ban Installation
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl restart fail2ban

# Firewall Setup with UFW
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
sudo ufw status

# Automated Security Updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

printf "\n🙌 ${green}Basic security tools are installed and configured!${reset}\n"