# How to Configure PHP Sessions

The web service stores PHP sessions in Redis by default. You can switch to file-based or another handler via environment variables.

## Redis (default)

No change needed if Redis is available. Default:

```bash
PHP_SESSION_SAVE_HANDLER=redis
PHP_SESSION_SAVE_PATH=tcp://${REDIS_HOST}:${REDIS_PORT}?auth=${REDIS_PASSWORD}
```

## File-based sessions

To use the filesystem instead:

1. Set in `.env` (or environment):

```bash
PHP_SESSION_SAVE_HANDLER=files
PHP_SESSION_SAVE_PATH=/tmp/sessions
```

2. Mount a volume for the session directory so it persists and is writable:

```yaml
volumes:
  - session_data:/tmp/sessions
```

3. Restart the web service.

For variable reference, see [Environment variables reference](../reference/environment-variables.md) (PHP Sessions).
