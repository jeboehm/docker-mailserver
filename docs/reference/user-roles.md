# User Roles Reference

mailserver-admin defines three roles with different permissions.

## Admin

- Manage all domains, users, aliases, and DKIM
- Full access to all features

## Domain Admin

- Manage users, aliases, and fetchmail within their assigned domain only
- Cannot add, edit, or delete domains
- Cannot manage DKIM
- Cannot change what belongs to an admin, see [Protections for admins](#protections-for-admins)

## User

- Log in to the application
- Manage own fetchmail accounts
- Change own password (subject to password policy)
- Cannot manage users, aliases, or domains
- No access to DKIM or domain configuration

## Protections for admins

A domain admin can see everything below, but cannot change it. Only an admin can. The rules are the same in the web interface and the [MCP server](mcp-server.md).

| Object                                                            | Domain admin can   | Domain admin cannot                                                                                                                 |
| ----------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| A user with the admin flag in their domain                        | Read it            | Change or delete it, including resetting its password or disabling it                                                               |
| Fetchmail accounts owned by an admin                              | List and read them | Create, edit or delete them, or assign an account to an admin. Admins do not appear in the owner choices                            |
| Aliases whose address is an admin's address (`admin@example.com`) | List and read them | Create, edit or delete them, or rename another alias onto that address                                                              |
| Aliases whose destination is an admin's address                   | List and read them | Create, edit or delete them, or change an alias so that its destination is an admin's address. The destination may be on any domain |

Details of the alias rules:

- The destination check ignores the [address extension](local-address-extension.md): with the default `RECIPIENT_DELIMITER=-`, `admin-sales@example.com` counts as `admin@example.com` when that address belongs to an admin, whether or not a user `admin-sales` exists. An empty delimiter turns the stripping off.
- Aliases that chain through other aliases are not followed. An alias to another alias that leads to an admin is allowed.
- Aliases that already point at an admin are not changed on upgrade. They become read-only for domain admins, including those the domain admin created earlier, so an admin has to fix or delete them. See the [upgrade changelog](upgrade-changelog.md#next-release).
- A domain admin therefore cannot forward mail to a colleague who has the admin flag.

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

The same rules as in the web interface apply: only admins can set `admin` or choose a domain, the [protections for admins](#protections-for-admins) apply, users cannot change their own role or `enabled` state or delete themselves, and only empty domains can be deleted. Mail tools refuse disabled users, and the read tools also refuse send-only users.

| API tokens           | Admin | Domain Admin | User |
| -------------------- | ----- | ------------ | ---- |
| Create for oneself   | yes   | yes          | yes  |
| See and revoke own   | yes   | yes          | yes  |
| See and revoke other | all   | own domain   | no   |
