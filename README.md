# docker-mailserver

`docker-mailserver` is inspired by the renowned [ISPMail guide](https://workaround.org/ispmail/).
This project enables you to run your own email services, giving you independence and freedom from relying on large corporations. It provides a secure, customizable, and feature-rich solution for managing your email infrastructure.

The container images are built either on [Alpine Linux](https://alpinelinux.org) or with the vendor's own base image, always ensuring they remain as lightweight as possible.

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
- Real-time spam prevention using RBL (Real-Time Blackhole Lists)
- Greylisting applied only to emails likely to be spam
- Support for catchall email addresses
- Support for send-only accounts restricted from receiving emails
- Restriction of sender addresses for enhanced security
- Configurable address extension support using the "-" delimiter
- Quota management with notifications for quota exceedance
- Enforced TLS for secure communication
- Full-Text Search (FTS) support for efficient message searching
- Continuous self-monitoring via Docker's healthcheck feature
- Developed with a focus on high-quality assurance standards

## Installation

### with Docker Compose

1. Run `git clone git@github.com:jeboehm/docker-mailserver.git`
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
3. Run `bin/production.sh pull` to download the images.
4. Run `bin/production.sh up -d` to start the services.
5. After a few seconds you can access the services listed in the section [Ports overview](#ports-overview).
6. Create your first email address and an admin user by running `bin/production.sh run --rm web setup.sh`.
   The wizard will ask you a few questions to set everything up.
7. Now you can login to the management interface with your new account credentials.

### on Kubernetes / k8s

Kubernetes installation is now a first class citizen. You can use the `kustomization.yaml` file to deploy the mailserver to your Kubernetes cluster.

**Important:** Installing on Kubernetes requires an existing MySQL-compatible database (for example MySQL or Percona
XtraDB). The provided kustomization does not provision a database. Configure the database connection via your `.env`
and supply credentials as Kubernetes Secrets before applying the manifests. See the
[Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
and the Wiki guide
[Use another MySQL instance](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Use-Another-MySQL-Instance) for
details.

1. Run `git clone git@github.com:jeboehm/docker-mailserver.git`
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [docs](docs/ENVIRONMENT_VARIABLES.md).
3. Run `kubectl create namespace mail`
4. Run `bin/create-tls-certs.sh`
5. Run `kubectl create -n mail secret tls tls-certs --cert=config/tls/tls.crt --key=config/tls/tls.key`
6. Run `kubectl apply -n mail -k .`

## Ports overview

| Service                           | Address                      |
| --------------------------------- | ---------------------------- |
| POP3 (starttls needed)            | 127.0.0.1:110                |
| POP3S                             | 127.0.0.1:995                |
| IMAP (starttls needed)            | 127.0.0.1:143                |
| IMAPS                             | 127.0.0.1:993                |
| SMTP                              | 127.0.0.1:25                 |
| Mail Submission (starttls needed) | 127.0.0.1:587                |
| Management Interface              | http://127.0.0.1:81/manager/ |
| Webmail                           | http://127.0.0.1:81/webmail/ |
| Rspamd Webinterface               | http://127.0.0.1:81/rspamd/  |

## Screenshots

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

## Documentation

- [Upgrade Guide](docs/UPGRADE.md)
- [Environment Variables](docs/ENVIRONMENT_VARIABLES.md)
- Installation:
  - [Kustomize External Database and HTTPS Ingress Example](docs/example-configs/kustomize/external-db-and-https-ingress/README.md)
  - [Compose Traefik Reverse Proxy Example](docs/example-configs/compose/traefik-reverse-proxy/README.md)
- [Developer Guide](docs/DEVELOPMENT.md)
- [Service Architecture](docs/ARCHITECTURE.md)

### Wiki (outdated, will be moved to the docs directory)

- Advanced setup:
  - [Use own TLS certficates](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Use-Your-Own-TLS-Certificates)
  - [Use another MySQL instance](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Use-Another-MySQL-Instance)
  - [Use the web service behind nginx-proxy](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Use-The-Web-Service-Behind-nginx-proxy)
  - [Container health monitoring](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Container-Health-Monitoring)
  - [Disable malware scanning](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Disable-Malware-Scanning)
  - [Advanced malware signatures](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Advanced-Malware-Signatures)
  - [Use an external mail relay](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Use-External-Mail-Relay-For-Sending-Mails)
  - [Add plugins to Roundcube](https://github.com/jeboehm/docker-mailserver/wiki/Howto:-Add-Plugins-To-Roundcube-Webmail)
- Features:
  - [Local address extension](https://github.com/jeboehm/docker-mailserver/wiki/Feature:-Local-Address-Extension)
  - [Sender policy framework, SPF](<https://github.com/jeboehm/docker-mailserver/wiki/Feature:-Sender-Policy-Framework-(SPF)>)
  - [DKIM](https://github.com/jeboehm/docker-mailserver/wiki/Feature:-DKIM)
- Technical details:
  - [Data storage](<https://github.com/jeboehm/docker-mailserver/wiki/Info:-Volume-Management-(Where-Is-My-Data%3F)>)
  - [Filtering](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Mail-Filtering)
  - [Component overview](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Component-Overview)
  - [DockerHub images](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Images-On-DockerHub)
- [Troubleshooting](https://github.com/jeboehm/docker-mailserver/wiki/Troubleshooting)

## Links

- [Issues](https://github.com/jeboehm/docker-mailserver/issues)
- [mailserver-admin](https://github.com/jeboehm/mailserver-admin)
- [fetchmailmgr](https://github.com/jeboehm/fetchmailmgr)
