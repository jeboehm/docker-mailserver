# mailserver-admin Configuration Reference

Environment variables for the mailserver-admin (web) application. Set in `.env` or the environment.

## General

| Variable          | Default  | Description                       |
| ----------------- | -------- | --------------------------------- |
| `APP_ENV`         | `prod`   | Application environment           |
| `APP_SECRET`      | (random) | Secret key (e.g. CSRF)            |
| `CSRF_ENABLED`    | `true`   | Enable CSRF protection            |
| `TRUSTED_PROXIES` | —        | Comma-separated trusted proxy IPs |

## Database

| Variable         | Description         |
| ---------------- | ------------------- |
| `MYSQL_USER`     | MySQL user          |
| `MYSQL_PASSWORD` | MySQL password      |
| `MYSQL_HOST`     | MySQL host          |
| `MYSQL_DATABASE` | MySQL database name |
| `REDIS_HOST`     | Redis host          |
| `REDIS_PORT`     | Redis port          |
| `REDIS_PASSWORD` | Redis password      |

## OAuth2

| Variable                  | Default                  | Description                                   |
| ------------------------- | ------------------------ | --------------------------------------------- |
| `OAUTH_ENABLED`           | `false`                  | Enable OAuth2 login                           |
| `OAUTH_CLIENT_ID`         | —                        | OAuth2 client ID                              |
| `OAUTH_CLIENT_SECRET`     | —                        | OAuth2 client secret                          |
| `OAUTH_CLIENT_SCOPES`     | `"email profile groups"` | Requested scopes                              |
| `OAUTH_AUTHORIZATION_URL` | —                        | Authorization URL                             |
| `OAUTH_ACCESS_TOKEN_URL`  | —                        | Token URL                                     |
| `OAUTH_INFOS_URL`         | —                        | Userinfo URL                                  |
| `OAUTH_ADMIN_GROUP`       | —                        | Group name for admin rights                   |
| `OAUTH_BUTTON_TEXT`       | `"Login with OIDC"`      | Login button label                            |
| `OAUTH_PATHS_IDENTIFIER`  | `sub`                    | Field containing user identifier (e.g. email) |
| `OAUTH_CREATE_USER`       | `false`                  | Create user if no match                       |

For setting up OAuth2, see [How to configure OAuth2](../how-to/configure-oauth2.md).
