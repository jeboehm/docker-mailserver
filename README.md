# docker-mailserver

![Logo](/docs/logo/logo.png?raw=true)

`docker-mailserver` is inspired by the renowned [ISPMail guide](https://workaround.org/ispmail/).
This project lets you run your own email services, giving you independence from large providers. It is a secure, customizable, and feature-rich solution for managing your email infrastructure.

Container images are built on [Alpine Linux](https://alpinelinux.org) or vendor base images and are kept lightweight.

[Changelog](https://github.com/jeboehm/docker-mailserver/releases)
[Upgrade Guide](docs/UPGRADE.md)

[![Build & Tests](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/jeboehm/docker-mailserver/actions/workflows/build.yml)

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

### Download

Download the latest release from the [Releases](https://github.com/jeboehm/docker-mailserver/releases) page and unpack the archive (release-vX.X.X.tar.gz).
If you are an advanced user, you can also download the source code from GitHub:

```bash
git clone https://github.com/jeboehm/docker-mailserver.git
```

Do not use the `latest` container image tag for production deployments. Use a specific version instead.
For example, use `jeboehm/mailserver-mta:6.3` instead of `jeboehm/mailserver-mta:latest`.

### Run on Docker

1. Copy the file `.env.dist` to `.env` and open it in a text editor.
   Change the variables in it according to your needs. They are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
2. To download the Docker images, run `bin/production.sh pull`.
3. To start the services, run `bin/production.sh up -d --wait`. This will wait for all services to be ready before continuing.
4. After a few seconds, you can access the services listed in the section [Ports overview](#ports-overview).
5. Start the installation wizard by running `bin/production.sh run --rm web setup.sh`. This will ask you a few questions to set everything up and create your first email address and an admin user.
6. Now you can log in to the management interface with your new account credentials.

### Run On Kubernetes (K8s)

Kubernetes deployment is fully supported. You can use the `kustomization.yaml` file to deploy the mailserver to your Kubernetes cluster.

**Important:** Installing on Kubernetes requires an existing MySQL-compatible database (for example, MySQL or Percona XtraDB).
The provided kustomization does not provision a database. Configure the database connection in your `.env` and supply
credentials as Kubernetes Secrets before applying the manifests. See the
[Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
and the documentation [Use another MySQL instance](docs/EXTERNAL_MYSQL.md) for details.

1. Copy the file `.env.dist` to `.env` and open it in a text editor.
   Change the variables in it according to your needs. They are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
2. Create a namespace for the mailserver by running `kubectl create namespace mail`.
3. To create self-signed TLS certificates, run `bin/create-tls-certs.sh`. You'll need them when you don't plan to use tools like `cert-manager`.
4. Create a Kubernetes secret for the TLS certificates by running `kubectl create -n mail secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key`.
5. Apply the kustomize manifests by running `kubectl apply -n mail -k .`.
6. When the pods are up and healthy, start the installation wizard by executing `setup.sh` in the php-fpm container of the web pod. This will ask you a few questions to set everything up and create your first email address and an admin user.
7. Now you can log in to the management interface with your new account credentials on the configured ingress.

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

## Documentation

- [Upgrade Guide](docs/UPGRADE.md)
- [Service Architecture](docs/ARCHITECTURE.md)
- Installation:
  - [Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
  - [Compose Traefik Reverse Proxy Example](docs/example-configs/compose/traefik-reverse-proxy/README.md)
- Configuration:
  - [DKIM Signing](docs/DKIM_SIGNING.md)
  - [Environment Variables](docs/ENVIRONMENT_VARIABLES.md)
  - [External MySQL](docs/EXTERNAL_MYSQL.md)
  - [External relay host](docs/RELAYHOST.md)
  - [Local Address Extension](docs/LOCAL_ADDRESS_EXTENSION.md)
  - [PHP Sessions](docs/PHP_SESSIONS.md)
  - [Reverse Proxy](docs/REVERSE_PROXY.md)
  - [Roundcube](docs/ROUNDCUBE.md)
  - [TLS](docs/TLS.md)
- [Developer Guide](docs/DEVELOPMENT.md)

## Screenshots

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

## Links

- [Issues](https://github.com/jeboehm/docker-mailserver/issues)
- Container Images:
  - [ghcr.io](https://github.com/jeboehm?tab=packages&repo_name=docker-mailserver)
  - [Docker Hub](https://hub.docker.com/u/jeboehm?page=1&search=mailserver)
- Components:
  - [dovecot](https://doc.dovecot.org/2.4.1/)
  - [fetchmailmgr](https://github.com/jeboehm/fetchmailmgr)
  - [mailserver-admin](https://github.com/jeboehm/mailserver-admin)
  - [postfix](https://www.postfix.org/documentation.html)
  - [redis](https://redis.io/docs/latest/)
  - [roundcube](https://docs.roundcube.net/doc/help/1.1/en_US/)
  - [rspamd](https://docs.rspamd.com/)
  - [unbound](https://unbound.docs.nlnetlabs.nl/en/latest/)
