# Traefik Reverse Proxy Setup

This example demonstrates how to deploy docker-mailserver with Traefik as a reverse proxy, providing automatic HTTPS with Let's Encrypt certificates.

## Overview

This setup extends the main `docker-compose.yml` and adds:

- **Traefik Reverse Proxy**: Handles HTTP/HTTPS routing and SSL termination
- **Automatic HTTPS**: Let's Encrypt certificates with automatic renewal
- **HTTP to HTTPS Redirect**: Automatic redirection from HTTP to HTTPS

## Configuration Details

### Traefik Configuration

The Traefik service is configured with:

- **Entry Points**: HTTP (80) and HTTPS (443)
- **Let's Encrypt**: Automatic SSL certificate management
- **Docker Provider**: Automatic service discovery
- **Security**: HTTP to HTTPS redirect
- **Logging**: Access logs and debug information

### Web Service

The web service is configured with Traefik labels for:

- **Host Routing**: `mail.example.org`
- **SSL Termination**: Let's Encrypt certificates
