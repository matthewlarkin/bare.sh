#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../" && source lib/init

printf "\n\n- - - - - - - - - - - - - - - - - - -\n"
printf "\n- - 🌳 SQLPage Deploy 🌳 - - - - - - -\n"
printf "\n- - - - - - - - - - - - - - - - - - -\n\n"

# Collect details about the project from the user
printf "\n- - - 🌿 Project Details 🌿 - - -\n"
printf "- GitHub repo <user/repo>: " && read repo
printf "- Domain name: " && read domain
printf "- Include www (y/n): " && read www_included
printf "- SQLPage port: " && read port

# Validates the given port
while [ -n "$(sudo lsof -i :$port)" ]; do
    printf "${yellow}Port ${port} is already in use!${reset} Please choose another port..."
    printf "SQLPage port: " && read port
done

# Setup repo_name
repo_name=$(echo $repo | cut -d'/' -f2)

# Check if the domain is pointing to the
# server's IP address and sets up /var/www/
public_ip=$(curl -s ifconfig.me)

while true; do
    given_domain_ip=$(dig +short "$domain")

    if [ "$public_ip" != "$given_domain_ip" ]; then
        printf "\n⚠️  ${yellow}$1 is not pointing to this server's IP address (${public_ip}).${reset}\n\nGo make sure the DNS is set up correctly and then come back here, and press 'y' to continue (may take a few minutes to propogate): "
        read dns_setup
    else
        break
    fi
done

# check that /var/www/ exists
if [ ! -d "/var/www" ]; then
    sudo mkdir -p /var/www
fi





# - - - - - - - - - - - - - - -
# - - SSH Key Management - - - -
# - - - - - - - - - - - - - - -

# list available SSH keys
printf "\n- - - 🌿 SSH Keys 🌿 - - -\n"
available_ssh_keys=$(b/ssh -l)

# if there are no SSH keys, create a new one
if [ -z "$available_ssh_keys" ]; then
    printf "\n⚠️ ${yellow}No SSH keys found.${reset}\n"
    b/ssh -n
    printf "\n✅ ${green}SSH key created!${reset}\n"
else
    printf "\n🚜 Use an existing SSH key? (y/n): " && read use_existing_ssh_key
    if [ "$use_existing_ssh_key" = "n" ]; then
        b/ssh -n
        printf "\n✅ ${green}SSH key created!${reset}\n"
    else
        # print the existing public key
        printf "\nYour existing public key is:\n"
        b/ssh -e
    fi
fi

# Check that user has set up SSH key on GitHub
printf "\n- - - 🌿 GitHub SSH Key 🌿 - - -\n"
printf "\nHave you set up the SSH key on GitHub? (y/n): " && read ssh_key_setup

while [ "$ssh_key_setup" != "y" ]; do
    printf "\n⚠️ ${yellow}Please set up the SSH key on GitHub.${reset} Then, press 'y' to continue: " && read ssh_key_setup
done





# - - - - - - - - - - - - - - -
# - - Project Deployment - - - -
# - - - - - - - - - - - - - - -

# Clone the repo into /var/www/
git clone "git@github.com:$repo.git" && sudo mv $repo_name /var/www/


# - - - - - - -
# - - SQLPage config
# - - - - - - -

# Use jq to edit the existing sqlpage.json file. We
# need to make the property "port" equal to the
# port we want to run the service on
# check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
    sudo apt install -y jq
fi

sqlpage_config_dir="/var/www/$repo_name/sqlpage"
sqlpage_config_file="$sqlpage_config_dir/sqlpage.json"
sudo mkdir -p "$sqlpage_config_dir"

# Check if the file exists and contains valid JSON
if sudo test -s "$sqlpage_config_file" && sudo jq empty "$sqlpage_config_file" >/dev/null 2>&1; then
    # File exists and contains valid JSON, modify it
    temp_file=$(mktemp)
    sudo jq ".port = \"$port\" | .environment = \"production\"" "$sqlpage_config_file" > "$temp_file" && sudo mv "$temp_file" "$sqlpage_config_file"
else
    # File does not exist or does not contain valid JSON, create it
    echo "{\"port\": \"$port\", \"environment\": \"production\"}" | sudo tee "$sqlpage_config_file" > /dev/null
fi

# setup the sqlpage service for this repo
sudo touch /etc/systemd/system/sqlpage-$repo_name.service
sudo tee /etc/systemd/system/sqlpage-$repo_name.service > /dev/null <<EOT
[Unit]
Description=SQLPage Service for $domain
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/$repo_name
ExecStart=/usr/bin/sqlpage
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT

# Start the SQLPage service and enable it to start on server boot
sudo systemctl daemon-reload
sudo systemctl start sqlpage-$repo_name
sudo systemctl enable sqlpage-$repo_name

# Create the nginx config file
sudo touch /etc/nginx/sites-available/$repo_name

# write the nginx config file that will reverse proxy to the sqlpage service and redirect traffic to https
sudo tee /etc/nginx/sites-available/$repo_name > /dev/null <<EOT
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://127.0.0.1:$port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOT
sudo ln -s /etc/nginx/sites-available/$repo_name /etc/nginx/sites-enabled/$repo_name


# - - - - - - -
# - - SSL Cert Setup
# - - - - - - -

# setup certbot for the domain
if ! [ -x "$(command -v certbot)" ]; then
    sudo apt install -y certbot python3-certbot-nginx
fi
sudo certbot --nginx -d $domain

# restart nginx and the sqlpage service
sudo systemctl restart nginx
sudo systemctl restart sqlpage-$repo_name




# - - - - - - -
# - - Fine 🤌
# - - - - - - -

printf "\n\n🚀 ${GREEN}SQLPage is now running at https://$domain!${RESET}\n\n"
printf "\n\nIf everything went well, we should be able to visit https://$domain\n
and see the SQLPage website! You may want to check the status of the SQLPage\n
service by running 'sudo systemctl status sqlpage-$repo_name' and the nginx service\n
by running 'sudo systemctl status nginx'. And make sure you've set up the SQLPage\n
configuration file at /var/www/$repo_name/sqlpage/sqlpage.json.\n\n"