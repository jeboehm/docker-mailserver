# Installation Guide

This guide covers installation procedures for `docker-mailserver` on Docker and Kubernetes platforms.

## Prerequisites

- Docker and Docker Compose (for Docker deployment)
- Kubernetes cluster with kubectl configured (for Kubernetes deployment)
- Domain name with DNS records configured
- Basic understanding of email server administration

## Download

### Option 1: Release Archive

Download the latest release from the [Releases](https://github.com/jeboehm/docker-mailserver/releases) page and unpack the archive (`release-vX.X.X.tar.gz`).

### Option 2: Source Code

For advanced users, clone the repository from GitHub:

```bash
git clone https://github.com/jeboehm/docker-mailserver.git
cd docker-mailserver
```

### Container Image Tags

**Important:** Do not use the `latest` container image tag for production deployments. Always use a specific version tag instead.

- ✅ Use: `jeboehm/mailserver-mta:6.3`
- ❌ Avoid: `jeboehm/mailserver-mta:latest`

## Docker Installation

### Step 1: Configure Environment Variables

1. Copy the example environment file to create your configuration:

```bash
cp .env.dist .env
```

2. Open `.env` in a text editor and configure the variables according to your needs. See [Environment Variables](ENVIRONMENT_VARIABLES.md) for detailed descriptions of all available options.

### Step 2: Download Container Images

Pull the required Docker images:

```bash
bin/production.sh pull
```

### Step 3: Start Services

Start all services in detached mode and wait for them to be ready:

```bash
bin/production.sh up -d --wait
```

This command will:

- Start all required containers
- Wait for health checks to pass
- Ensure services are ready before continuing

### Step 4: Access Services

After a few seconds, the services will be available on the ports listed in the [Ports Overview](#ports-overview) section.

### Step 5: Run Installation Wizard

Execute the setup script to configure the mailserver and create your first account:

```bash
bin/production.sh run --rm web setup.sh
```

The wizard will:

- Ask configuration questions
- Create your first email address
- Create an admin user for the management interface

### Step 6: Access Management Interface

Log in to the management interface using the credentials created during setup:

- Management Interface: `http://127.0.0.1:81/manager/`
- Webmail: `http://127.0.0.1:81/webmail/`

## Kubernetes Installation

Kubernetes deployment requires an existing MySQL-compatible database (MySQL or Percona XtraDB). The provided kustomization does not provision a database.

You can find a complete example configuration for Kubernetes in the [example-configs](https://github.com/jeboehm/docker-mailserver/tree/main/docs/example-configs/kustomize/external-db-and-https-ingress) folder.

### Step 1: Configure Environment Variables to create a ConfigMap

1. Copy the example environment file:

```bash
cp .env.dist .env
```

2. Edit `.env` and configure variables as described in [Environment Variables](ENVIRONMENT_VARIABLES.md).

3. Create Kubernetes secrets for database credentials and other sensitive values before applying manifests.

### Step 2: Create Namespace

Create a dedicated namespace for the mailserver:

```bash
kubectl create namespace mail
```

### Step 3: Generate TLS Certificates

If you are not using a certificate management tool like `cert-manager`, generate self-signed TLS certificates:

```bash
bin/create-tls-certs.sh
```

### Step 4: Create TLS Secret

Create a Kubernetes secret for the TLS certificates:

```bash
kubectl create -n mail secret tls tls-certs \
  --cert=config/tls/tls.crt \
  --key=config/tls/tls.key
```

### Step 5: Apply Kustomize Manifests

Deploy the mailserver using Kustomize:

```bash
kubectl apply -n mail -k .
```

### Step 6: Verify Pod Status

Wait for all pods to be running and healthy:

```bash
kubectl get pods -n mail
```

### Step 7: Run Installation Wizard

Execute the setup script in the web pod's php-fpm container:

```bash
kubectl exec -n mail -it deployment/web -c php-fpm -- setup.sh
```

The wizard will guide you through:

- Initial configuration
- First email address creation
- Admin user setup

### Step 8: Access Management Interface

Access the management interface through your configured ingress using the admin credentials created during setup.

## Ports Overview

The following services are exposed on the specified ports:

| Service                             | Address                      |
| ----------------------------------- | ---------------------------- |
| POP3 (STARTTLS required)            | 127.0.0.1:110                |
| POP3S                               | 127.0.0.1:995                |
| IMAP (STARTTLS required)            | 127.0.0.1:143                |
| IMAPS                               | 127.0.0.1:993                |
| SMTP                                | 127.0.0.1:25                 |
| Mail Submission (STARTTLS required) | 127.0.0.1:587                |
| Management Interface                | http://127.0.0.1:81/manager/ |
| Webmail                             | http://127.0.0.1:81/webmail/ |
| Rspamd web interface                | http://127.0.0.1:81/rspamd/  |

## Post-Installation

After installation, consider:

1. **DNS Configuration**: Ensure proper DNS records (MX, SPF, DKIM, DMARC) are configured for your domain
2. **TLS Certificates**: Replace self-signed certificates with valid certificates from a trusted CA
3. **Firewall Rules**: Configure firewall rules to allow necessary ports
4. **Backup Strategy**: Set up regular backups of persistent volumes
5. **Monitoring**: Configure monitoring and alerting for service health

See the [Configuration](ENVIRONMENT_VARIABLES.md) section for advanced configuration options.

## Troubleshooting

Common issues and solutions:

- **Services not starting**: Check container logs with `docker-compose logs` or `kubectl logs`
- **Database connection errors**: Verify database credentials in `.env` and ensure the database is accessible
- **TLS certificate issues**: Ensure certificates are properly mounted and have correct permissions
- **Port conflicts**: Verify no other services are using the required ports

For additional help, see:

- [Architecture Documentation](ARCHITECTURE.md)
- [Development Guide](DEVELOPMENT.md)
- [GitHub Issues](https://github.com/jeboehm/docker-mailserver/issues)
