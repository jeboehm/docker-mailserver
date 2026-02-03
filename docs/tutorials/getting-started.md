# Getting Started

This tutorial walks you through installing docker-mailserver with Docker Compose and creating your first mailbox. By the end you will have a running mailserver and access to the management interface.

**What we will do:** Configure the environment, start the services, run the setup wizard, and log in to the management interface.

## Prerequisites

- Docker and Docker Compose installed
- A domain name (for later DNS configuration)
- Ports 25, 110, 143, 587, 993, 995, 81 available

## Step 1: Obtain the project

Download the latest release from the [Releases](https://github.com/jeboehm/docker-mailserver/releases) page and unpack the archive (`release-vX.X.X.tar.gz`), or clone the repository:

```bash
git clone https://github.com/jeboehm/docker-mailserver.git
cd docker-mailserver
```

Do not use the `latest` container image tag for production. Use a specific version tag (e.g. `jeboehm/mailserver-mta:6.3`).

## Step 2: Configure environment variables

Copy the example environment file:

```bash
cp .env.dist .env
```

Edit `.env` and set at least:

- `MYSQL_PASSWORD` (required when using the included database)
- `REDIS_PASSWORD` (required when using the included Redis)
- `CONTROLLER_PASSWORD` (required for Rspamd)
- `DOVEADM_API_KEY` (required for Dovecot API)

For a full list of variables, see [Environment variables reference](../reference/environment-variables.md).

## Step 3: Pull and start services

Pull the container images:

```bash
bin/production.sh pull
```

Start all services and wait for them to be ready:

```bash
bin/production.sh up -d --wait
```

You should see the containers start. Wait until health checks pass. You can check status with `bin/production.sh ps`.

## Step 4: Run the setup wizard

Run the setup script to create your first account and an admin user:

```bash
bin/production.sh run --rm web setup.sh
```

The wizard will ask for configuration details, create your first email address, and create an admin user for the management interface. Follow the prompts.

## Step 5: Open the management interface

Open a browser and go to:

- **Management interface:** `http://127.0.0.1:81/manager/`
- **Webmail:** `http://127.0.0.1:81/webmail/`

Log in with the admin credentials you set in the wizard. You should see the dashboard.

## Step 6: Check the dashboard

On the dashboard you will see an overview of the mailserver: domains, users, and quick links. From here you can add domains, users, and aliases.

## Next steps

- Configure DNS records for your domain so other servers can deliver mail to you. See [DNS records reference](../reference/dns-records.md) and [How to configure DNS](../how-to/configure-dns.md).
- Replace self-signed TLS certificates with valid certificates. See [How to configure TLS certificates](../how-to/configure-tls.md).
- Add more users or domains via the management interface. See the [Administration how-to guides](../how-to/manage-domains.md).

For a list of exposed ports and services, see [Ports reference](../reference/ports.md).
