# How to Use an External MySQL Database

docker-mailserver can use an external MySQL (or compatible) database instead of the included database service. Use this for production, Kubernetes, or when reusing existing MySQL infrastructure.

## Steps

### 1. Create the database and user

On the MySQL server:

```sql
CREATE DATABASE mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Create a user with access to that database and set a password.

### 2. Import the schema

Import the mailserver and webmail schema from the project:

```bash
mysql -h your-mysql-host -u root -p mailserver < target/db/rootfs/docker-entrypoint-initdb.d/001_mailserver.sql
mysql -h your-mysql-host -u root -p mailserver < target/db/rootfs/docker-entrypoint-initdb.d/002_webmail.sql
```

Adjust host, user, and paths as needed.

### 3. Configure environment variables

In `.env`:

```bash
MYSQL_HOST=your-mysql-host.example.com
MYSQL_DATABASE=mailserver
MYSQL_USER=mailserver_user
MYSQL_PASSWORD=your_secure_password
```

### 4. Remove or exclude the database service (Docker Compose)

If using Docker Compose, remove or do not include the `db` service (e.g. comment out or omit `deploy/compose/db.yaml`). Remove `depends_on: db` from services that referenced it so they use the external host instead.

### 5. Restart the web service

Restart the web service so it connects to the external database and runs any migrations:

- Docker: `bin/production.sh restart web` or `docker-compose restart web`
- Kubernetes: `kubectl rollout restart deployment/web -n mail`

## Kubernetes

Kustomize does not include a database service; you must provide an external MySQL (or compatible) database and set `MYSQL_*` in your ConfigMap/Secrets as above.

For variable reference, see [Environment variables reference](../reference/environment-variables.md) (Database section).
