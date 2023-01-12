#!/bin/bash
groupadd -g ${PGID} minecraft
useradd -u ${PUID} -g minecraft minecraft

set -e

if [ ! -f /config/config.toml ]; then
    mkdir -p /config
    cp /default/config.toml /config
fi

if [ ! -d /minecraft ]; then
    echo -e "\033[31mError missing minecraft folder!\033[0m"
    exit
fi

chown -R minecraft:minecraft /config
chown -R minecraft:minecraft /minecraft

echo "----------"
echo
echo "Starting with ${RAM} of ram"
echo
echo "----------"

sudo -u minecraft /entrypoint-afterroot.sh ${RAM}