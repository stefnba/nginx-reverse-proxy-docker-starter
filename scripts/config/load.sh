#!/bin/bash

##
# Loads config files in /sites dir into /config/sites which are then loaded into Nginx container.
# Script should be run every time config files changes
##

template_path="../../templates"
sites_path="../../sites"
output_path="../../config/sites"

cd $(dirname $0)

mkdir -p $output_path

for site in "$sites_path"/*
do
    . $site # open file
    main_domain=${domain%%' '*} # get first element of domain list

    export main_domain=$main_domain
    export domain=$domain
    export service=$service

    name="$(basename $site)"

    # echo "$site ${$name%.*}"

    if [ "$https" == 'true' ]; 
        then
            cat "$template_path/https.conf" | envsubst > "$output_path/$(basename $site).nginx"
        else
            cat "$template_path/http.conf" | envsubst > "$output_path/$(basename $site).nginx"
    fi
done

mkdir -p "../../logs"

read -p "Do you want to reload Docker? (Y/N) " decision

if [ "$decision" == "Y" ] || [ "$decision" == "y" ]; then
    echo "### Reloading Nginx ###"
    docker compose exec nginx nginx -s reload
fi


