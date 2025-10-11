# docker-mailserver

![Logo](/docs/logo/logo.png?raw=true)

`docker-mailserver` is inspired by the renowned [ISPMail guide](https://workaround.org/ispmail/).
This project lets you run your own email services, giving you independence from large providers. It is a secure, customizable, and feature-rich solution for managing your email infrastructure.

Container images are built on [Alpine Linux](https://alpinelinux.org) or vendor base images and are kept lightweight.

[Changelog](https://github.com/jeboehm/docker-mailserver/releases)
[Upgrade Guide](docs/UPGRADE.md)

[![Tests](https://github.com/jeboehm/docker-mailserver/actions/workflows/test.yml/badge.svg?branch=next)](https://github.com/jeboehm/docker-mailserver/actions/workflows/test.yml)
[![Build](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml)

## Features

- Secure email protocols: POP3, IMAP, and SMTP with user authentication
- Web-based management interface for account, domain, and alias administration
- Intuitive webmail interface
- Fetchmail integration to retrieve emails from external providers
- DKIM message signing for email authenticity
- Server-side mail filtering with configurable rules via a web frontend
- Spam filter training by simply moving emails to or from the junk folder
- Real-time spam prevention using RBLs (Real-Time Blackhole Lists)
- Selective greylisting for likely spam
- Support for catch-all email addresses
- Support for send-only accounts restricted from receiving emails
- Restriction of sender addresses for enhanced security
- Configurable address extensions using the '-' delimiter
- Quota management with notifications when quotas are exceeded
- Enforced TLS for secure communication
- Full-text search (FTS) support for efficient message searching
- Continuous self-monitoring via Docker healthcheck
- Developed with a strong focus on quality assurance

## Installation

### With Docker Compose

1. Run `git clone git@github.com:jeboehm/docker-mailserver.git`
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
3. Run `bin/production.sh pull` to download the images.
4. Run `bin/production.sh up -d` to start the services.
5. After a few seconds, you can access the services listed in the section [Ports overview](#ports-overview).
6. Create your first email address and an admin user by running `bin/production.sh run --rm web setup.sh`.
   The wizard will ask you a few questions to set everything up.
7. Now you can log in to the management interface with your new account credentials.

### On Kubernetes (K8s)

Kubernetes installation is a first-class citizen. You can use the `kustomization.yaml` file to deploy the mailserver to your Kubernetes cluster.

**Important:** Installing on Kubernetes requires an existing MySQL-compatible database (for example, MySQL or Percona XtraDB).
The provided kustomization does not provision a database. Configure the database connection in your `.env` and supply
credentials as Kubernetes Secrets before applying the manifests. See the
[Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
and the documentation [Use another MySQL instance](docs/EXTERNAL_MYSQL.md) for details.

1. Run `git clone git@github.com:jeboehm/docker-mailserver.git`
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
3. Run `kubectl create namespace mail`
4. Run `bin/create-tls-certs.sh`
5. Run `kubectl create -n mail secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key`
6. Run `kubectl apply -n mail -k .`

## Ports overview

| Service                             | Address                      |
| ----------------------------------- | ---------------------------- |
| POP3 (STARTTLS required)            | 127.0.0.1:110                |
| POP3S                               | 127.0.0.1:995                |
| IMAP (STARTTLS required)            | 127.0.0.1:143                |
| IMAPS                               | 127.0.0.1:993                |
| SMTP                                | 127.0.0.1:25                 |
| Mail Submission (STARTTLS required) | 127.0.0.1:587                |
| Management Interface                | http://127.0.0.1:81/manager/ |
| Webmail                             | http://127.0.0.1:81/webmail/ |
| Rspamd web interface                | http://127.0.0.1:81/rspamd/  |

## Screenshots

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

## Documentation

- [Upgrade Guide](docs/UPGRADE.md)
- [Features](docs/FEATURES.md)
- [Service Architecture](docs/ARCHITECTURE.md)
- Installation:
  - [Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
  - [Compose Traefik Reverse Proxy Example](docs/example-configs/compose/traefik-reverse-proxy/README.md)
- Configuration:
  - [Environment Variables](docs/ENVIRONMENT_VARIABLES.md)
  - [Roundcube](docs/ROUNDCUBE.md)
  - [TLS](docs/TLS.md)
  - [External MySQL](docs/EXTERNAL_MYSQL.md)
  - [External relay host](docs/RELAYHOST.md)
  - [Reverse Proxy](docs/REVERSE_PROXY.md)
  - [PHP Sessions](docs/PHP_SESSIONS.md)
- [Developer Guide](docs/DEVELOPMENT.md)

## Links

- [Issues](https://github.com/jeboehm/docker-mailserver/issues)
- [mailserver-admin](https://github.com/jeboehm/mailserver-admin)
- [fetchmailmgr](https://github.com/jeboehm/fetchmailmgr)
