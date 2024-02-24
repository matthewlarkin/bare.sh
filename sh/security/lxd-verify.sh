#!/bin/bash

if [ -z "$(dpkg -l | grep lxd)" ]; then
    sudo apt-get update
    sudo apt-get install -y lxd
fi

# verify lxd is installed
if [ -z "$(dpkg -l | grep lxd)" ]; then
    echo "Could not install lxd"
    exit 1
fi