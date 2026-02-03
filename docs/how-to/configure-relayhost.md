# How to Configure a Relay Host

To send outgoing mail through another SMTP server (e.g. a provider or corporate server), configure a relay host.

## Steps

### 1. Create credentials file

Create a file (e.g. `sasl_passwd`) with:

```text
hostname username:password
```

Example for relay at `mailpit` on port 1025:

```text
mailpit user1:password1
```

Set secure permissions:

```bash
chmod 600 sasl_passwd
```

### 2. Mount the file into the MTA container

In `deploy/compose/mta.yaml` (or your compose override), add a volume for the credentials file:

```yaml
volumes:
  - data-tls:/etc/postfix/tls:ro
  - ./sasl_passwd:/etc/postfix/sasl_passwd_ext:ro
```

Use the path where the MTA expects it (e.g. `/etc/postfix/sasl_passwd_ext`).

### 3. Set environment variables

In `.env`:

```bash
RELAYHOST=[hostname]:port
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext
```

Example for Gmail:

```bash
RELAYHOST=[smtp.gmail.com]:587
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext
```

Credentials file content for Gmail (use an app password):

```text
smtp.gmail.com your-email@gmail.com:your-app-password
```

Example for Office 365:

```bash
RELAYHOST=[smtp.office365.com]:587
RELAY_PASSWD_FILE=/etc/postfix/sasl_passwd_ext
```

```text
smtp.office365.com your-email@yourdomain.com:your-password
```

### 4. Restart the MTA

```bash
bin/production.sh up -d mta
```

(or `docker-compose up -d mta`).

## Verification

Send a test message via webmail and check MTA logs for successful relay (e.g. `status=sent`).

For reference, see [Environment variables reference](../reference/environment-variables.md) (Relay section).
