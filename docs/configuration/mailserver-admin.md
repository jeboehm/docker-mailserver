# mailserver-admin configuration

## OAuth2

The `mailserver-admin` application supports OAuth2/OIDC authentication for user login. When OAuth2 is enabled, users authenticate through an external identity provider instead of using local credentials.

### Authentication Flow

1. User clicks the OAuth2 login button and is redirected to the configured identity provider
2. After successful authentication, the provider redirects back to `https://example.com/login/check-oauth`
3. The application retrieves user information from the provider's userinfo endpoint
4. The application extracts the user identifier from the field specified in `OAUTH_PATHS_IDENTIFIER`
5. The application attempts to match this identifier with existing users in the database
6. If a match is found, the user is logged in with their existing account
7. If no match is found and `OAUTH_CREATE_USER` is enabled, a new user account is created automatically
8. If no match is found and `OAUTH_CREATE_USER` is disabled, login is denied

### User Identifier Configuration

The `OAUTH_PATHS_IDENTIFIER` configuration specifies which field from the OAuth2 provider's user information contains the user identifier. This field must contain an email address that matches an existing domain configured in the mailserver.

**Important requirements:**

- The identifier must be a valid email address with a domain that exists in the domain list
- The field must be write-protected in the OAuth2 provider (not user-editable)
- Do not use the standard `email` field from common identity providers, as users can typically change their email address

**Recommended OAuth2 Providers:**

[pocket-id](https://pocket-id.org) is a tested solution that provides write-protected email attributes suitable for this use case. When using pocket-id or similar providers, configure `OAUTH_PATHS_IDENTIFIER` to point to a field that contains the user's email address and cannot be modified by the user.

### Administrator Access Control

Administrator rights can be granted based on the groups claim in the OAuth2 provider. Configure the `OAUTH_ADMIN_GROUP` variable with the name of the administrator group in your identity provider. Users who are members of this group will receive administrator privileges in `mailserver-admin`.

### OAuth2 Client Setup

To use OAuth2, create a new OAuth2 client in your identity provider with the following settings:

- **Redirect URI:** `https://example.com/login/check-oauth` (replace with your actual domain)
- **Client ID and Secret:** Add these values to the `.env` file as `OAUTH_CLIENT_ID` and `OAUTH_CLIENT_SECRET`

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
OAUTH_CREATE_USER=true
```

## Environment variables

The following environment variables can be set in the `.env` file or in the environment:

### General Configuration

- `APP_ENV`: The environment the application is running in. Default: `prod`
- `APP_SECRET`: A secret key used by Symfony for various purposes (e.g., CSRF tokens). Default: `randomly generated`.
- `CSRF_ENABLED`: Whether CSRF protection is enabled. Default: `true`.
- `TRUSTED_PROXIES`: A list of trusted proxy IP addresses.

### Database Configuration

- `MYSQL_USER`: The MySQL database user.
- `MYSQL_PASSWORD`: The MySQL database password.
- `MYSQL_HOST`: The MySQL database host.
- `MYSQL_DATABASE`: The MySQL database name.
- `REDIS_HOST`: The Redis server host.
- `REDIS_PORT`: The Redis server port.
- `REDIS_PASSWORD`: The Redis server password.

### OAuth2 Configuration

- `OAUTH_ENABLED`: Whether OAuth2 is enabled. Default: `false`.
- `OAUTH_CLIENT_ID`: The client ID for the OAuth2 provider.
- `OAUTH_CLIENT_SECRET`: The client secret for the OAuth2 provider.
- `OAUTH_CLIENT_SCOPES`: The scopes requested from the OAuth2 provider. Default: `"email profile groups"`.
- `OAUTH_AUTHORIZATION_URL`: The authorization URL for the OAuth2 provider.
- `OAUTH_ACCESS_TOKEN_URL`: The access token URL for the OAuth2 provider.
- `OAUTH_INFOS_URL`: The user information URL for the OAuth2 provider.
- `OAUTH_ADMIN_GROUP`: The name of the administrator group in the OAuth2 provider.
- `OAUTH_BUTTON_TEXT`: The text displayed on the OAuth2 login button. Default: `"Login with OIDC"`.
- `OAUTH_PATHS_IDENTIFIER`: The path to the identifier in the OAuth2 provider. Default: `"sub"`.
- `OAUTH_CREATE_USER`: Whether to create a new user if no match is found in the database. Default: `false`.
