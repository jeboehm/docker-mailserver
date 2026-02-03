# Service Architecture Reference

docker-mailserver consists of the following services:

| Service   | Component         | Role                               |
| --------- | ----------------- | ---------------------------------- |
| MTA       | Postfix           | SMTP (send/receive)                |
| MDA       | Dovecot           | IMAP/POP3 (mailbox access)         |
| Web       | Admin + Roundcube | Management UI and webmail          |
| Filter    | Rspamd            | Spam filtering                     |
| SSL       | —                 | Certificate generation             |
| Database  | MySQL             | User and configuration data        |
| Redis     | Redis             | Caching and sessions               |
| Unbound   | Unbound           | DNS resolver for filter            |
| Fetchmail | Fetchmail         | External mail retrieval (optional) |

## Persistent Volumes

| Volume        | Purpose                             |
| ------------- | ----------------------------------- |
| `data-db`     | MySQL data (users, aliases, config) |
| `data-mail`   | User mailboxes (maildir)            |
| `data-tls`    | TLS certificates and keys           |
| `data-filter` | Rspamd data and statistics          |
| `data-redis`  | Redis data                          |
| `data-spool`  | Postfix queue and spool             |

## Volume Mounts by Service

- **db:** `data-db:/var/lib/mysql`
- **mta:** `data-tls:/etc/postfix/tls:ro`, `data-spool:/var/spool/postfix`
- **mda:** `data-mail:/srv/vmail`, `data-tls:/etc/dovecot/tls:ro`
- **filter:** `data-filter:/var/lib/rspamd`
- **redis:** `data-redis:/data`
- **SSL:** `data-tls:/media/tls:rw`

For an overview of how these components work together, see [Architecture](../explanation/architecture.md).
