# Upgrade Changelog

Version-specific upgrade notes. When upgrading, update manifests in `deploy/compose` and `deploy/kustomize` to match the new version (volumes, configuration). Update `.env` for new or changed environment variables.

## v7.3

Observability features in mailserver-admin. Set:

- `MDA_DOVEADM_ADDRESS`: MDA address for Dovecot API (default: `mda:8080`)
- `DOVEADM_API_KEY`: API key for Dovecot API

Change at least `DOVEADM_API_KEY` from the default.

## v7.1

- **web:** mailserver-admin can generate mobileconfig files for iOS and macOS. Generation uses the same TLS certificate shown to clients. Mount that certificate into the web container to enable generation.

## v6.x to v7.x

- **web:** Image is Alpine-based and uses FrankenPHP instead of PHP-FPM.
- **web:** Roundcube path: `/var/www/html/webmail` → `/opt/roundcube` (symlink at `/var/www/html/webmail` to Roundcube `public_html`).
- **web:** Admin path: `/opt/admin`.
- **web:** Read-only operation supported; configure tmpfs mounts as in `deploy/compose/web.yaml`.

## v5.x to v6.0

- Kubernetes deployment is supported via `kustomization.yaml`. Helm chart deprecated and archived.
- **virus:** Removed. Use [Rspamd antivirus](https://docs.rspamd.com/modules/antivirus/) for antivirus.
- **unbound:** Added as DNS resolver for the filter.
- **filter:** Base image `rspamd/rspamd`; no longer Alpine-based.
- **web:** `CSRF_ENABLED=false` disables CSRF (default: `true`). Rootless: web listens on 8080 internally.

### MTA

- TLS paths: `/etc/postfix/tls/tls.crt`, `/etc/postfix/tls/tls.key`.
- Submission only on port 587.

### MDA

- Base image: `dovecot/dovecot`; no longer Alpine-based.
- TLS paths: `/etc/dovecot/tls/tls.crt`, `/etc/dovecot/tls/tls.key`. No DH file.
- Mail storage: `/srv/vmail` (was `/var/vmail`).
- Rootless: runs as non-root; ensure mail storage and TLS are accessible by UID/GID 1000.
- Internal ports: IMAP 31143, POP3 31110, IMAPS 31993, POP3S 31995 (internal only).
- FTS enabled by default; `FTS_*` variables removed.
- POP3 and IMAP always enabled; `POP3_ENABLED` and `IMAP_ENABLED` removed.
