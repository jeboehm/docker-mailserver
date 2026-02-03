# User Roles Reference

mailserver-admin defines three roles with different permissions.

## Admin

- Manage all domains, users, aliases, and DKIM
- Full access to all features

## Domain Admin

- Manage users, aliases, and fetchmail within their assigned domain only
- Cannot add, edit, or delete domains
- Cannot manage DKIM

## User

- Log in to the application
- Manage own fetchmail accounts
- Change own password (subject to password policy)
- Cannot manage users, aliases, or domains
- No access to DKIM or domain configuration
