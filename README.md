# Nginx Reverse Proxy with Docker

This containierized Nginx reverse proxy can be deployed on a remote webserver, e.g. DigitalOcean. 

# Getting started

## Setup Webserver

### Install Docker

Visit the following guide to install Docker on your Linux machine:

https://docs.docker.com/engine/install/ubuntu/

Once Docker is installed,

### Configuration of Firewall on the Webserver

To come.

## Configuration of Nginx

The config `/config/nginx.conf` will be loaded as the main `nginx.conf` for Nginx when starting the Docker container. It contains all the necessary configuration. 

### Configuration of Reverse Proxy

The folder `/servers` contains all upstream servers of the reverse proxy. All files with the extension `.nginx` will be loaded by Nginx as configuration files. 

## SSL Encryption with Let's Encrypt and Certbot

Let's Encrypt provides free certificates for TLS encryption which are valid for 90 days and can be renewed. Both initial creation and renewal can be automated using Certbot.

#### Configuration without SSL
```
server {
    listen 80;
    listen [::]:80;

    server_name localhost; # Change this to domain for which traffic is to be redirected

    location / {
        # Workaround with set $target to avoid error when upstream service is not yet running
        set $target http://app:8000; # change this to respective container hostname and port
        resolver 127.0.0.11;
        proxy_pass $target; 

        include proxy_params;

        access_log /var/log/nginx/site-1.access.log logger-json;
        error_log /var/log/nginx/site-1.error.log;
  }
}
```

#### Configuration with SSL

It is highly recommended to generate SSL certificates to encrypt the traffic to and from the server.

## Setup Applications

To come.

## Setup Docker

`Docker-compose.yml` of Reverse Proxy:

```yml
services:
    nginx:
        networks:
            - reverse-proxy-network
networks:
    reverse-proxy-network:
        name: reverse-proxy-network
```

`Docker-compose.yml` of App Project:

```yml
services:
    app:
        networks:
            - default
            - reverse-proxy-network
    db:
        networks:
            - default
networks:
  reverse-proxy-network:
    external: true
```

## Deployment to Webserver

### Docker Context

The following commands create a new context with ssh and activate that context.

```bash
docker context create remote --docker "host=ssh://user@host"
docker context use remote
```

Once the context has been activated, you can run the compose command.

```bash
docker compose up -d
```

### Docker Host

```bash
DOCKER_HOST=“ssh://user@remotehost” docker-compose up -d
```
