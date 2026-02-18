# How to Configure TLS Certificates

This guide covers TLS for mail protocols (SMTP, IMAP, POP3) served by the MTA (Postfix) and MDA (Dovecot) containers. To terminate TLS for the web interface (port 81), use a reverse proxy — see [How to configure a reverse proxy](configure-reverse-proxy.md).

By default the mailserver uses a shared `data-tls` volume with internally generated certificates. To use external certificates (e.g. Let's Encrypt), mount certificate and key files into the MTA and MDA containers.

## Certificate locations

- **MDA (Dovecot):** `/etc/dovecot/tls/tls.crt`, `/etc/dovecot/tls/tls.key`
- **MTA (Postfix):** `/etc/postfix/tls/tls.crt`, `/etc/postfix/tls/tls.key`

## Steps (Docker Compose)

### 1. Mount certificates in MDA

In `deploy/compose/mda.yaml`, replace the `data-tls` volume with file mounts:

```yaml
volumes:
  - data-mail:/srv/vmail
  - /path/to/certificate.crt:/etc/dovecot/tls/tls.crt:ro
  - /path/to/private.key:/etc/dovecot/tls/tls.key:ro
```

### 2. Mount certificates in MTA

In `deploy/compose/mta.yaml`, replace the `data-tls` volume with file mounts:

```yaml
volumes:
  - /path/to/certificate.crt:/etc/postfix/tls/tls.crt:ro
  - /path/to/private.key:/etc/postfix/tls/tls.key:ro
```

### 3. Remove or disable the SSL service (optional)

If you no longer need internal certificate generation, remove the SSL service from your compose stack so it does not overwrite or conflict with your certificates.

### 4. Restart MTA and MDA

```bash
bin/production.sh up -d mta mda
```

## Let’s Encrypt example

If certificates are in `/etc/letsencrypt/live/yourdomain.com/`:

```yaml
# mda
- /etc/letsencrypt/live/yourdomain.com/fullchain.pem:/etc/dovecot/tls/tls.crt:ro
- /etc/letsencrypt/live/yourdomain.com/privkey.pem:/etc/dovecot/tls/tls.key:ro

# mta
- /etc/letsencrypt/live/yourdomain.com/fullchain.pem:/etc/postfix/tls/tls.crt:ro
- /etc/letsencrypt/live/yourdomain.com/privkey.pem:/etc/postfix/tls/tls.key:ro
```

Use `fullchain.pem` so the chain is complete.

## Requirements

- **Format:** PEM (`.crt`, `.pem`, `.key`).
- **Permissions:** Certificate and key readable by the container user; key with restricted permissions (e.g. 600).

If TLS errors appear, check paths and permissions and review MTA/MDA logs: `bin/production.sh logs mta`, `bin/production.sh logs mda`.
