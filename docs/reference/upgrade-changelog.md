# Upgrade Changelog

Version-specific upgrade notes. When upgrading, update manifests in `deploy/compose` and `deploy/kustomize` to match the new version (volumes, configuration). Update `.env` for new or changed environment variables.

## v7.x to v8.0

All database environment variables were renamed from `MYSQL_*` to `DB_*`, and PostgreSQL can be used instead of MySQL.

### Renamed variables

| Old name                | New name             |
| ----------------------- | -------------------- |
| `MYSQL_HOST`            | `DB_HOST`            |
| `MYSQL_PORT`            | `DB_PORT`            |
| `MYSQL_DATABASE`        | `DB_NAME`            |
| `MYSQL_USER`            | `DB_USER`            |
| `MYSQL_PASSWORD`        | `DB_PASSWORD`        |
| `MYSQL_TLS_VERIFY_CERT` | `DB_TLS_VERIFY_CERT` |
| `MYSQL_ROOT_PASSWORD`   | `DB_ROOT_PASSWORD`   |

New variables: `DB_DRIVER` (`mysql` or `pgsql`, default `mysql`) and `DB_SERVER_VERSION` (default `8.4`). `DB_IMAGE` and `DB_DATA_DIR` apply to the bundled database container only.

### Docker Compose

The old names keep working. The compose files in `deploy/compose/` map them onto the new ones:

```yaml
DB_HOST: ${DB_HOST:-${MYSQL_HOST:-db}}
```

This fallback is transitional and will be removed. Rename the variables in `.env`. Note that `${VAR:-…}` treats unset and empty alike: an empty `DB_PASSWORD=` falls through to `MYSQL_PASSWORD`.

### Kubernetes

**Kubernetes deployments have no fallback.** The variables reach the containers straight from the `config-env` ConfigMap and the `secret-config-env` Secret via `envFrom`; nothing maps the old names. Rename the keys before applying the manifests:

- ConfigMap `config-env`: `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_DATABASE`, `MYSQL_USER`
- Secret `secret-config-env`: `MYSQL_PASSWORD`
- `MYSQL_TLS_VERIFY_CERT`, wherever it is set

Old keys do not fail loudly. The containers fall back to their image defaults (`DB_HOST=db`, `DB_USER=root`, `DB_NAME=mailserver`, empty password) and try to reach a host named `db`, which does not exist in a Kustomize deployment. See `docs/example-configs/kustomize/external-db-and-https-ingress/` for updated examples.

### PostgreSQL

Set `DB_DRIVER=pgsql`, `DB_PORT=5432`, and `DB_SERVER_VERSION` to the server major version. `DB_SERVER_VERSION` is required, because Doctrine cannot detect it in this image. `DB_TLS_VERIFY_CERT` has no PostgreSQL counterpart.

Switching engines migrates no data. Lookups are now wrapped in `lower()`, so existing mixed-case domains, mailboxes, and aliases resolve on MySQL but not on PostgreSQL.

See [Database backends](../explanation/database-backends.md) and the [environment variables reference](environment-variables.md).

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
