# External Database and HTTPS Ingress Example

This example demonstrates how to deploy the docker-mailserver in Kubernetes with an external MySQL database and HTTPS ingress configuration. This setup is ideal for production environments where you want to use an existing database infrastructure and provide secure web access to the mail administration interface.

## Overview

This configuration extends the base docker-mailserver kustomization with:

- **External MySQL Database**: Uses an existing MySQL/Percona XtraDB Cluster instead of the built-in database
- **HTTPS Ingress**: Provides secure web access to the mail administration interface with automatic TLS certificate management
- **LoadBalancer Services**: Exposes SMTP/IMAP services through LoadBalancer services for external access
- **OAuth Integration**: Configures OAuth2/OIDC authentication for enhanced security
- **Varying storage classes**: Uses Longhorn storage class for persistent volumes

## Configuration Files

### `kustomization.yaml`

The main kustomization file that:

- Sets the namespace to `mail`
- References the base docker-mailserver kustomization from GitHub
- Includes all custom resources and patches
- Configures Longhorn storage class for persistent volumes

### `namespace.yaml`

Creates the `mail` namespace with pod security policies set to baseline level for enhanced security.

### `config.yaml`

ConfigMap containing environment variables for:

- **Database Configuration**: External MySQL connection details
- **OAuth Settings**: OIDC authentication configuration
- **Mail Settings**: Domain, postmaster, and delimiter configuration
- **Security**: HTTPS enforcement and trusted proxy settings

### `secret.yaml`

OnePassword integration for secure secret management. This example uses OnePassword operator to fetch secrets from a vault.

### `service.yaml`

Defines LoadBalancer services for:

- **MTA Service**: Exposes SMTP (port 25) and submission (port 587)
- **MDA Service**: Exposes IMAP (port 143)
- **External DNS**: Automatic DNS record management

### `ingress.yaml`

NGINX ingress configuration for:

- **HTTPS Termination**: Automatic TLS certificate management via cert-manager
- **Web Interface**: Routes traffic to the web service
- **Multiple Domains**: Supports multiple hostnames for different services
