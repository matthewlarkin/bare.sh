#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && { [ -f lib/init ] && source lib/init || echo "Cannot find lib/init" && exit 1; }

# check if nginx is installed
if [ -x "$(command -v nginx)" ]; then
    printf "\n✅ Nginx is already installed\n"
else
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
fi