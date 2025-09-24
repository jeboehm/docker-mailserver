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
