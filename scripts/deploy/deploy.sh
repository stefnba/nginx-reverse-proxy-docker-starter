#!/bin/bash

##
# Copy relevant files to remote server
##

files_path="./files.conf"
env_file="../../.env"

cd $(dirname $0)

files=(
    "../..//./docker-compose.yml"
    "../..//./config/nginx.conf"
    "../..//./config/proxy_params.conf"
    "../..//./scripts/ssl/*"
    "../..//./scripts/config/*"
    "../..//./templates/*"
    "../..//./sites/*"
)

# file_list=()

# while IFS= read -r line; do
#     echo $line
#   file_list+=("$line")
# done < $files_path

# echo "${file_list[@]}"

# Read .env file
source $env_file

# echo "${files[@]}"

# Sync files
for file in "${files[@]}"
do
    # echo $file
    rsync $file "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" -v -R -r
done