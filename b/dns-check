#!/bin/bash

source colors.sh

public_ip=$(curl -s ifconfig.me)

while true; do
    given_domain_ip=$(dig +short "$1")

    if [ "$public_ip" != "$given_domain_ip" ]; then
        printf "\n⚠️  ${yellow}$1 is not pointing to this server's IP address (${public_ip}).${reset}\n\nGo make sure the DNS is set up correctly and then come back here, and press 'y' to continue (may take a few minutes to propogate): "
        read dns_setup
    else
        break
    fi
done