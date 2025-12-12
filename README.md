# docker-mailserver

![Logo](/docs/logo/logo.png?raw=true)

`docker-mailserver` is inspired by the renowned [ISPMail guide](https://workaround.org/ispmail/).
This project lets you run your own email services, giving you independence from large providers. It is a secure, customizable, and feature-rich solution for managing your email infrastructure.

Container images are built on [Alpine Linux](https://alpinelinux.org) or vendor base images and are kept lightweight.

[![Build & Tests](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml)

## 📚 Documentation

**Full documentation is available at: [https://jeboehm.github.io/docker-mailserver/](https://jeboehm.github.io/docker-mailserver/)**

The documentation includes:

- Complete installation guides for Docker and Kubernetes
- Configuration reference for all environment variables
- Deployment examples and recipes
- Architecture and development guides

## Features

- Secure email protocols: POP3, IMAP, and SMTP with user authentication
- Web-based management interface for account, domain, and alias administration
- Integrated webmail interface
- DKIM message signing and spam filtering with Rspamd
- Real-time spam prevention using RBLs (Real-Time Blackhole Lists)
- Fetchmail integration for external mail retrieval
- Quota management, catch-all addresses, and send-only accounts
- Restriction of sender addresses for enhanced security
- Full-text search and enforced TLS
- Continuous health monitoring

See the [documentation](https://jeboehm.github.io/docker-mailserver/) for a complete feature list.

## Setup

`docker-mailserver` can be set up using Docker or Kubernetes.

For detailed installation instructions, see the [Installation Guide](https://jeboehm.github.io/docker-mailserver/INSTALLATION/) in the documentation.

## Screenshots

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

## Links

- [Documentation](https://jeboehm.github.io/docker-mailserver/) - Complete documentation and guides
- [Issues](https://github.com/jeboehm/docker-mailserver/issues) - Report bugs and request features
- [Releases](https://github.com/jeboehm/docker-mailserver/releases) - Release notes and changelog
- Container Images:
  - [GitHub Container Registry](https://github.com/jeboehm?tab=packages&repo_name=docker-mailserver)
  - [Docker Hub](https://hub.docker.com/u/jeboehm?page=1&search=mailserver)
