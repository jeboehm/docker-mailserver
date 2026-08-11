# How to Use an External Database

docker-mailserver can use an external database instead of the included database service. Use this
for production, Kubernetes, or when reusing existing database infrastructure. MySQL/MariaDB and
PostgreSQL are both supported.

## Steps

### 1. Create the database and user

On MySQL:

```sql
CREATE DATABASE mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

On PostgreSQL:

```sql
CREATE DATABASE mailserver ENCODING 'UTF8';
```

Create a user with access to that database and set a password. The user needs DDL privileges
(`CREATE`, `ALTER`, `DROP`, `INDEX`), because the web service creates the tables itself on first
start and migrates them afterwards. No schema import is needed on either engine.

### 2. Configure environment variables

In `.env`, for MySQL:

```bash
DB_HOST=your-database-host.example.com
DB_NAME=mailserver
DB_USER=mailserver_user
DB_PASSWORD=your_secure_password
```

For PostgreSQL:

```bash
DB_DRIVER=pgsql
DB_HOST=your-database-host.example.com
DB_PORT=5432
DB_NAME=mailserver
DB_USER=mailserver_user
DB_PASSWORD=your_secure_password
DB_SERVER_VERSION=18
```

Set `DB_SERVER_VERSION` to the major version of your server.

### 3. Remove or exclude the database service (Docker Compose)

If using Docker Compose, remove or do not include the `db` service (e.g. comment out or omit `deploy/compose/db.yaml`). Remove `depends_on: db` from services that referenced it so they use the external host instead.

### 4. Restart the web service

Restart the web service. It connects to the external database, creates the schema if the database is
empty, and applies any pending migrations:

- Docker: `bin/production.sh restart web` or `docker-compose restart web`
- Kubernetes: `kubectl rollout restart deployment/web -n mail`

## Kubernetes

Kustomize does not include a database service; you must provide an external database and set the
`DB_*` variables in your ConfigMap/Secrets as above.

For variable reference, see [Environment variables reference](../reference/environment-variables.md) (Database section).
For the differences between the two engines, see [Database backends](../explanation/database-backends.md).
