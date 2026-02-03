# About the Service Architecture

docker-mailserver is built from several services that handle different parts of mail delivery and management. Understanding how they fit together helps when configuring, troubleshooting, or extending the system.

## Why multiple services

Email delivery involves distinct tasks: accepting and relaying mail (MTA), storing and serving mailboxes (MDA), filtering spam (filter), and providing a web UI (web). Splitting these into separate services lets each use the right technology (Postfix, Dovecot, Rspamd, PHP) and scale or replace components independently.

## How the services work together

- **MTA (Postfix)** receives mail on port 25 and accepts submissions on port 587. It looks up recipients in the database, applies relay and policy, and hands mail to the filter for scanning. After filtering, it delivers to the MDA via LMTP or stores in the queue for later delivery.

- **MDA (Dovecot)** stores mail in maildirs and serves it over IMAP and POP3. It authenticates users against the database and enforces quotas. The web interface uses Dovecot for authentication and mailbox access; the filter may use Dovecot for scanning.

- **Filter (Rspamd)** scans messages for spam and viruses, applies DKIM signing, and can learn from user actions (e.g. moving mail to junk). It runs as a milter so the MTA can pass messages through it before delivery.

- **Web** runs the admin UI (mailserver-admin) and Roundcube webmail. It talks to the database for users, domains, aliases, and DKIM, and to Dovecot for authentication and mailbox operations. Observability features pull data from Rspamd and Dovecot (e.g. Doveadm HTTP API).

- **Database (MySQL)** holds users, domains, aliases, DKIM config, and application data. All services that need this data connect to the same database.

- **Redis** is used for sessions and caching so the web service can run across multiple instances without losing session state.

- **Unbound** (when used) provides DNS resolution for the filter so RBL and other DNS-based checks work correctly.

- **SSL** (optional) generates and manages internal TLS certificates. In production you typically replace these with certificates from a CA (e.g. Let’s Encrypt).

- **Fetchmail** (optional) periodically connects to external mail servers (POP3/IMAP) and delivers retrieved mail into local mailboxes.

For a concise list of services and volumes, see [Service architecture reference](../reference/service-architecture.md).
