# Traefik Reverse Proxy Setup

This example demonstrates how to deploy docker-mailserver with Traefik as a reverse proxy.

## Configuration Details

1. Copy the `compose.yaml` file to your project's root folder with the name `docker-compose.override.yml`.
2. Update the `Host(`mail.example.org`)` in the `docker-compose.override.yml` file to the domain you want to use for your mail server web interface.
3. Run `bin/production.sh up -d` to start the services.

[compose.yaml](./compose.yaml)
