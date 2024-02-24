#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && { [ -f lib/init ] && source lib/init || echo "Cannot find lib/init" && exit 1; }

bash sh/web/nginx/install.sh

sqlpage_bin="https://github.com/lovasoa/SQLpage/releases/download/v0.18.3/sqlpage-linux.tgz"

# check if SQLPage is installed (and install it if it's not)
if [ ! -f "/bin/sqlpage" ]; then
    sudo curl -s -L -O $sqlpage_bin
    sudo tar -xzf sqlpage-linux.tgz && sudo rm sqlpage-linux.tgz
    sudo mv sqlpage.bin /bin/sqlpage
    sudo chmod 750 /bin/sqlpage
    sudo chown www-data:www-data /bin/sqlpage
fi