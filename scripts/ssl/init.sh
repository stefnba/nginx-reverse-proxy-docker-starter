#!/bin/bash

rsa_key_size=4096
certbot_path="../../config/certbot" # certbot conf dir on host
sites_path="../../sites/" # folder where user should place config files for upstream services
new_domains_path="./_domains/" # temporary folder for domains that require new certificates; destination for copying for conf files from sites_path

staging=1 # Set to 1 for testing to avoid hitting request limits

cd $(dirname $0)

# Check if certificate already exists & copy config files to temporary dir new_domains_path
check_existing_certificate () {
    if [ -d "$certbot_path/conf/live/$1" ]; then
        read -p "Existing certificates folder for doamin $1 found. Do you want to continue and replace existing certificates? (Y/N): " decision
        if [ "$decision" == "Y" ] || [ "$decision" == "y" ]; then
            copy_domain_config $2
        fi
    else
        copy_domain_config $2
    fi
}

# Copy config files to temporary dir new_domains_path
copy_domain_config () {
    cp $1 "$new_domains_path/$(basename -- ${1})"
}

# Download TLS params to maintain best-practice HTTPS configurations for nginx
download_tls_parameters () {
    if [ ! -e "$certbot_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$certbot_path/conf/ssl-dhparams.pem" ]; then
        echo "### Downloading recommended TLS parameters ###"
        mkdir -p "$certbot_path/conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$certbot_path/conf/options-ssl-nginx.conf"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$certbot_path/conf/ssl-dhparams.pem"
        echo
    fi
}

# Create dummy certificate which is necessary for nginx to start up
create_dummy_certificate () {
    echo "### Creating dummy certificate for $1 ###"
    path="/etc/letsencrypt/live/$1"
    mkdir -p "$certbot_path/conf/live/$1"
    docker compose run --rm --entrypoint "\
        openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
}

delete_dummy_certificate() {
    echo "### Deleting dummy certificate for $1 ###"

    docker compose run --rm --entrypoint "\
        rm -Rf /etc/letsencrypt/live/$1 && \
        rm -Rf /etc/letsencrypt/archive/$1 && \
        rm -Rf /etc/letsencrypt/renewal/$1.conf" certbot
}

# Only register main domain of domain list, should be domain w/o www. prefix
register_certificate() {
    echo "### Requesting Let's Encrypt certificate for $1 ###"

    # Enable staging mode if needed
    if [ $staging != "0" ]; then staging_arg="--staging"; fi

    rm -rf "$certbot_path/conf/live/$1" \
    rm -rf "$certbot_path/conf/archive/$1" \
    rm -rf "$certbot_path/conf/renewal/$1.conf"

    docker compose run --rm --entrypoint "\
        certbot certonly --webroot -w /var/www/certbot \
        -d $1 \
        --rsa-key-size $rsa_key_size \
        --agree-tos \
        --email $2\
        $staging_arg \
        --force-renewal" certbot
}


# create certbot folder on host
mkdir -p $certbot_path
# create temporary dir for new domains
mkdir -p $new_domains_path

# download TLS parameters from GitHub
download_tls_parameters

# Iterate over all configured domains in /sites folder and 
# select new or existing domains for which certificate should be generated
for file in "$sites_path"/*
do
    # open domain config file
    . $file # open file
    # get first element of domain list
    main_domain=${domain%%' '*} 
    # check if exists already
    check_existing_certificate $main_domain $file
done

# Iterate over _domains dir
for domain_file in "$new_domains_path"/*
do
    # open domain config file
    . $domain_file # open file
    # get first element of domain list
    main_domain=${domain%%' '*} 
    # create dummy
    create_dummy_certificate $main_domain
done

# Start Nginx with dummy certificates
echo "### Starting Nginx service ###"
docker compose up --force-recreate -d nginx

# Change ownership of certbot folder
sudo chown -R $(id -u):$(id -g) $certbot_path

# Iterate over all configured domains and delete dummy certificate
for domain_file in "$new_domains_path"/*
do
    . $domain_file # open file
    delete_dummy_certificate $domain
    main_domain=${domain%%' '*} # get first element of domain list
    register_certificate $main_domain $email
done

# Delete temporary domains dir
rm -rf $new_domains_path

read -p "Do you want to reload Docker? (Y/N) " decision

if [ "$decision" == "Y" ] || [ "$decision" == "y" ]; then
    echo "### Reloading Nginx ###"
    docker compose exec nginx nginx -s reload
fi