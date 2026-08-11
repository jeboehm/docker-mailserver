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

Create a user with access to that database and set a password.

### 2. Import the schema

On MySQL, import the mailserver and webmail schema from the project:

```bash
mysql -h your-database-host -u root -p mailserver < target/db/mysql/initdb.d/001_mailserver.sql
mysql -h your-database-host -u root -p mailserver < target/db/mysql/initdb.d/002_webmail.sql
```

Adjust host, user, and paths as needed.

On PostgreSQL, skip this step. The web service creates the schema through migrations, and
Roundcube creates its own tables on first start.

### 3. Configure environment variables

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

### 4. Remove or exclude the database service (Docker Compose)

If using Docker Compose, remove or do not include the `db` service (e.g. comment out or omit `deploy/compose/db.yaml`). Remove `depends_on: db` from services that referenced it so they use the external host instead.

### 5. Restart the web service

Restart the web service so it connects to the external database and runs any migrations:

- Docker: `bin/production.sh restart web` or `docker-compose restart web`
- Kubernetes: `kubectl rollout restart deployment/web -n mail`

## Kubernetes

Kustomize does not include a database service; you must provide an external database and set the
`DB_*` variables in your ConfigMap/Secrets as above.

For variable reference, see [Environment variables reference](../reference/environment-variables.md) (Database section).
For the differences between the two engines, see [Database backends](../explanation/database-backends.md).
