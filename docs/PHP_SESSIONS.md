# PHP Session Configuration

This document explains how to configure PHP sessions in the docker-mailserver project, including both Redis and file-based session storage options.

## Overview

The web service supports configurable PHP session storage through environment variables. By default, sessions are stored in Redis, but you can easily switch to file-based storage or other session handlers.

## Environment Variables

| Variable                   | Default                                                    | Description          |
| -------------------------- | ---------------------------------------------------------- | -------------------- |
| `PHP_SESSION_SAVE_HANDLER` | `redis`                                                    | Session save handler |
| `PHP_SESSION_SAVE_PATH`    | `tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}` | Session save path    |

## Session Storage Options

### Redis Sessions (Default)

Redis is the default session storage mechanism, providing fast, scalable session management.

**Configuration:**

```bash
PHP_SESSION_SAVE_HANDLER=redis
PHP_SESSION_SAVE_PATH=tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}
```

### File-Based Sessions

Store sessions as files on the local filesystem.

**Configuration:**

```bash
PHP_SESSION_SAVE_HANDLER=files
PHP_SESSION_SAVE_PATH=/tmp/sessions
```

## Implementation Examples

### Docker Compose Configuration

**Redis Sessions (Default):**

```yaml
services:
  web:
    environment:
      - PHP_SESSION_SAVE_HANDLER=redis
      - PHP_SESSION_SAVE_PATH=tcp://redis:6379?auth=${REDIS_PASSWORD}
    depends_on:
      - redis
```

**File-Based Sessions:**

```yaml
services:
  web:
    environment:
      - PHP_SESSION_SAVE_HANDLER=files
      - PHP_SESSION_SAVE_PATH=/tmp/sessions
    volumes:
      - session_data:/tmp/sessions
```

## PHP Configuration

The session configuration is applied through the PHP configuration file at:
`target/web/rootfs/usr/local/etc/php/conf.d/zzz_app.ini`

```ini
session.save_handler = ${PHP_SESSION_SAVE_HANDLER}
session.save_path = "${PHP_SESSION_SAVE_PATH:-tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}}"
```

This configuration:

- Uses the `PHP_SESSION_SAVE_HANDLER` environment variable
- Falls back to Redis configuration if `PHP_SESSION_SAVE_PATH` is not set
