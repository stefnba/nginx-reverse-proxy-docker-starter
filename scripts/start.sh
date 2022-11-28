#!/bin/bash

##
# Start docker nginx container, loads config and ececutes init-ssh.sh if certbot folder doesn't exist
##

certbot_path="../config/certbot"

cd $(dirname $0)

./load-config.sh "no-reload"

if ! [ -d "$certbot_path" ]; 
    then
        ./init-ssh.sh
    else 
        docker compose up -d nginx
fi
