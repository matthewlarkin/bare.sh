#!/usr/bin/env bash

# Check if we have acme.sh installed
if [ ! -f ~/.acme.sh/acme.sh ]; then
    echo "acme.sh not found, installing..."
    curl https://get.acme.sh | sh
    source ~/.bashrc
fi

# Ask for Let's Encrpt details
read -p "Your email: " email
read -p "Your domains (space separated): " domains
IFS=' ' read -r -a domain_array <<< "$domains"
for domain in "${domain_array[@]}"; do
    d_args+=" -d $domain"
done

# Now we can use $d_args in acme.sh
acme.sh --issue --webroot $webroot $d_args --staging
acme.sh --issue --webroot $webroot $d_args --force

# Setup cPanel hook
acme.sh --deploy --deploy-hook cpanel_uapi --domain $domain