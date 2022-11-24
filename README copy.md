# Nginx Reverse Proxy with Docker

## Setup Webserver

### Install Docker

Visit the following guide to install Docker on your Linux machine:

https://docs.docker.com/engine/install/ubuntu/

Once Docker is installed,

### Configuration of Firewall

To come.

## Setup Nginx

To come.

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
