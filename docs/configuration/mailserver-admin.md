# mailserver-admin configuration

## OAuth2

To use OAuth2, you need to create a new OAuth2 client in your OAuth2 provider. The redirect URI should be
`https://example.com/login/check-oauth`. The client ID and client secret should be added to the `.env` file.

Depending on your needs, you can configure `mailserver-admin` to give admin rights to a user by testing for a specific group in the groups
field of the OAuth user information. Set the name of your administrator group to the `OAUTH_ADMIN_GROUP` variable in the `.env` file. If you
leave `OAUTH_ADMIN_GROUP` empty, all authenticated users will have admin rights. You must make sure to handle the login permissions in your
OAuth2 provider.

### OAuth2 configuration example

```bash
OAUTH_ENABLED=true
OAUTH_CLIENT_ID=xxxxx-xxxx-xxxx-xxxx-xxxxxxx
OAUTH_CLIENT_SECRET=xxxxxxxxxxxxx
OAUTH_CLIENT_SCOPES="email profile groups"
OAUTH_AUTHORIZATION_URL=https://id.example.com/authorize
OAUTH_ACCESS_TOKEN_URL=https://id.example.com/api/oidc/token
OAUTH_INFOS_URL=https://id.example.com/api/oidc/userinfo
OAUTH_BUTTON_TEXT="Login with OIDC"
OAUTH_ADMIN_GROUP=admin
OAUTH_PATHS_IDENTIFIER=sub
```

## Environment variables

The following environment variables can be set in the `.env` file or in the environment:

### General

- `APP_ENV`: The environment the application is running in. Default: `prod`
- `APP_SECRET`: A secret key used by Symfony for various purposes (e.g., CSRF tokens). Default: `randomly generated`.
- `CSRF_ENABLED`: Whether CSRF protection is enabled. Default: `true`.
- `TRUSTED_PROXIES`: A list of trusted proxy IP addresses.

### Database

- `MYSQL_USER`: The MySQL database user.
- `MYSQL_PASSWORD`: The MySQL database password.
- `MYSQL_HOST`: The MySQL database host.
- `MYSQL_DATABASE`: The MySQL database name.
- `REDIS_HOST`: The Redis server host.
- `REDIS_PORT`: The Redis server port.
- `REDIS_PASSWORD`: The Redis server password.

### OAuth2

- `OAUTH_ENABLED`: Whether OAuth2 is enabled. Default: `false`.
- `OAUTH_CLIENT_ID`: The client ID for the OAuth2 provider.
- `OAUTH_CLIENT_SECRET`: The client secret for the OAuth2 provider.
- `OAUTH_CLIENT_SCOPES`: The scopes requested from the OAuth2 provider. Default: `"email profile groups"`.
- `OAUTH_AUTHORIZATION_URL`: The authorization URL for the OAuth2 provider.
- `OAUTH_ACCESS_TOKEN_URL`: The access token URL for the OAuth2 provider.
- `OAUTH_INFOS_URL`: The user information URL for the OAuth2 provider.
- `OAUTH_ADMIN_GROUP`: The name of the administrator group in the OAuth2 provider.
- `OAUTH_BUTTON_TEXT`: The text displayed on the OAuth2 login button. Default: `"Login with OIDC"`.
