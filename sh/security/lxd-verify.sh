#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../../" && { [ -f lib/init ] && source lib/init || echo "Cannot find lib/init" && exit 1; }

if [ -z "$(dpkg -l | grep lxd)" ]; then
    sudo apt-get update
    sudo apt-get install -y lxd
fi

# verify lxd is installed
if [ -z "$(dpkg -l | grep lxd)" ]; then
    echo "Could not install lxd"
    exit 1
fi