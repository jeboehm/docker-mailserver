# Relayhost Configuration

## Overview

The `docker-mailserver` MTA service can be configured to relay outgoing emails through another SMTP server. This is useful when you need to send emails through a third-party SMTP provider, corporate mail server, or when your hosting provider blocks direct SMTP connections.

## Configuration

### Environment Variables

Configure the following environment variables in your `.env` file:

```bash
# Relayhost Configuration
RELAYHOST=[mailpit]:1025
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext
```

### Variable Descriptions

- **RELAYHOST**: The SMTP server to relay emails through, in the format `[hostname]:port`
- **RELAY_PASSWD_FILE**: Path to the credentials file containing authentication details

## Credentials File

### File Format

Create a credentials file with the following format:
```
[hostname]:port username:password
```

### Example Credentials File

For a relayhost at `mailpit` on port `1025` with user `user1` and password `password1`:

```
[mailpit]:1025 user1:password1
```

### File Location

The credentials file must be mounted to `/etc/postfix/sasl_passwd_ext` in the MTA container.

## Docker Compose Configuration

### Step 1: Create Credentials File

Create your credentials file locally (e.g., `sasl_passwd`):

```bash
# Create credentials file
echo "[mailpit]:1025 user1:password1" > sasl_passwd

# Set secure permissions
chmod 600 sasl_passwd
```

### Step 2: Mount Credentials File

Edit `deploy/compose/mta.yaml` to mount the credentials file:

```yaml
services:
  mta:
    image: jeboehm/mailserver-mta:latest
    build:
      context: ../../target/mta
      cache_from:
        - type=registry,ref=ghcr.io/jeboehm/mailserver-mta:buildcache
    restart: on-failure:5
    env_file: ../../.env
    volumes:
      - data-tls:/etc/postfix/tls:ro
      # Mount your credentials file
      - ./sasl_passwd:/etc/postfix/sasl_passwd_ext:ro
      # For using external certificates uncomment the following lines
      # and change the path on the left side of the colon.
      # - /home/user/certs/mail.example.com.crt:/etc/postfix/tls.crt:ro
      # - /home/user/certs/mail.example.com.key:/etc/postfix/tls.key:ro
```

### Step 3: Update Environment Variables

Ensure your `.env` file contains:

```bash
RELAYHOST=[mailpit]:1025
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext
```

### Step 4: Restart MTA Service

```bash
# Restart the MTA service to apply changes
docker-compose up -d mta

# Or using the production script
bin/production.sh up -d mta
```

## Common Relayhost Examples

### Gmail SMTP

```bash
# Environment variables
RELAYHOST=[smtp.gmail.com]:587
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext

# Credentials file content
[smtp.gmail.com]:587 your-email@gmail.com:your-app-password
```

### Office 365

```bash
# Environment variables
RELAYHOST=[smtp.office365.com]:587
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext

# Credentials file content
[smtp.office365.com]:587 your-email@yourdomain.com:your-password
```

## Verification

### Test Email Sending

1. **Send a test email** through the webmail interface
2. **Check MTA logs** for successful relay:
   ```bash
   # Docker Compose
   bin/production.sh logs mta

   # Kubernetes
   kubectl logs statefulset/mta -n mail
   ```

3. **Look for successful relay messages** in the logs:
   ```
   postfix/smtp[1234]: 1A2B3C4D5E: to=<recipient@example.com>, relay=mailpit[127.0.0.1]:1025, delay=0.1, delays=0.05/0.01/0.01/0.03, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 1A2B3C4D5E)
   ```
