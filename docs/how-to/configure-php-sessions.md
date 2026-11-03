# How to Configure PHP Sessions

`PHP_SESSION_SAVE_HANDLER` and `PHP_SESSION_SAVE_PATH` set PHP's session handler for Roundcube's PHP side. You can switch from Redis to file-based or another handler.

These variables do not affect mailserver-admin. Since the release that adds the MCP server, it keeps admin logins and MCP sessions in Redis through its own handler, so you cannot move them with these variables and changing them does not log anyone out of the management interface.

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

## After upgrading with custom values

If you had set custom values, users are expected to have to log in to the management interface once after upgrading, because admin logins are now looked up in Redis. This follows from how the session store changed; no upgrade of a running installation has been tested. See [Upgrade changelog](../reference/upgrade-changelog.md).

For variable reference, see [Environment variables reference](../reference/environment-variables.md#php-sessions).
