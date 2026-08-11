# Environment Variables Reference

Overview of environment variables used to configure docker-mailserver. Set these in your `.env` file or in the environment.

## Basic Configuration

### Database

When using the database service provided by docker-mailserver compose, you do not need to set host, port, or database name. You must set `DB_PASSWORD`.

| Variable             | Default                              | Description                         |
| -------------------- | ------------------------------------ | ----------------------------------- |
| `DB_DRIVER`          | `mysql`                              | Database engine, `mysql` or `pgsql` |
| `DB_HOST`            | `db`                                 | Database hostname                   |
| `DB_PORT`            | `3306`                               | Database port                       |
| `DB_NAME`            | `mailserver`                         | Database name                       |
| `DB_USER`            | `root` (MTA/MDA), `mailserver` (Web) | Database username                   |
| `DB_PASSWORD`        | _(empty)_                            | Database password                   |
| `DB_SERVER_VERSION`  | `8.4`                                | Server version reported to Doctrine |
| `DB_TLS_VERIFY_CERT` | `no`                                 | TLS to the database, `mysql` only   |

The `DB_USER` defaults above are the image defaults, which a Kubernetes deployment gets when it does
not set the variable. Every compose service overrides it to `mailserver`.

`DB_SERVER_VERSION` has to match the server, because Doctrine cannot detect the PostgreSQL
version by itself in this image. Use the major version, for example `18`.

`DB_TLS_VERIFY_CERT` applies to the MTA and the MDA, and only with `DB_DRIVER=mysql`. The two
services interpret it slightly differently, because Postfix and Dovecot expose different settings:

| Value | MTA (Postfix)                              | MDA (Dovecot)                             |
| ----- | ------------------------------------------ | ----------------------------------------- |
| `no`  | TLS if the server offers it, no validation | no TLS                                    |
| `yes` | TLS with certificate validation            | TLS required, with certificate validation |

Certificates are validated against the system trust store, so `yes` requires a database certificate
signed by a public CA. The bundled database container ships a self-signed certificate and fails
validation.

PostgreSQL has no equivalent setting. Dovecot connects with `sslmode=prefer`; Postfix leaves the
mode unset and uses the libpq default.

These variables configure the bundled database container only:

| Variable           | Default     | Description                             |
| ------------------ | ----------- | --------------------------------------- |
| `DB_IMAGE`         | `mysql:lts` | Image of the bundled database container |
| `DB_DATA_DIR`      | _(engine)_  | Data directory inside that container    |
| `DB_ROOT_PASSWORD` | _(empty)_   | Superuser password of that container    |

#### Using PostgreSQL

```bash
DB_DRIVER=pgsql
DB_PORT=5432
DB_SERVER_VERSION=18
# only when using the bundled database container
DB_IMAGE=postgres:18-alpine
DB_DATA_DIR=/var/lib/postgresql
```

Switching engines does not migrate any data. Run `make clean` first when using the bundled
container: PostgreSQL refuses to initialise into a data directory that is not empty.

#### Renamed From MYSQL\_\*

The database variables were renamed from `MYSQL_*` to `DB_*`. Docker Compose deployments keep
working with the old names, which are used as a fallback.

| Old name                | New name             |
| ----------------------- | -------------------- |
| `MYSQL_HOST`            | `DB_HOST`            |
| `MYSQL_PORT`            | `DB_PORT`            |
| `MYSQL_DATABASE`        | `DB_NAME`            |
| `MYSQL_USER`            | `DB_USER`            |
| `MYSQL_PASSWORD`        | `DB_PASSWORD`        |
| `MYSQL_TLS_VERIFY_CERT` | `DB_TLS_VERIFY_CERT` |
| `MYSQL_ROOT_PASSWORD`   | `DB_ROOT_PASSWORD`   |

Kubernetes deployments have no such fallback, because the variables reach the containers straight
from the generated ConfigMap. Rename them in your `.env` before applying the manifests.

### Mail Server Identity

| Variable              | Default                  | Description                                                       |
| --------------------- | ------------------------ | ----------------------------------------------------------------- |
| `MAILNAME`            | `mail.example.com`       | Primary mail server hostname                                      |
| `POSTMASTER`          | `postmaster@example.com` | Postmaster email address                                          |
| `RECIPIENT_DELIMITER` | `-`                      | Character used for address extensions (e.g., user-tag@domain.com) |
| `MYNETWORKS`          | `127.0.0.0/8`            | Networks Postfix relays for without authentication                |

### Redis

When using the Redis service provided by docker-mailserver compose or kustomize, you do not need to configure host or port. You must set `REDIS_PASSWORD`.

| Variable         | Default      | Description           |
| ---------------- | ------------ | --------------------- |
| `REDIS_HOST`     | `redis`      | Redis server hostname |
| `REDIS_PORT`     | `6379`       | Redis server port     |
| `REDIS_PASSWORD` | _(required)_ | Redis server password |

### Authentication

| Variable              | Default      | Description                           |
| --------------------- | ------------ | ------------------------------------- |
| `CONTROLLER_PASSWORD` | _(required)_ | Password for RSpamd controller access |
| `DOVEADM_API_KEY`     | _(required)_ | API key for Dovecot API access        |

### Relay

Set `RELAYHOST` to `[hostname]:port` to route all outgoing mail through an external SMTP server. Leave unset to deliver directly.

| Variable            | Default      | Description                                                       |
| ------------------- | ------------ | ----------------------------------------------------------------- |
| `RELAYHOST`         | _(disabled)_ | SMTP relay host for outgoing mail (e.g. `[smtp.example.com]:587`) |
| `RELAY_PASSWD_FILE` | _(disabled)_ | Path to relay authentication file (inside the MTA container)      |

### Filter

| Variable      | Default      | Description                  |
| ------------- | ------------ | ---------------------------- |
| `FILTER_MIME` | _(disabled)_ | Enable MIME header filtering |

### Fetchmail

| Variable             | Default      | Description                                 |
| -------------------- | ------------ | ------------------------------------------- |
| `FETCHMAIL_INTERVAL` | _(required)_ | Seconds between polls of external mailboxes |

The fetchmail service passes this value straight to `fetchmail --interval` and has no fallback, so it must be set. `.env.dist` ships `300`.

### Startup

| Variable            | Default   | Description                                                     |
| ------------------- | --------- | --------------------------------------------------------------- |
| `WAITSTART_TIMEOUT` | `1m`      | How long the MTA and web containers wait for their dependencies |
| `SKIP_INIT`         | _(unset)_ | Skip database provisioning in the web container                 |

`.env.dist` ships `WAITSTART_TIMEOUT=2m`. The Kubernetes web Deployment sets `SKIP_INIT=true`, because an init container performs the provisioning instead.

### TLS Certificate Generation

These configure the `ssl` container, which generates a self-signed certificate when none is mounted.

| Variable                       | Description                              |
| ------------------------------ | ---------------------------------------- |
| `SSL_CERT`                     | Path of the generated certificate        |
| `SSL_KEY`                      | Path of the generated private key        |
| `SSL_CSR`                      | Path of the certificate signing request  |
| `SSL_SUBJ_COUNTRY`             | Certificate subject: country             |
| `SSL_SUBJ_STATE`               | Certificate subject: state               |
| `SSL_SUBJ_LOCALITY`            | Certificate subject: locality            |
| `SSL_SUBJ_ORGANIZATION`        | Certificate subject: organization        |
| `SSL_SUBJ_ORGANIZATIONAL_UNIT` | Certificate subject: organizational unit |

## Extended Configuration

### Service Addresses

| Variable                      | Default                    | Description                             |
| ----------------------------- | -------------------------- | --------------------------------------- |
| `FILTER_MILTER_ADDRESS`       | `filter:11332`             | RSpamd milter service address           |
| `FILTER_WEB_ADDRESS`          | `filter:11334`             | RSpamd web interface address            |
| `MDA_AUTH_ADDRESS`            | `mda:2004`                 | Dovecot authentication service address  |
| `MDA_IMAP_ADDRESS`            | `mda:31143`                | Dovecot IMAP service address            |
| `MDA_IMAPS_ADDRESS`           | _(unset)_                  | Dovecot IMAPS service address           |
| `MDA_POP3_ADDRESS`            | _(unset)_                  | Dovecot POP3 service address            |
| `MDA_POP3S_ADDRESS`           | _(unset)_                  | Dovecot POP3S service address           |
| `MDA_LMTP_ADDRESS`            | `mda:2003`                 | Dovecot LMTP service address            |
| `MDA_MANAGESIEVE_ADDRESS`     | `mda:4190`                 | Dovecot ManageSieve service address     |
| `MDA_DOVEADM_ADDRESS`         | `mda:8080`                 | Dovecot API address                     |
| `MTA_HOST`                    | `mta`                      | Postfix MTA hostname                    |
| `MTA_SMTP_ADDRESS`            | `mta:25`                   | Postfix SMTP service address            |
| `MTA_SMTP_SUBMISSION_ADDRESS` | `mta:587`                  | Postfix SMTP submission service address |
| `WEB_HTTP_ADDRESS`            | _(unset)_                  | Web interface HTTP address              |
| `UNBOUND_DNS_ADDRESS`         | _(unset)_                  | Unbound resolver address                |
| `RSPAMD_DNS_SERVERS`          | `round-robin:unbound:5353` | DNS servers for Rspamd                  |

The defaults above are the image defaults, which apply to Docker Compose. Kubernetes deployments
override several of them in `deploy/kustomize/common/configmap.yaml`, because the Services publish
different ports than the containers listen on: `MDA_IMAP_ADDRESS` becomes `mda:143`,
`WEB_HTTP_ADDRESS` becomes `web:80`, and `RSPAMD_DNS_SERVERS` becomes `round-robin:unbound:53`. See
[Ports reference](ports.md).

### mailserver-admin

See [mailserver-admin configuration reference](mailserver-admin-config.md).

### PHP Sessions

| Variable                   | Default                                                    | Description          |
| -------------------------- | ---------------------------------------------------------- | -------------------- |
| `PHP_SESSION_SAVE_HANDLER` | `redis`                                                    | Session save handler |
| `PHP_SESSION_SAVE_PATH`    | `tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}` | Session save path    |

### Proxy Protocol

| Variable             | Default   | Description                                                                  |
| -------------------- | --------- | ---------------------------------------------------------------------------- |
| `MDA_UPSTREAM_PROXY` | `no`      | Enable Traefik / HAProxy PROXY protocol for MDA (Dovecot) IMAP/POP3 services |
| `MTA_UPSTREAM_PROXY` | _(unset)_ | Enable Traefik / HAProxy PROXY protocol for MTA (Postfix) SMTP services      |
| `TRUSTED_PROXIES`    | _(unset)_ | Networks allowed to send PROXY protocol headers                              |

When set to `true`, the mail server accepts the HAProxy PROXY protocol to receive the original client IP when behind a load balancer or reverse proxy.

`TRUSTED_PROXIES` sets Dovecot's `haproxy_trusted_networks`. Without it, Dovecot rejects PROXY protocol connections even when `MDA_UPSTREAM_PROXY` is enabled. The same variable configures trusted proxies in mailserver-admin, see [mailserver-admin configuration reference](mailserver-admin-config.md).
