# Service Architecture

`docker-mailserver` consists of several microservices:

- **MTA (Mail Transfer Agent)** - Postfix for SMTP
- **MDA (Mail Delivery Agent)** - Dovecot for IMAP/POP3
- **Web** - Admin interface and Roundcube webmail
- **Filter** - RSpamd for spam filtering
- **SSL** - Certificate generation and management
- **Database** - MySQL for user and configuration data
- **Redis** - Caching and session storage
- **Unbound** - DNS resolver for the filter service
- **Fetchmail** - External mail retrieval (optional)

## Persistent Volumes

The project uses several persistent volumes to ensure data persistence across container restarts and updates. These volumes are defined in the main `docker-compose.yml` file and mounted into specific services:

### Volume Definitions

```yaml
volumes:
  data-db: # MySQL database storage
  data-mail: # User mailboxes and email data
  data-tls: # TLS certificates and keys
  data-filter: # RSpamd filter data and statistics
  data-redis: # Redis cache and session data
```

### Volume Mounts by Service

#### Database Service (`db`)

- **`data-db:/var/lib/mysql`** - Stores MySQL database files, user accounts, aliases, and configuration data

#### Mail Transfer Agent (`mta`)

- **`data-tls:/etc/postfix/tls:ro`** - Read-only access to TLS certificates for SMTP encryption

#### Mail Delivery Agent (`mda`)

- **`data-mail:/srv/vmail`** - User mailboxes, email storage, and maildir structure
- **`data-tls:/etc/dovecot/tls:ro`** - Read-only access to TLS certificates for IMAP/POP3 encryption

#### Filter Service (`filter`)

- **`data-filter:/var/lib/rspamd`** - RSpamd configuration, statistics, and learning data

#### Redis Service (`redis`)

- **`data-redis:/data`** - Redis database files for caching and session storage

#### SSL Service (`ssl`)

- **`data-tls:/media/tls:rw`** - Read-write access for TLS certificate generation and management

### Volume Purpose and Data Persistence

- **`data-db`**: Critical for maintaining user accounts, passwords, and mail server configuration
- **`data-mail`**: Essential for preserving all user emails and mailbox structures
- **`data-tls`**: Required for maintaining SSL/TLS certificates and encryption keys
- **`data-filter`**: Important for spam filter learning and statistics accumulation
- **`data-redis`**: Used for session management and temporary data caching

These volumes ensure that your mail server data survives container updates, restarts, and even complete system reboots, making the deployment production-ready and reliable.
