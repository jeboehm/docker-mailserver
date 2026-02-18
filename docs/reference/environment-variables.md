# Environment Variables Reference

Overview of environment variables used to configure docker-mailserver. Set these in your `.env` file or in the environment.

## Basic Configuration

### Database

When using the MySQL service provided by docker-mailserver compose, you do not need to set host, port, or database. You must set `MYSQL_PASSWORD`.

| Variable                | Default                              | Description                        |
| ----------------------- | ------------------------------------ | ---------------------------------- |
| `MYSQL_HOST`            | `db`                                 | MySQL database hostname            |
| `MYSQL_PORT`            | `3306`                               | MySQL database port                |
| `MYSQL_DATABASE`        | `mailserver`                         | MySQL database name                |
| `MYSQL_USER`            | `root` (MTA/MDA), `mailserver` (Web) | MySQL database username            |
| `MYSQL_PASSWORD`        | _(empty)_                            | MySQL database password            |
| `MYSQL_TLS_VERIFY_CERT` | `no`                                 | MySQL TLS certificate verification |

### Mail Server Identity

| Variable              | Default                  | Description                                                       |
| --------------------- | ------------------------ | ----------------------------------------------------------------- |
| `MAILNAME`            | `mail.example.com`       | Primary mail server hostname                                      |
| `POSTMASTER`          | `postmaster@example.com` | Postmaster email address                                          |
| `RECIPIENT_DELIMITER` | `-`                      | Character used for address extensions (e.g., user+tag@domain.com) |

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

| Variable            | Default        | Description                       |
| ------------------- | -------------- | --------------------------------- |
| `RELAYHOST`         | _(disabled)_   | SMTP relay host for outgoing mail (e.g. `[smtp.example.com]:587`) |
| `RELAY_PASSWD_FILE` | _(disabled)_   | Path to relay authentication file (inside the MTA container) |

### Filter

| Variable      | Default      | Description                  |
| ------------- | ------------ | ---------------------------- |
| `FILTER_MIME` | _(disabled)_ | Enable MIME header filtering |

## Extended Configuration

### Service Addresses

| Variable                      | Default                  | Description                             |
| ----------------------------- | ------------------------ | --------------------------------------- |
| `FILTER_MILTER_ADDRESS`       | `filter:11332`           | RSpamd milter service address           |
| `FILTER_WEB_ADDRESS`          | `filter:11334`           | RSpamd web interface address            |
| `MDA_AUTH_ADDRESS`            | `mda:2004`               | Dovecot authentication service address  |
| `MDA_IMAP_ADDRESS`            | `mda:143`                | Dovecot IMAP service address            |
| `MDA_LMTP_ADDRESS`            | `mda:2003`               | Dovecot LMTP service address            |
| `MDA_MANAGESIEVE_ADDRESS`     | `mda:4190`               | Dovecot ManageSieve service address     |
| `MDA_DOVEADM_ADDRESS`         | `mda:8080`               | Dovecot API address (default: mda:8080) |
| `MTA_HOST`                    | `mta`                    | Postfix MTA hostname                    |
| `MTA_SMTP_ADDRESS`            | `mta:25`                 | Postfix SMTP service address            |
| `MTA_SMTP_SUBMISSION_ADDRESS` | `mta:587`                | Postfix SMTP submission service address |
| `WEB_HTTP_ADDRESS`            | `web:80`                 | Web interface HTTP address              |
| `RSPAMD_DNS_SERVERS`          | `round-robin:unbound:53` | DNS servers for RSpamd (Kubernetes)     |

### mailserver-admin

See [mailserver-admin configuration reference](mailserver-admin-config.md).

### PHP Sessions

| Variable                   | Default                                                    | Description          |
| -------------------------- | ---------------------------------------------------------- | -------------------- |
| `PHP_SESSION_SAVE_HANDLER` | `redis`                                                    | Session save handler |
| `PHP_SESSION_SAVE_PATH`    | `tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}` | Session save path    |

### Proxy Protocol

| Variable             | Default | Description                                                                  |
| -------------------- | ------- | ---------------------------------------------------------------------------- |
| `MDA_UPSTREAM_PROXY` | `false` | Enable Traefik / HAProxy PROXY protocol for MDA (Dovecot) IMAP/POP3 services |
| `MTA_UPSTREAM_PROXY` | `false` | Enable Traefik / HAProxy PROXY protocol for MTA (Postfix) SMTP services      |

When set to `true`, the mail server accepts the HAProxy PROXY protocol to receive the original client IP when behind a load balancer or reverse proxy.
