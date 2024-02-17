#!/bin/bash

# Check if we have acme.sh installed
if [ ! -f ~/.acme.sh/acme.sh ]; then
    echo "acme.sh not found, installing..."
    curl https://get.acme.sh | sh
    source ~/.bashrc
fi

# Ask for details
read -p "Your email: " email # Email to use for Let's Encrypt account
read -p "Your domains (space separated): " domains # example.com www.example.com
IFS=' ' read -r -a domain_array <<< "$domains" # Convert the space-separated domains into an array
d_args="" # Initialize an empty string to hold the -d arguments
for domain in "${domain_array[@]}"; do # Loop over the array and append -d domain for each one
    d_args+=" -d $domain"
done

# Now we can use $d_args in acme.sh
acme.sh --issue --webroot $webroot $d_args --staging
acme.sh --issue --webroot $webroot $d_args --force

# Setup cPanel hook
acme.sh --deploy --deploy-hook cpanel_uapi --domain $domain