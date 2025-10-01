# Environment Variables Configuration

This document provides an overview of all environment variables used to configure `docker-mailserver` project.

## Basic Configuration Variables

These are the core environment variables that need to be configured in your `.env` file for basic mailserver functionality.

### Database Configuration

When you use the MySQL service provided by docker-mailserver compose, you don't need to configure this.
It is required to **always set** `MYSQL_PASSWORD`.

| Variable         | Default                              | Description             |
| ---------------- | ------------------------------------ | ----------------------- |
| `MYSQL_HOST`     | `db`                                 | MySQL database hostname |
| `MYSQL_PORT`     | `3306`                               | MySQL database port     |
| `MYSQL_DATABASE` | `mailserver`                         | MySQL database name     |
| `MYSQL_USER`     | `root` (MTA/MDA), `mailserver` (Web) | MySQL database username |
| `MYSQL_PASSWORD` | _(empty)_                            | MySQL database password |

### Mail Server Identity

| Variable              | Default                  | Description                                                       |
| --------------------- | ------------------------ | ----------------------------------------------------------------- |
| `MAILNAME`            | `mail.example.com`       | Primary mail server hostname                                      |
| `POSTMASTER`          | `postmaster@example.com` | Postmaster email address                                          |
| `RECIPIENT_DELIMITER` | `-`                      | Character used for address extensions (e.g., user+tag@domain.com) |

### Redis Configuration

When you use the Redis service provided by docker-mailserver compose or kustomize, you don't need to configure this.
It is required to **always set** `REDIS_PASSWORD`.

| Variable         | Default      | Description           |
| ---------------- | ------------ | --------------------- |
| `REDIS_HOST`     | `redis`      | Redis server hostname |
| `REDIS_PORT`     | `6379`       | Redis server port     |
| `REDIS_PASSWORD` | _(required)_ | Redis server password |

### Authentication

This is the password for the RSpamd controller access. It is required to **always set** `CONTROLLER_PASSWORD`.

| Variable              | Default      | Description                           |
| --------------------- | ------------ | ------------------------------------- |
| `CONTROLLER_PASSWORD` | _(required)_ | Password for RSpamd controller access |

### Relay Configuration

| Variable            | Default | Description                       |
| ------------------- | ------- | --------------------------------- |
| `RELAYHOST`         | `false` | SMTP relay host for outgoing mail |
| `RELAY_PASSWD_FILE` | `false` | Path to relay authentication file |
| `RELAY_OPTIONS`     | `false` | Additional relay security options |

### Filter Configuration

Block suspicious attachments by type (bat, com, exe, dll, vbs, docm, doc, dzip).

| Variable      | Default | Description                  |
| ------------- | ------- | ---------------------------- |
| `FILTER_MIME` | `false` | Enable MIME header filtering |

## Extended Configuration Variables

These variables are used for service-to-service communication and configuration. You need them
when you use Kubernetes or decide to rename services somehow.

### Service Address Configuration

| Variable                      | Default                  | Description                             |
| ----------------------------- | ------------------------ | --------------------------------------- |
| `FILTER_MILTER_ADDRESS`       | `filter:11332`           | RSpamd milter service address           |
| `FILTER_WEB_ADDRESS`          | `filter:11334`           | RSpamd web interface address            |
| `MDA_AUTH_ADDRESS`            | `mda:2004`               | Dovecot authentication service address  |
| `MDA_IMAP_ADDRESS`            | `mda:143`                | Dovecot IMAP service address            |
| `MDA_LMTP_ADDRESS`            | `mda:2003`               | Dovecot LMTP service address            |
| `MDA_MANAGESIEVE_ADDRESS`     | `mda:4190`               | Dovecot ManageSieve service address     |
| `MTA_HOST`                    | `mta`                    | Postfix MTA hostname                    |
| `MTA_SMTP_ADDRESS`            | `mta:25`                 | Postfix SMTP service address            |
| `MTA_SMTP_SUBMISSION_ADDRESS` | `mta:587`                | Postfix SMTP submission service address |
| `WEB_HTTP_ADDRESS`            | `web:80`                 | Web interface HTTP address              |
| `WEB_PHP_ADDRESS`             | `127.0.0.1:9000`         | PHP-FPM service address                 |
| `RSPAMD_DNS_SERVERS`          | `round-robin:unbound:53` | DNS servers for RSpamd (Kubernetes)     |

### mailserver-admin Configuration

See [mailserver-admin](https://github.com/jeboehm/mailserver-admin?tab=readme-ov-file#environment-variables) for more information.

### PHP Configuration

| Variable                   | Default                                                    | Description          |
| -------------------------- | ---------------------------------------------------------- | -------------------- |
| `PHP_SESSION_SAVE_HANDLER` | `redis`                                                    | Session save handler |
| `PHP_SESSION_SAVE_PATH`    | `tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}` | Session save path    |

### Proxy Protocol Configuration

These variables enable HAProxy PROXY protocol support for load balancer integration.

| Variable             | Default | Description                                                                  |
| -------------------- | ------- | ---------------------------------------------------------------------------- |
| `MDA_UPSTREAM_PROXY` | `false` | Enable Traefik / HAProxy PROXY protocol for MDA (Dovecot) IMAP/POP3 services |
| `MTA_UPSTREAM_PROXY` | `false` | Enable Traefik / HAProxy PROXY protocol for MTA (Postfix) SMTP services      |

#### Usage

When set to `true`, these variables enable the HAProxy / Traefik PROXY protocol, which allows the mail server to receive the original client IP address when behind a load balancer or reverse proxy.

**MDA_UPSTREAM_PROXY** affects:

- IMAP service
- IMAPS service
- POP3 service
- POP3S service

**MTA_UPSTREAM_PROXY** affects:

- SMTP service
- SMTP submission service

This is typically used when deploying behind load balancers like HAProxy, Traefik, or cloud load balancers that support the PROXY protocol.
