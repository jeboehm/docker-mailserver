docker-mailserver
=================

Docker Mailserver based on the famous [ISPMail guide](https://workaround.org/ispmail/).
All images are based on [Alpine Linux](https://alpinelinux.org) and are so small as possible.

[Changelog](https://github.com/jeboehm/docker-mailserver/releases)

Build status
------------
[![Integration Tests](https://github.com/jeboehm/docker-mailserver/actions/workflows/integration-tests.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/integration-tests.yml)
[![Build unofficial-sigs](https://github.com/jeboehm/docker-mailserver/actions/workflows/build-unofficial-sigs.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/build-unofficial-sigs.yml)
[![Lint Code Base](https://github.com/jeboehm/docker-mailserver/actions/workflows/super-linter.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/super-linter.yml)
[![Publish release](https://github.com/jeboehm/docker-mailserver/actions/workflows/publish-release.yml/badge.svg)](https://github.com/jeboehm/docker-mailserver/actions/workflows/publish-release.yml)

Features
--------

- POP3, IMAP, SMTP with user authentication
- TLS enforced
- Webmail interface
- Server-side mail filtering, rule configuration via web frontend
- Spam- and malware filter
- Catchall address support
- Restricted sender addresses
- Spamfilter is trained just by moving emails to or out of the junk folder
- Uses RBL (real time black hole lists) to block already known spam senders
- Greylisting only when incoming mail is likely spam
- DKIM message signing
- Quota support
- Notifications when exceeding the quota
- Web management interface to create / remove accounts, domains and aliases
- Support of send only accounts which are not allowed to receive but send mails
- IMAP, POP3 and malware filters can be disabled if they are not used
- FTS (Full-Text Search) support using [fts-xapian](https://github.com/grosjo/fts-xapian) for fast message searching
- Permanent self testing by Docker's healthcheck feature
- Developed with high quality assurance standards
- Address extension (-)

Installation (basic setup)
--------------------------

1. Run ```git clone git@github.com:jeboehm/docker-mailserver.git```
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [Wiki](https://github.com/jeboehm/docker-mailserver/wiki/Configuration-variables).
3. Run ```bin/production.sh pull``` to download the images.
4. Run ```bin/production.sh up -d``` to start the services.
5. After a few seconds you can access the services listed in the paragraph [Services](#Services).
6. Create your first email address and an admin user by running ```bin/production.sh run --rm web setup.sh```.
   The wizard will ask you a few questions to set everything up.
8. Now you can login to the management interface with your new account credentials.

Screenshots
-----------

### Manage users

![User overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/user.png)

### Manage aliases

![Alias overview](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/alias.png)

### DKIM setup

![DKIM setup](https://raw.githubusercontent.com/jeboehm/mailserver-admin/master/.github/screenshots/dkim_edit.png)

Documentation
-------------

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
  - [Sender policy framework, SPF](https://github.com/jeboehm/docker-mailserver/wiki/Feature:-Sender-Policy-Framework-(SPF))
  - [DKIM](https://github.com/jeboehm/docker-mailserver/wiki/Feature:-DKIM)
- Technical details:
  - [Data storage](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Volume-Management-(Where-Is-My-Data%3F))
  - [Filtering](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Mail-Filtering)
  - [Component overview](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Component-Overview)
  - [DockerHub images](https://github.com/jeboehm/docker-mailserver/wiki/Info:-Images-On-DockerHub)
- [Upgrading](https://github.com/jeboehm/docker-mailserver/wiki/Upgrading)
- [Troubleshooting](https://github.com/jeboehm/docker-mailserver/wiki/Troubleshooting)

Services
--------

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
