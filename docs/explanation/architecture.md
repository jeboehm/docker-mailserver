# About the Service Architecture

docker-mailserver is built from several services, one per task: accepting and relaying mail (MTA), storing and serving mailboxes (MDA), filtering spam (filter) and the web UI (web). Each service uses its own software (Postfix, Dovecot, Rspamd, PHP) and can be scaled or replaced independently. The list of services is in the [Service architecture reference](../reference/service-architecture.md).

## How the services work together

- **MTA (Postfix)** receives mail on port 25 and accepts submissions on port 587. It looks up recipients in the database, applies relay and policy, and hands mail to the filter for scanning. After filtering, it delivers to the MDA via LMTP or stores in the queue for later delivery.

- **MDA (Dovecot)** stores mail in maildirs and serves it over IMAP and POP3. It authenticates users against the database and enforces quotas.

- **Filter (Rspamd)** scans messages for spam, applies DKIM signing, and can learn from user actions (e.g. moving mail to junk). It runs as a milter so the MTA can pass messages through it before delivery. Its state, including the DKIM keys, is kept in Redis.

- **Web** runs the admin UI (mailserver-admin) and Roundcube webmail. It talks to the database for users, domains, aliases and DKIM, and to Dovecot for mailbox access. Observability features pull data from Rspamd and Dovecot (Doveadm HTTP API).

- **Database (MySQL/MariaDB or PostgreSQL)** holds users, domains, aliases, DKIM config, and application data. All services that need this data connect to the same database. See [Database backends](database-backends.md).

- **Redis** holds the state of Rspamd and the sessions and caches of the web service, so the web service can run across multiple instances.

- **Unbound** (when used) provides DNS resolution for the filter so RBL and other DNS-based checks work correctly.

- **SSL** (optional) generates and manages internal TLS certificates. In production you typically replace these with certificates from a CA (e.g. Let’s Encrypt).

- **Fetchmail** (optional) periodically connects to external mail servers (POP3/IMAP) and delivers retrieved mail into local mailboxes.
