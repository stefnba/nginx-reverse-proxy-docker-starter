#!/bin/bash

##
# Copy relevant files to remote server
##

env_file="../.env"

cd $(dirname $0)

files=(
    "..//./docker-compose.yml"
    "..//./config/nginx.conf"
    "..//./config/proxy_params.conf"
    "..//./scripts/*"
    "..//./templates/*"
    "..//./sites/*"
)

# Read .env file
source $env_file


# Sync files
for file in "${files[@]}"
do
    # echo $file
    rsync $file "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" -v -R -r
done