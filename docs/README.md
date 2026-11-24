# docker-mailserver Documentation

![Logo](logo/logo.png)

`docker-mailserver` is a containerized email server solution inspired by the [ISPMail guide](https://workaround.org/ispmail/). It provides a secure, customizable email infrastructure that runs on Docker or Kubernetes.

## Overview

The project runs your own mail services (Postfix, Dovecot, Rspamd) with a web interface (mailserver-admin) and webmail (Roundcube). The container images are built on Alpine Linux or on the upstream images.

## Documentation structure

The documentation is organised by purpose:

- **[Tutorial: Getting Started](tutorials/getting-started.md)** — A step-by-step lesson to install docker-mailserver with Docker Compose and log in to the management interface.
- **How-to guides** — Task-oriented guides for specific goals: [install with Docker](how-to/install-docker.md), [install on Kubernetes](how-to/install-kubernetes.md), [configure DNS](how-to/configure-dns.md), [configure TLS](how-to/configure-tls.md), [manage users](how-to/manage-users.md), [configure the MCP server](how-to/configure-mcp-server.md), and more.
- **Reference** — Technical descriptions: [environment variables](reference/environment-variables.md), [DNS records](reference/dns-records.md), [ports](reference/ports.md), [service architecture](reference/service-architecture.md), [user roles](reference/user-roles.md), [MCP server](reference/mcp-server.md), and related topics.
- **Administration (web UI)** — Working with the management interface: [login](administration/login.md), [dashboard](administration/dashboard.md).
- **Explanation** — Background and context: [architecture](explanation/architecture.md), [database backends](explanation/database-backends.md), [DNS and email delivery](explanation/dns-and-email.md), [observability](explanation/observability.md), [MCP server risks and limitations](explanation/mcp-server.md).
- **Recipes** — Ready-made deployment examples: [Traefik reverse proxy](https://github.com/jeboehm/docker-mailserver/tree/main/docs/example-configs/compose/traefik-reverse-proxy) for Docker, [external database and HTTPS ingress](https://github.com/jeboehm/docker-mailserver/tree/main/docs/example-configs/kustomize/external-db-and-https-ingress) for Kubernetes.
- **Development** — Building and contributing: [development guide](development/development.md), [mailserver-admin development](development/mailserver-admin.md).

## Key features

- **Email protocols:** POP3, IMAP, and SMTP with user authentication
- **Web management:** Web-based interface for account, domain, and alias administration
- **Webmail:** Integrated webmail interface
- **Client provisioning:** Configuration profiles for iOS and macOS, plus assisted client configuration in Outlook and Thunderbird
- **DNS Validation Wizard:** Checks all mail-related DNS records for your domains
- **External mail retrieval:** Fetchmail integration for retrieving emails from external providers
- **MCP server:** Endpoint for agents to manage the server and read and send the user's own mail
- **Email authentication:** DKIM message signing for email authenticity
- **Spam filtering:** Server-side mail filtering with configurable rules via web frontend
- **Spam training:** Train spam filters by moving emails to or from the junk folder
- **Real-time protection:** RBL integration for spam prevention
- **Greylisting:** Selective greylisting for likely spam
- **Address management:** Catch-all addresses, send-only accounts, [local address extension](reference/local-address-extension.md) (RFC 5233)
- **Quota management:** Email quota management with notifications
- **TLS:** Enforced TLS for secure communication
- **Full-text search:** FTS support for efficient message searching
- **Health monitoring:** Continuous self-monitoring via Docker healthcheck

## Quick start

New to docker-mailserver: start with the [Getting Started tutorial](tutorials/getting-started.md). To install with a known procedure, see [Docker](how-to/install-docker.md) or [Kubernetes](how-to/install-kubernetes.md). To upgrade, see [How to upgrade](how-to/upgrade.md).

## Service architecture

The services and their roles are listed in the [Service architecture reference](reference/service-architecture.md). [About the service architecture](explanation/architecture.md) explains how they work together.

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
