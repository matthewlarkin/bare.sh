#!/bin/bash

# check if nginx is installed
if [ -x "$(command -v nginx)" ]; then
    printf "\n✅ Nginx is already installed\n"
else
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
fi