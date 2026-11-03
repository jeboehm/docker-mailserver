# User Roles Reference

mailserver-admin defines three roles with different permissions.

## Admin

- Manage all domains, users, aliases, and DKIM
- Full access to all features

## Domain Admin

- Manage users, aliases, and fetchmail within their assigned domain only
- Can read users with the admin flag in their own domain, but cannot change or delete them, including resetting their password or disabling them. Only admins can change or delete an admin.
- Cannot add, edit, or delete domains
- Cannot manage DKIM

## User

- Log in to the application
- Manage own fetchmail accounts
- Change own password (subject to password policy)
- Cannot manage users, aliases, or domains
- No access to DKIM or domain configuration

## Mailboxes

Through the MCP server, every role reaches only its own mailbox. Admin and Domain Admin grant no access to other people's mail.

## MCP server and API tokens

A call to the [MCP server](mcp-server.md) succeeds only if the API token carries the required [scope](mcp-server.md#scopes) and the owner's current role allows the action on that object. A token never exceeds the role of its owner.

| Tool group                                   | Admin       | Domain Admin | User         |
| -------------------------------------------- | ----------- | ------------ | ------------ |
| Domains: list, create, delete                | all         | no           | no           |
| Users: list, get, create, update, delete     | all         | own domain   | no           |
| Aliases: list, get, create, update, delete   | all         | own domain   | no           |
| Fetchmail: list, get, create, update, delete | all         | own domain   | own accounts |
| DKIM: status, enable, disable, recreate key  | all         | no           | no           |
| DNS validation                               | all domains | own domain   | no           |
| Mail: read, send                             | own mailbox | own mailbox  | own mailbox  |

The same rules as in the web interface apply: only admins can set `admin`, choose a domain, or change or delete a user with the admin flag, users cannot change their own role or `enabled` state or delete themselves, and only empty domains can be deleted. Mail tools refuse disabled users, and the read tools also refuse send-only users.

| API tokens           | Admin | Domain Admin | User |
| -------------------- | ----- | ------------ | ---- |
| Create for oneself   | yes   | yes          | yes  |
| See and revoke own   | yes   | yes          | yes  |
| See and revoke other | all   | own domain   | no   |
