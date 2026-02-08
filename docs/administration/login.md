# Login

The login page authenticates users to the mailserver-admin interface. Authentication methods are local (email + password) or OAuth2, depending on configuration.

![Login](../images/admin/login.png)

## Authentication methods

### Local authentication

By default, users log in with their mailserver email address and password.

### OAuth2

When OAuth2 is enabled, an OAuth2 login button is shown. Users can sign in via an external identity provider. OAuth2 is typically used to grant admin rights based on group membership. For setup, see [How to configure OAuth2](../how-to/configure-oauth2.md). For OAuth2 variables, see [mailserver-admin configuration reference](../reference/mailserver-admin-config.md#oauth2).
