# How to Configure PHP Sessions

`PHP_SESSION_SAVE_HANDLER` and `PHP_SESSION_SAVE_PATH` set PHP's session handler for Roundcube's PHP side. You can switch from Redis to file-based or another handler.

These variables do not affect mailserver-admin. Since mailserver-admin 5.20.0, it keeps admin logins and MCP sessions in Redis through its own handler (`REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`), so you cannot move them with these variables.

They set PHP's default handler only. Roundcube keeps its own login sessions as its `session_storage` setting says, which this image leaves at Roundcube's default of `db`.

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

To see what changed for installations with custom values, see the [upgrade changelog](../reference/upgrade-changelog.md#mailserver-admin-php_session_-no-longer-apply).

For variable reference, see [Environment variables reference](../reference/environment-variables.md#php-sessions).
