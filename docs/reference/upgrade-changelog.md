# Upgrade Changelog

Version-specific upgrade notes. For the procedure, see [How to upgrade](../how-to/upgrade.md).

## Next release

This entry applies to the docker-mailserver release that ships the mailserver-admin versions below. Neither the release number nor the mailserver-admin version of the last item exists yet: both are placeholders.

### mailserver-admin: domain admins can no longer change what belongs to an admin

Domain admins lose three things they could do before. The rules are in [Protections for admins](user-roles.md#protections-for-admins).

- **Fetchmail accounts of admins** (mailserver-admin 5.23.2): a domain admin can no longer create, edit, delete or reassign them.
- **Aliases on an admin's address** (mailserver-admin 5.23.2): a domain admin can no longer create, edit or delete an alias whose address is an admin's address.
- **Aliases pointing to an admin's address** (mailserver-admin `<version not released yet>`): a domain admin can no longer create, edit or delete an alias whose destination is an admin's address, with or without an address extension.

Nothing is migrated. Existing fetchmail accounts and aliases of these kinds stay as they are and keep working, but domain admins can only read them from now on. An admin has to change or delete them, which includes aliases a domain admin created earlier.

With the default `RECIPIENT_DELIMITER=-`, domain admins are also refused destinations such as `admin-sales@example.com` when `admin@example.com` belongs to an admin.

## v8.1.0

### MCP server

The MCP server is new and on by default, including reading and sending mail, see [How to configure the MCP server](../how-to/configure-mcp-server.md). It only acts for API tokens, which users have to create first, and it answers only for the hostnames in `MCP_ALLOWED_HOSTS`.

Copy the `MCP_*` block from `.env.dist` to `.env` and set `MCP_ALLOWED_HOSTS` to your hostname. To turn it off, set `MCP_ENABLED=false`. New variables are listed in the [environment variables reference](environment-variables.md#mcp-server).

With `MDA_UPSTREAM_PROXY=true`, also point `MDA_IMAPS_ADDRESS` at the proxy. The mail tools are the only user of this address, so existing setups may not set it. Without it, they report that the mailbox is busy.

## v8.0.x to later

### Kubernetes: credentials move from the ConfigMap into a Secret

This only affects deployments that apply the root `kustomization.yaml` (`kubectl apply -k .` from the project root); overlays that reference `deploy/kustomize/` and bring their own ConfigMap and Secret are unaffected.

The root `kustomization.yaml` no longer reads `.env` directly. Run `bin/kubernetes-env.sh` before `kubectl apply -k .`, and again after every change to `.env`.
It splits `.env` into `config/kubernetes/config.env` (ConfigMap `config-env`) and `config/kubernetes/secret.env` (Secret `secret-config-env`).
Without the script, `kubectl apply -k .` fails because `config/kubernetes/config.env` does not exist.

The workloads read both objects through `envFrom`, so they see the same variables as before. Workloads of your own that read one of these keys with `configMapKeyRef` from `config-env` must switch to `secretKeyRef` from `secret-config-env`.

### mailserver-admin: PHP_SESSION\_\* no longer apply

From mailserver-admin 5.20.0, `PHP_SESSION_SAVE_HANDLER` and `PHP_SESSION_SAVE_PATH` no longer affect it, only Roundcube's PHP side. Admin logins are always kept in the Redis of `REDIS_HOST`, `REDIS_PORT` and `REDIS_PASSWORD`, under the same key prefix as PHP's default handler.

- **Default values:** existing logins should stay valid.
- **Custom `PHP_SESSION_*` values:** admin logins kept elsewhere are no longer found, so users should have to log in once after upgrading. Old session data stays where it was and is not migrated.

Both are expected from how the session store changed. No upgrade of a running installation has been tested.

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

### Database TLS

`DB_TLS_VERIFY_CERT` now applies to the MDA as well. Dovecot previously connected to the database without TLS in every configuration. The default `no` keeps that behaviour, so nothing changes unless you opt in.

### PostgreSQL

Settings: [Using PostgreSQL](environment-variables.md#using-postgresql). Switching engines migrates no data, and mixed-case addresses stop resolving, see [Database backends](../explanation/database-backends.md#case-sensitivity).

### Schema creation

The web service creates the schema on both engines. The MySQL bootstrap SQL under `target/db/` is gone, and with it the manual import step for external MySQL databases; that database user now needs DDL privileges instead. Existing installations are unaffected, because the migrations detect the existing schema and skip the baseline.

## v7.4

- **mda:** Dovecot 2.4.2 on an Alpine base image again, superseding the `dovecot/dovecot` base noted under v5.x to v6.0. Configuration was simplified in the same step.

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
