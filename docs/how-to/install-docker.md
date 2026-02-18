# How to Install with Docker Compose

This guide describes how to install docker-mailserver using Docker Compose.

If you are setting up docker-mailserver for the first time, the [Getting Started tutorial](../tutorials/getting-started.md) provides a step-by-step walkthrough that covers these same steps with more explanation.

## Prerequisites

- Docker and Docker Compose installed on the host
- A domain name
- Root or sudo access on the host

## Steps

### 1. Configure environment variables

Copy the example environment file and edit `.env`:

```bash
cp .env.dist .env
```

Set at least `MYSQL_PASSWORD`, `REDIS_PASSWORD`, `CONTROLLER_PASSWORD`, and `DOVEADM_API_KEY`. See [Environment variables reference](../reference/environment-variables.md).

### 2. Pull images

```bash
bin/production.sh pull
```

### 3. Start services

```bash
bin/production.sh up -d --wait
```

### 4. Run setup wizard

```bash
bin/production.sh run --rm web setup.sh
```

Follow the wizard to create your first account and admin user.

### 5. Access the management interface

- Management: `http://127.0.0.1:81/manager/`
- Webmail: `http://127.0.0.1:81/webmail/`

## Post-installation

- Configure DNS (MX, SPF, DKIM, DMARC). See [How to configure DNS](configure-dns.md) and [DNS records reference](../reference/dns-records.md).
- Replace self-signed TLS with valid certificates. See [How to configure TLS certificates](configure-tls.md).
- Configure firewall, backups, and monitoring as needed.

## Troubleshooting

- **Services not starting:** Check logs with `docker-compose logs` or `bin/production.sh logs`.
- **Database errors:** Verify `MYSQL_*` and database accessibility.
- **TLS issues:** Check certificate paths and permissions.
- **Port conflicts:** Ensure ports 25, 110, 143, 587, 993, 995, 81 are free.

For port details, see [Ports reference](../reference/ports.md).
