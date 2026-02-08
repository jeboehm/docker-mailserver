# How to Configure OAuth2 Login

mailserver-admin can use OAuth2/OIDC for login. When enabled, users sign in via an external identity provider instead of (or in addition to) local credentials. OAuth2 is typically used to grant admin rights based on group membership.

## Steps

### 1. Create an OAuth2 client in your identity provider

Create a client with:

- **Redirect URI:** `https://your-domain/login/check-oauth` (use your actual domain)
- **Client ID** and **Client secret** for use in `.env`

### 2. Set environment variables

In `.env` (or the environment):

```bash
OAUTH_ENABLED=true
OAUTH_CLIENT_ID=your-client-id
OAUTH_CLIENT_SECRET=your-client-secret
OAUTH_AUTHORIZATION_URL=https://id.example.com/authorize
OAUTH_ACCESS_TOKEN_URL=https://id.example.com/api/oidc/token
OAUTH_INFOS_URL=https://id.example.com/api/oidc/userinfo
OAUTH_BUTTON_TEXT="Login with OIDC"
OAUTH_ADMIN_GROUP=admin
OAUTH_PATHS_IDENTIFIER=sub
OAUTH_CREATE_USER=false
```

Adjust URLs, scopes, and button text to match your provider.

### 3. Configure the user identifier

`OAUTH_PATHS_IDENTIFIER` must point to a field in the provider’s userinfo that contains an email address that exists as a user in the mailserver (same domain). The field should be write-protected in the provider so users cannot change it. Do not use a normal “email” claim that users can edit.

### 4. Optional: auto-create users

Set `OAUTH_CREATE_USER=true` to create a mailserver user when someone logs in via OAuth2 and no matching user exists. Use only if your provider guarantees a stable, domain-valid email identifier.

### 5. Restart the web service

Restart the web container so the new variables are loaded. A login button for OAuth2 will appear on the login page.

## Flow

1. User clicks the OAuth2 login button and is redirected to the provider.
2. After authentication, the provider redirects back to `/login/check-oauth`.
3. The application reads userinfo and takes the identifier from `OAUTH_PATHS_IDENTIFIER`.
4. If the identifier matches an existing user, that user is logged in. If `OAUTH_ADMIN_GROUP` is set and the user is in that group, they get admin rights.
5. If there is no match and `OAUTH_CREATE_USER=true`, a new user is created; otherwise login is denied.

For all OAuth2 variables, see [mailserver-admin configuration reference](../reference/mailserver-admin-config.md).
