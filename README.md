docker-mailserver
=================

Docker Mailserver based on the famous [ISPMail guide](https://workaround.org/ispmail/).
All images are based on [Alpine Linux](https://alpinelinux.org) and are so small as possible.

[![Build Status](https://travis-ci.org/jeboehm/docker-mailserver.svg?branch=master)](https://travis-ci.org/jeboehm/docker-mailserver)

Features
--------
- POP3, IMAP, SMTP with user authentification
- TLS support
- Webmail interface
- Server-side mail filtering, rule configuration via web frontend
- Spam- and malware filter
- Uses RBL (real time black hole lists) to block already known spam senders
- Greylisting only when incoming mail is likely spam
- Web management interface to create / remove accounts, domains and aliases
- Support of send only accounts which are not allowed to receive but send mails
- IMAP, POP3 and malware filters can be disabled if they are not used
- Permanent self testing by Docker's healthcheck feature
- Developed with high quality assurance standards

Usage
=====

Installation (basic setup)
--------------------------
1. ```git clone git@github.com:jeboehm/docker-mailserver.git```
2. Copy the file `.env.dist` to `.env` and change the variables in it according to your needs.
   The variables are described in the [next paragraph](#Configuration).
3. Run ```bin/production.sh pull``` to download the images.
4. Run ```bin/production.sh up -d``` to start the services.
5. After a few seconds you can access the services listed in the paragraph [Services](#Services).
6. Login to the management interface with username `admin@example.com` and password `changeme`.
7. Create a first domain and add an mail account to it. Set it as an admin account.
8. Now you can login to the management interface with your new account credentials. The example.com domain
   can be safely deleted.

Configuration
-------------
All configuration options can be found in the `.env` file in the root folder of docker mailserver.

| Variable            | Description                                                                  |
| ------------------- | ---------------------------------------------------------------------------- |
| MAILNAME            | Should match your reverse DNS record                                         |
| POSTMASTER          | Mail address of the system's administrator                                   |
| FILTER_MIME         | Discard mails with suspicious files attached (see [Filters](#Filters))       |
| FILTER_VIRUS        | Discard mails with virus or malware files attached (see [Filters](#Filters)) |
| ENABLE_IMAP         | Enable IMAP4 support                                                         |
| ENABLE_POP3         | Enable POP3 support                                                          |
| ADMIN_USERS         | Mail addresses of users that are allowed to use the manager                  |
| CONTROLLER_PASSWORD | Password for accessing the rspamd web interface                              |

Services
--------
| Service                | Address                      |
| ---------------------- | ---------------------------- |
| POP3 (starttls needed) | 127.0.0.1:110                |
| POP3S                  | 127.0.0.1:995                |
| IMAP (starttls needed) | 127.0.0.1:143                |
| IMAPS                  | 127.0.0.1:993                |
| SMTP (starttls needed) | 127.0.0.1:25                 |
| Management Interface   | http://127.0.0.1:81/manager/ |
| Webmail                | http://127.0.0.1:81/webmail/ |
| Rspamd Webinterface    | http://127.0.0.1:81/rspamd/  |

Default accounts
----------------
| Username          | Password |
| ----------------- | -------- |
| admin@example.com | changeme |

You can create or edit accounts via the management interface (see above).
Passwords can also be edited via webmail. 

Installation (advanced setup)
-----------------------------
This paragraph describes different advanced configuration scenarios. It requires some knowledge
about docker-compose.

### Use your own TLS certificates
1. Remove the `ssl` service from `docker-compose.yml`, by removing the entire block.
2. Uncomment the volume notations in the `mta` and `mda` blocks, delete the data-tls mounts:
   ```
    mta:
      image: jeboehm/mailserver-mta:latest
      ...
      volumes:
        - /home/user/certs/mail.example.com.crt:/media/tls/mailserver.crt:ro
        - /home/user/certs/mail.example.com.key:/media/tls/mailserver.key:ro

    mda:
      image: jeboehm/mailserver-mda:latest
      ...
      volumes:
        - data-mail:/var/vmail
        - /home/user/certs/mail.example.com.crt:/media/tls/mailserver.crt:ro
        - /home/user/certs/mail.example.com.key:/media/tls/mailserver.key:ro
   ```
3. Delete the `data-tls` volume from the volumes section by removing the entire block.

### Use an already running MySQL instance
1. Remove the `db` service from `docker-compose.yml`, by removing the entire block.
2. Remove the `MYSQL_ROOT_PASSWORD` variable from the `.env` file.
3. Add a `MYSQL_HOST` variable to the `.env` file, change it so that it points to your MySQL host, `127.0.0.1` for example.
4. Change `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` so they matches your credentials.
5. Import the both `.sql` files in `db/rootfs/docker-entrypoint-initdb.d`.

If your MySQL instance also runs in Docker, be aware that it needs to be connected to your mail network, since docker-compose creates a new one for each project.
You can do so by executing for example ```docker network connect mail_default mysql```.

### Use the web service behind nginx-proxy
1. Uncomment the environment variable VIRTUAL_HOST from `docker-compose.yml`:
   ```
    web:
      image: jeboehm/mailserver-web:latest
      ...
      environment:
        - VIRTUAL_HOST=mail.example.com
   ```
2. Change the variable to the (sub-) domain you want to use.
3. Remove the `web` service port definition from `docker-compose.production.yml`.

### Use autoheal to restart unhealthy containers
Autoheal is a Docker image that automatically restarts containers that are marked unhealthy.
docker-mailserver tests itself regulary by using the healthcheck feature of Docker. When a test
fails, the container state changes to unhealthy.

You can create and start the Autoheal container by running the following command:

```
docker run \
	-d --name autoheal \
	-e AUTOHEAL_CONTAINER_LABEL=all \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	-m 32M \
	--restart=always \
	--net=none \
	willfarrell/autoheal
```

### Disable malware scanning
1. Set the `FILTER_VIRUS` variable in `.env` file to `FALSE`.
2. Remove the virus service by deleting the entire block in `docker-compose.yml`.

### Use advanced malware signatures
1. Uncomment the `virus_unof_sig_updater` definition in `docker-compose.yml`:
   ```
    virus_unof_sig_updater:
      build: ./virus/contrib/unofficial-sigs
      env_file: .env
      volumes_from:
        - virus
   ```
2. Run `docker-compose build virus_unof_sig_updater` to build the image.
3. Run `docker-compose up virus_unof_sig_updater` regulary (e.g. by adding a cronjob).

Technical details
=================
Filters
------------
By default, spam is filtered by [rspamd](https://rspamd.com/).

| Method                                                               | Variable            |
| -------------------------------------------------------------------- | ------------------- |
| rspamd                                                               | -                   |
| ClamAV virus & malware filtering                                     | FILTER_VIRUS        |
| Block attachments by type (bat, com, exe, dll, vbs, docm, doc, dzip) | FILTER_MIME         |

Volume Management (Where are my files?)
---------------------------------------
Docker manages the data volumes. The first startup creates four volumes, named data-db, -mail, -tls and -filter.
Run `docker volume inspect <name>` to get their real path in the filesystem.

TLS certificates
----------------
The TLS certificate is stored in the data-tls volume. Obtain its path by running `docker volume inspect`
and replace the autogenerated certificate with a real one. You can also mount a certificate directly by uncommenting
the relevant lines in docker-compose.yml.

Override container configuration
--------------------------------
Container configurations can be overridden by creating the file `docker-compose.override.yml` in the root folder.
The startup script will load it automatically.

If you need further assistance, check the [docker-compose](https://docs.docker.com/compose/) manual.

Component overview
------------------
| Servicename | Software                    | Description                                               |
| ----------- | --------------------------- | --------------------------------------------------------- |
| db          | MySQL                       | Datastorage for webmail and mail users and their aliases  |
| filter      | rspamd                      | Spam filtering and greylisting                            |
| mda         | Dovecot                     | Provides IMAP and POP3, handles incoming mail with sieve  |
| mta         | Postfix                     | Transfers incoming and outgoing mail                      |
| ssl         | openssl                     | Creates a self signed certificate if none is provided     |
| test        | Bats                        | Runs integration tests, only used for developing          |
| virus       | ClamAV                      | Virus filter                                              |
| web         | Roundcube, mailserver-admin | Provides an management interface and webmail tool         |
