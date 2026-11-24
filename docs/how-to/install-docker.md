# How to Install with Docker Compose

This guide describes how to install docker-mailserver using Docker Compose.

For a first installation with more explanation, see the [Getting Started tutorial](../tutorials/getting-started.md).

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

Set at least `DB_PASSWORD`, `REDIS_PASSWORD`, `CONTROLLER_PASSWORD`, and `DOVEADM_API_KEY`. See [Environment variables reference](../reference/environment-variables.md).

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

- Management: `http://127.0.0.1:81/`
- Webmail: `http://127.0.0.1:81/webmail/`

## Post-installation

- Configure DNS (MX, SPF, DKIM, DMARC). See [How to configure DNS](configure-dns.md) and [DNS records reference](../reference/dns-records.md).
- Replace self-signed TLS with valid certificates. See [How to configure TLS certificates](configure-tls.md).
- Restrict the published ports, see [Binding and exposure](../reference/ports.md#binding-and-exposure), and back up the volumes listed in the [Service architecture reference](../reference/service-architecture.md#persistent-volumes).

## Troubleshooting

- **Services not starting:** Check logs with `bin/production.sh logs`.
- **Database errors:** Verify `DB_*` and database accessibility.
- **TLS issues:** See [How to configure TLS certificates](configure-tls.md#requirements).
- **Port conflicts:** Free the host ports listed in the [Ports reference](../reference/ports.md).
