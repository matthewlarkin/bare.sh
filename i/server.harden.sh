#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../" && source lib/init

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

# ⚠️ install ufw with snap (will have DNS issues, otherwise)
sudo snap install ufw -y

# Firewall Setup with UFW
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
# lxbr0 is the default bridge for lxd, so we need to allow traffic on it
sudo ufw allow in on lxdbr0
sudo ufw route allow in on lxdbr0
sudo ufw route allow out on lxdbr0
sudo ufw enable
sudo ufw status

# Automated Security Updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

printf "\n🙌 ${green}Basic security tools are installed and configured!${reset}\n"