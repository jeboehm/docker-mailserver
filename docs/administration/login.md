# Login

The login page provides authentication to access the `mailserver-admin` interface. Users can authenticate using either regular email address and password credentials and OAuth2, depending on the configuration.

![Login](../images/admin/login.png)

## Authentication Methods

### Local Authentication

By default, users authenticate using their email address and password configured in the mailserver.

### OAuth2 Authentication

OAuth2 authentication can be enabled to allow users to log in using an external identity provider. When OAuth2 is enabled, a login button appears on the login page. Currently, this is only useful for granting admin rights to users.

For OAuth2 configuration options, see [mailserver-admin configuration](../configuration/mailserver-admin.md#oauth2).
