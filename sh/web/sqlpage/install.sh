#!/bin/bash

bash web/nginx/install.sh

sqlpage_bin="https://github.com/lovasoa/SQLpage/releases/download/v0.18.3/sqlpage-linux.tgz"

# check if SQLPage is installed (and install it if it's not)
if [ ! -f "/usr/bin/sqlpage" ]; then
    sudo curl -s -L -O $sqlpage_bin
    sudo tar -xzf sqlpage-linux.tgz && sudo rm sqlpage-linux.tgz
    sudo mv sqlpage.bin /usr/bin/sqlpage
    sudo chmod 750 /usr/bin/sqlpage
    sudo chown www-data:www-data /usr/bin/sqlpage
fi