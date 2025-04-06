# docker-mailserver

`docker-mailserver` is inspired by the renowned [ISPMail guide](https://workaround.org/ispmail/).
This project enables you to run your own email services, giving you independence and freedom from relying on large corporations. It provides a secure, customizable, and feature-rich solution for managing your email infrastructure.

All Docker images are built on [Alpine Linux](https://alpinelinux.org), ensuring they remain as lightweight as possible.

[Changelog](https://github.com/jeboehm/docker-mailserver/releases)

## Build status

[![Build multiarch, buildx](https://github.com/jeboehm/docker-mailserver/actions/workflows/build-multiarch.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/build-multiarch.yml)
[![Matrix test application](https://github.com/jeboehm/docker-mailserver/actions/workflows/test.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/test.yml)
[![Create Release](https://github.com/jeboehm/docker-mailserver/actions/workflows/create-release.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/create-release.yml)

## Features

- Secure email protocols: POP3, IMAP, and SMTP with user authentication
- Enforced TLS for secure communication
- Intuitive webmail interface
- Server-side mail filtering with configurable rules via a web frontend
- Advanced spam and malware filtering
- Support for catchall email addresses
- Restriction of sender addresses for enhanced security
- Spam filter training by simply moving emails to or from the junk folder
- Real-time spam prevention using RBL (Real-Time Blackhole Lists)
- Greylisting applied only to emails likely to be spam
- DKIM message signing for email authenticity
- Quota management with notifications for quota exceedance
- Web-based management interface for account, domain, and alias administration
- Support for send-only accounts restricted from receiving emails
- Optional disabling of IMAP, POP3, and malware filters if not required
- Full-Text Search (FTS) support for efficient message searching
- Continuous self-monitoring via Docker's healthcheck feature
- Developed with a focus on high-quality assurance standards
- Address extension support using the "-" delimiter
- Kubernetes support via Helm charts for streamlined deployment on Kubernetes clusters
- Fetchmail integration to retrieve emails from external providers

## Installation (basic setup)

1. Run `git clone git@github.com:jeboehm/docker-mailserver.git`
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [Wiki](https://github.com/jeboehm/docker-mailserver/wiki/Configuration-variables).
3. Run `bin/production.sh pull` to download the images.
4. Run `bin/production.sh up -d` to start the services.
5. After a few seconds you can access the services listed in the paragraph [Services](#Services).
6. Create your first email address and an admin user by running `bin/production.sh run --rm web setup.sh`.
   The wizard will ask you a few questions to set everything up.
7. Now you can login to the management interface with your new account credentials.

## Installation on Kubernetes / k8s (beta)

### TL;DR

```bash
helm repo add mailserver https://jeboehm.github.io/mailserver-charts/
helm search repo mailserver
helm install my-release mailserver/docker-mailserver
```

You can find `values.yaml` and more information in the [mailserver-charts repository](https://github.com/jeboehm/mailserver-charts/tree/main/charts/docker-mailserver).

## Screenshots

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

## Documentation

- [Configuration](https://github.com/jeboehm/docker-mailserver/wiki/Configuration-variables)
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
- [Upgrading](https://github.com/jeboehm/docker-mailserver/wiki/Upgrading)
- [Troubleshooting](https://github.com/jeboehm/docker-mailserver/wiki/Troubleshooting)

## Services

| Service                                    | Address                      |
| ------------------------------------------ | ---------------------------- |
| POP3 (starttls needed)                     | 127.0.0.1:110                |
| POP3S                                      | 127.0.0.1:995                |
| IMAP (starttls needed)                     | 127.0.0.1:143                |
| IMAPS                                      | 127.0.0.1:993                |
| SMTP                                       | 127.0.0.1:25                 |
| Mail Submission (starttls needed)          | 127.0.0.1:587                |
| Mail Submission (SSL, disabled by default) | 127.0.0.1:465                |
| Management Interface                       | http://127.0.0.1:81/manager/ |
| Webmail                                    | http://127.0.0.1:81/webmail/ |
| Rspamd Webinterface                        | http://127.0.0.1:81/rspamd/  |

## Links

- [Issues](https://github.com/jeboehm/docker-mailserver/issues)
- [Helm Charts](https://github.com/jeboehm/mailserver-charts)
- [mailserver-admin](https://github.com/jeboehm/mailserver-admin)
- [fetchmailmgr](https://github.com/jeboehm/fetchmailmgr)
