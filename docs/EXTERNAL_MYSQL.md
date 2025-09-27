# External MySQL Configuration

## Overview

The `docker-mailserver` can be configured to use an external MySQL database instead of the built-in database service. This is particularly useful for production deployments, Kubernetes environments, or when you want to use an existing MySQL infrastructure.

## Environment Variables

To use an external MySQL database, configure the following environment variables in your `.env` file:

```bash
# External MySQL Configuration
MYSQL_HOST=your-mysql-host.example.com
MYSQL_DATABASE=mailserver
MYSQL_USER=mailserver_user
MYSQL_PASSWORD=your_secure_password
```

### Variable Descriptions

- **MYSQL_HOST**: The hostname or IP address of your MySQL server
- **MYSQL_DATABASE**: The database name to use (will be created if it doesn't exist)
- **MYSQL_USER**: The MySQL username for database access
- **MYSQL_PASSWORD**: The password for the MySQL user

## Database Initialization

### Required SQL Files

The mailserver requires two SQL initialization files to be imported into your external MySQL database:

1. **`target/db/rootfs/docker-entrypoint-initdb.d/001_mailserver.sql`** - Core mailserver schema
2. **`target/db/rootfs/docker-entrypoint-initdb.d/002_webmail.sql`** - Webmail-specific schema

### Import Process

#### Option 1: Manual Import

1. **Connect to your MySQL server**:

   ```bash
   mysql -h your-mysql-host.example.com -u root -p
   ```

2. **Create the database** (if it doesn't exist):

   ```sql
   CREATE DATABASE mailserver CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **Import the SQL files**:
   ```bash
   mysql -h your-mysql-host.example.com -u root -p mailserver < target/db/rootfs/docker-entrypoint-initdb.d/001_mailserver.sql
   mysql -h your-mysql-host.example.com -u root -p mailserver < target/db/rootfs/docker-entrypoint-initdb.d/002_webmail.sql
   ```

#### Option 2: Using Docker

If you have the SQL files locally, you can use Docker to import them:

```bash
# Import mailserver schema
docker run --rm -v $(pwd)/target/db/rootfs/docker-entrypoint-initdb.d:/sql mysql:lts mysql -h your-mysql-host.example.com -u root -p mailserver < /sql/001_mailserver.sql

# Import webmail schema
docker run --rm -v $(pwd)/target/db/rootfs/docker-entrypoint-initdb.d:/sql mysql:lts mysql -h your-mysql-host.example.com -u root -p mailserver < /sql/002_webmail.sql
```

## Docker Compose Configuration

### Removing the Built-in Database

To use an external MySQL database with Docker Compose, remove the database service:

1. **Edit `deploy/compose/db.yaml`**:

   ```yaml
   # Comment out or remove the entire db service
   # services:
   #   db:
   #     image: mysql:lts
   #     restart: on-failure:5
   #     env_file: ../../.env
   #     volumes:
   #       - ../../target/db/rootfs/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d:ro
   #       - data-db:/var/lib/mysql
   ```

2. **Update service dependencies**:
   - Remove `depends_on: - db` from services that depend on the database
   - The services will connect to the external MySQL host instead

### Example Configuration

```yaml
# In your docker-compose.yml or compose override
services:
  web:
    environment:
      - MYSQL_HOST=your-mysql-host.example.com
      - MYSQL_DATABASE=mailserver
      - MYSQL_USER=mailserver_user
      - MYSQL_PASSWORD=your_secure_password
    # Remove depends_on: db if present
```

## Kubernetes Configuration

External MySQL is **required** for Kubernetes deployments, as the provided kustomization does not include a database service.

### Prerequisites

1. **Existing MySQL Server**: Ensure you have a MySQL-compatible database (MySQL, Percona XtraDB, MariaDB)
2. **Database Access**: Verify network connectivity from your Kubernetes cluster to the MySQL server
3. **Credentials**: Create a MySQL user with appropriate permissions

## Database Migrations

After importing the initial SQL files, you need to restart the web service to apply any database migrations:

### Docker Compose

```bash
# Restart the web service to apply migrations
docker-compose restart web

# Or if using the production script
bin/production.sh restart web
```

### Kubernetes

```bash
# Restart the web deployment
kubectl rollout restart deployment/web -n mail
```
