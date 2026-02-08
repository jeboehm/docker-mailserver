# docker-mailserver Documentation

![Logo](logo/logo.png)

`docker-mailserver` is a containerized email server solution inspired by the [ISPMail guide](https://workaround.org/ispmail/). It provides a secure, customizable email infrastructure that runs on Docker or Kubernetes.

## Overview

This project enables you to operate your own email services, providing independence from large email providers. The solution is built on Alpine Linux and vendor base images, keeping container images lightweight while maintaining comprehensive functionality.

## Documentation structure

The documentation is organised by purpose:

- **[Tutorial: Getting Started](tutorials/getting-started.md)** — A step-by-step lesson to install docker-mailserver with Docker Compose and create your first mailbox.
- **How-to guides** — Task-oriented guides for specific goals (install on Kubernetes, configure DNS, manage users, configure TLS, and more). See the [How-to](how-to/install-docker.md) section in the navigation.
- **Reference** — Technical descriptions: [environment variables](reference/environment-variables.md), [DNS records](reference/dns-records.md), [ports](reference/ports.md), [service architecture](reference/service-architecture.md), [user roles](reference/user-roles.md), and related topics.
- **Explanation** — Background and context: [architecture](explanation/architecture.md), [DNS and email delivery](explanation/dns-and-email.md), [observability](explanation/observability.md).

## Key features

- **Email protocols:** POP3, IMAP, and SMTP with user authentication
- **Web management:** Web-based interface for account, domain, and alias administration
- **Webmail:** Integrated webmail interface
- **External mail retrieval:** Fetchmail integration for retrieving emails from external providers
- **Email authentication:** DKIM message signing for email authenticity
- **Spam filtering:** Server-side mail filtering with configurable rules via web frontend
- **Spam training:** Train spam filters by moving emails to or from the junk folder
- **Real-time protection:** RBL integration for spam prevention
- **Greylisting:** Selective greylisting for likely spam
- **Address management:** Catch-all addresses, send-only accounts, local address extension (RFC 5233)
- **Security:** Sender address restrictions and configurable address extensions
- **Quota management:** Email quota management with notifications
- **TLS:** Enforced TLS for secure communication
- **Full-text search:** FTS support for efficient message searching
- **Health monitoring:** Continuous self-monitoring via Docker healthcheck

## Quick start

1. **[Tutorial: Getting Started](tutorials/getting-started.md)** — Install with Docker Compose and create your first account
2. **[How to install with Docker](how-to/install-docker.md)** — Docker Compose installation steps
3. **[How to install on Kubernetes](how-to/install-kubernetes.md)** — Kubernetes deployment steps
4. **[How to upgrade](how-to/upgrade.md)** — Upgrade procedures and [upgrade changelog](reference/upgrade-changelog.md)

## Service architecture

The mailserver consists of multiple microservices:

- **MTA (Mail Transfer Agent)** — Postfix for SMTP
- **MDA (Mail Delivery Agent)** — Dovecot for IMAP/POP3
- **Web** — Admin interface and Roundcube webmail
- **Filter** — RSpamd for spam filtering
- **SSL** — Certificate generation and management
- **Database** — MySQL for user and configuration data
- **Redis** — Caching and session storage
- **Unbound** — DNS resolver for the filter service
- **Fetchmail** — External mail retrieval (optional)

See [Service architecture reference](reference/service-architecture.md) for a concise list and [About the service architecture](explanation/architecture.md) for context.

## Getting help

- **[GitHub Issues](https://github.com/jeboehm/docker-mailserver/issues)** — Report bugs and request features
- **[Releases](https://github.com/jeboehm/docker-mailserver/releases)** — View release notes and changelog

## Container images

Container images are available at:

- [GitHub Container Registry](https://github.com/jeboehm?tab=packages&repo_name=docker-mailserver)
- [Docker Hub](https://hub.docker.com/u/jeboehm?page=1&search=mailserver)

## Component references

- [Dovecot Documentation](https://doc.dovecot.org/2.4.1/)
- [Postfix Documentation](https://www.postfix.org/documentation.html)
- [Rspamd Documentation](https://docs.rspamd.com/)
- [Roundcube Documentation](https://docs.roundcube.net/doc/help/1.1/en_US/)
- [Redis Documentation](https://redis.io/docs/latest/)
- [Unbound Documentation](https://unbound.docs.nlnetlabs.nl/en/latest/)

## Star history

[![Star History Chart](https://api.star-history.com/svg?repos=jeboehm/docker-mailserver&type=date&legend=top-left)](https://www.star-history.com/#jeboehm/docker-mailserver&type=date&legend=top-left)
