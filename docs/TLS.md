# TLS Certificate Configuration

## Overview

The `docker-mailserver` uses TLS certificates for secure email communication. The system supports both internally generated certificates and external certificates (such as those from Let's Encrypt).

## Certificate Locations

### MDA Service (Dovecot)

The Mail Delivery Agent expects TLS certificates at:

- **Certificate**: `/etc/dovecot/tls/tls.crt`
- **Private Key**: `/etc/dovecot/tls/tls.key`

### MTA Service (Postfix)

The Mail Transfer Agent expects TLS certificates at:

- **Certificate**: `/etc/postfix/tls/tls.crt`
- **Private Key**: `/etc/postfix/tls/tls.key`

## Default Configuration

By default, the services use a shared `data-tls` volume that contains internally generated certificates:

```yaml
# In deploy/compose/mda.yaml
volumes:
  - data-tls:/etc/dovecot/tls:ro

# In deploy/compose/mta.yaml
volumes:
  - data-tls:/etc/postfix/tls:ro
```

## Using External Certificates

### Let's Encrypt Integration

To use certificates from Let's Encrypt or other external sources, you need to mount the certificate files directly into the containers.

#### Step 1: Modify mda.yaml

Edit `deploy/compose/mda.yaml` and replace the `data-tls` volume with direct file mounts:

```yaml
services:
  mda:
    volumes:
      - data-mail:/srv/vmail
      # Remove this line:
      # - data-tls:/etc/dovecot/tls:ro
      # Add these lines instead:
      - /path/to/your/certificate.crt:/etc/dovecot/tls/tls.crt:ro
      - /path/to/your/private.key:/etc/dovecot/tls/tls.key:ro
```

#### Step 2: Modify mta.yaml

Edit `deploy/compose/mta.yaml` and replace the `data-tls` volume with direct file mounts:

```yaml
services:
  mta:
    volumes:
      # Remove this line:
      # - data-tls:/etc/postfix/tls:ro
      # Add these lines instead:
      - /path/to/your/certificate.crt:/etc/postfix/tls/tls.crt:ro
      - /path/to/your/private.key:/etc/postfix/tls/tls.key:ro
```

#### Step 3: Remove SSL Service

Since you're using external certificates, you can remove the SSL service from your deployment:

1. **For Docker Compose**: Remove the `ssl` service from your `docker-compose.yml`
2. **For Kubernetes**: Remove the SSL-related resources from your kustomization

### Example: Let's Encrypt Certificates

If you have Let's Encrypt certificates in `/etc/letsencrypt/live/yourdomain.com/`:

```yaml
# In deploy/compose/mda.yaml
services:
  mda:
    volumes:
      - data-mail:/srv/vmail
      - /etc/letsencrypt/live/yourdomain.com/fullchain.pem:/etc/dovecot/tls/tls.crt:ro
      - /etc/letsencrypt/live/yourdomain.com/privkey.pem:/etc/dovecot/tls/tls.key:ro

# In deploy/compose/mta.yaml
services:
  mta:
    volumes:
      - /etc/letsencrypt/live/yourdomain.com/fullchain.pem:/etc/postfix/tls/tls.crt:ro
      - /etc/letsencrypt/live/yourdomain.com/privkey.pem:/etc/postfix/tls/tls.key:ro
```

## Certificate Requirements

### File Permissions

Ensure your certificate files have appropriate permissions:

- **Certificate files**: Readable by the container user (typically `root` or the service user)
- **Private key files**: Secure permissions (e.g., `600` or `644`)

### Certificate Format

- **Certificate**: PEM format (`.crt`, `.pem`, or `.cert` extensions)
- **Private Key**: PEM format (`.key` or `.pem` extensions)
- **Chain**: Use `fullchain.pem` for Let's Encrypt (includes intermediate certificates)

### Logs

Check service logs for TLS-related errors:

```bash
bin/production.sh logs mda
bin/production.sh logs mta
```
