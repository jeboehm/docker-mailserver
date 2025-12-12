# docker-mailserver Documentation

![Logo](logo/logo.png)

`docker-mailserver` is a containerized email server solution inspired by the [ISPMail guide](https://workaround.org/ispmail/). It provides a secure, customizable email infrastructure that runs on Docker or Kubernetes.

## Overview

This project enables you to operate your own email services, providing independence from large email providers. The solution is built on Alpine Linux and vendor base images, keeping container images lightweight while maintaining comprehensive functionality.

## Key Features

- **Email Protocols**: POP3, IMAP, and SMTP with user authentication
- **Web Management**: Web-based interface for account, domain, and alias administration
- **Webmail**: Integrated webmail interface
- **External Mail Retrieval**: Fetchmail integration for retrieving emails from external providers
- **Email Authentication**: DKIM message signing for email authenticity
- **Spam Filtering**: Server-side mail filtering with configurable rules via web frontend
- **Spam Training**: Train spam filters by moving emails to or from the junk folder
- **Real-time Protection**: RBL (Real-Time Blackhole List) integration for spam prevention
- **Greylisting**: Selective greylisting for likely spam
- **Address Management**: Support for catch-all addresses and send-only accounts
- **Security**: Sender address restrictions and configurable address extensions
- **Quota Management**: Email quota management with notifications
- **TLS**: Enforced TLS for secure communication
- **Full-Text Search**: FTS support for efficient message searching
- **Health Monitoring**: Continuous self-monitoring via Docker healthcheck

## Quick Start

1. **[Installation Guide](INSTALLATION.md)** - Get started with Docker or Kubernetes deployment
2. **[Upgrade Guide](UPGRADE.md)** - Upgrade procedures and version migration notes

## Service Architecture

The mailserver consists of multiple microservices:

- **MTA (Mail Transfer Agent)** - Postfix for SMTP
- **MDA (Mail Delivery Agent)** - Dovecot for IMAP/POP3
- **Web** - Admin interface and Roundcube webmail
- **Filter** - RSpamd for spam filtering
- **SSL** - Certificate generation and management
- **Database** - MySQL for user and configuration data
- **Redis** - Caching and session storage
- **Unbound** - DNS resolver for the filter service
- **Fetchmail** - External mail retrieval (optional)

See [Architecture Documentation](ARCHITECTURE.md) for detailed information.

## Getting Help

- **[GitHub Issues](https://github.com/jeboehm/docker-mailserver/issues)** - Report bugs and request features
- **[Releases](https://github.com/jeboehm/docker-mailserver/releases)** - View release notes and changelog

## Container Images

Container images are available at:

- [GitHub Container Registry](https://github.com/jeboehm?tab=packages&repo_name=docker-mailserver)
- [Docker Hub](https://hub.docker.com/u/jeboehm?page=1&search=mailserver)

## Component References

- [Dovecot Documentation](https://doc.dovecot.org/2.4.1/)
- [Postfix Documentation](https://www.postfix.org/documentation.html)
- [Rspamd Documentation](https://docs.rspamd.com/)
- [Roundcube Documentation](https://docs.roundcube.net/doc/help/1.1/en_US/)
- [Redis Documentation](https://redis.io/docs/latest/)
- [Unbound Documentation](https://unbound.docs.nlnetlabs.nl/en/latest/)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=jeboehm/docker-mailserver&type=date&legend=top-left)](https://www.star-history.com/#jeboehm/docker-mailserver&type=date&legend=top-left)
