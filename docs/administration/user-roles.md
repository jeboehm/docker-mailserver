# User Roles

In `mailserver-admin`, there are three distinct user roles, each with different levels of access and permissions:

## Admin

**Permissions**: Can perform all actions within the application.

**Capabilities**:

- Manage all mail domains, users, aliases, and DKIM settings
- Full access to all features and configurations

## Domain Admin

**Permissions**: Limited to managing users, aliases, and fetchmail accounts within their own domain.

**Capabilities**:

- Create, update, and remove users within their domain
- Define and manage mail aliases within their domain
- Configure and manage fetchmail accounts within their domain

**Restrictions**:

- Cannot add or edit new domains
- Cannot manage DKIM settings for any domain

## User

**Permissions**: Limited to managing their own fetchmail accounts.

**Capabilities**:

- Login to the application
- Configure and manage their personal fetchmail accounts
- Change their own password with strict password policy

**Restrictions**:

- Cannot manage users, aliases, or domains
- No access to DKIM settings or domain configurations
