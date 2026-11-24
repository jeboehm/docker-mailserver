# mailserver-admin Configuration Reference

Environment variables for the mailserver-admin (web) application. Set in `.env` or the environment.

## General

| Variable       | Default  | Description             |
| -------------- | -------- | ----------------------- |
| `APP_ENV`      | `prod`   | Application environment |
| `APP_SECRET`   | (random) | Secret key (e.g. CSRF)  |
| `CSRF_ENABLED` | `true`   | Enable CSRF protection  |

`TRUSTED_PROXIES` ([Proxy Protocol](environment-variables.md#proxy-protocol)), the `DB_*` variables ([Database](environment-variables.md#database)), the `REDIS_*` variables ([Redis](environment-variables.md#redis)) and `RECIPIENT_DELIMITER` ([Mail Server Identity](environment-variables.md#mail-server-identity)) are shared with the other services and are described in the [environment variables reference](environment-variables.md).

## OAuth2

| Variable                  | Default                         | Description                                   |
| ------------------------- | ------------------------------- | --------------------------------------------- |
| `OAUTH_ENABLED`           | `false`                         | Enable OAuth2 login                           |
| `OAUTH_CLIENT_ID`         | —                               | OAuth2 client ID                              |
| `OAUTH_CLIENT_SECRET`     | —                               | OAuth2 client secret                          |
| `OAUTH_CLIENT_SCOPES`     | `"openid email profile groups"` | Requested scopes                              |
| `OAUTH_AUTHORIZATION_URL` | —                               | Authorization URL                             |
| `OAUTH_ACCESS_TOKEN_URL`  | —                               | Token URL                                     |
| `OAUTH_INFOS_URL`         | —                               | Userinfo URL                                  |
| `OAUTH_ADMIN_GROUP`       | `admin`                         | Group name for admin rights                   |
| `OAUTH_BUTTON_TEXT`       | `"Login with OIDC"`             | Login button label                            |
| `OAUTH_PATHS_IDENTIFIER`  | `email`                         | Field containing user identifier (e.g. email) |
| `OAUTH_CREATE_USER`       | `false`                         | Create user if no match                       |

For setting up OAuth2, see [How to configure OAuth2](../how-to/configure-oauth2.md).

## MCP server

The `MCP_*` variables and their defaults are listed in the [environment variables reference](environment-variables.md#mcp-server).
