# Upgrade Guide

Upgrade guide for docker-mailserver.

Before upgrading, ensure you have updated `docker-compose.yml` and `docker-compose.production.yml` files.

## v6.0

- **virus**: The virus service has been removed. To add antivirus functionality, see the [Rspamd antivirus documentation](https://docs.rspamd.com/modules/antivirus/).
- **unbound**: Added unbound as a DNS resolver for the filter service.
- **web**: Set `CSRF_ENABLED=false` to disable CSRF protection in the web interface (default: `true`).
- **filter**: The base image has been changed to `rspamd/rspamd`. This image is no longer based on Alpine Linux.

### MTA (Mail Transfer Agent)

- **TLS Certificate Paths**: Certificate paths have been updated to `/etc/postfix/tls/tls.crt` and `/etc/postfix/tls/tls.key`.

### MDA (Mail Delivery Agent)

- **Base Image**: Changed to `dovecot/dovecot`. This image is no longer based on Alpine Linux.
- **TLS Certificate Paths**: Updated to `/etc/dovecot/tls/tls.crt` and `/etc/dovecot/tls/tls.key`. A Diffie-Hellman file is no longer required.
- **Mail Storage**: Now mounted to `/srv/vmail` instead of `/var/vmail`.
- **Rootless Operation**: The container now runs as a non-root user. Ensure mail storage and TLS certificates are accessible by `UID 1000` and `GID 1000`.
- **Internal Ports**: IMAP/POP3 internal ports have been updated:
  - IMAP: `31143`
  - POP3: `31110`
  - IMAPS: `31993`
  - POP3S: `31995`

  These ports are only used for connections within the container network.

- **Full Text Search**: Enabled by default. All `FTS_` environment variables have been removed.
- **Protocol Support**: POP3 and IMAP are always enabled. The `POP3_ENABLED` and `IMAP_ENABLED` environment variables have been removed.
