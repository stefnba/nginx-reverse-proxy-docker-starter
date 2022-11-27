#!/bin/bash

##
# Copy relevant files to remote server
##

cd $(dirname $0)

env_file="../../.env"
files=("../..//./docker-compose.yml" "../..//./config/*" "../..//./servers/*" "../..//./scripts/*")

# Read .env file
source $env_file

echo $REMOTE_DIR

# Sync files
for file in "${files[@]}"
do
    rsync $file "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" -v -R -r
    echo "__ DONE __"
    echo ""
done