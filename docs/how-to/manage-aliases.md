# How to Manage Aliases

Aliases forward incoming mail from one address to one or more destinations (local users or external addresses). **Admin** can manage all aliases; **Domain Admin** only aliases in their domain; **User** cannot manage aliases.

## Add an alias

1. Log in to the management interface.
2. Open **Alias** in the menu.
3. Click **Add Alias**.
4. Enter:
   - **Source Address:** Local part + domain (e.g. `info@example.com`). Leave the local part empty for a catch-all alias.
   - **Destination Address(es):** One or more addresses to forward to.
5. Save.

The source must belong to an existing domain. Destinations can be local users or external addresses. You can create multiple aliases with the same source and different destinations to forward to several recipients.

![Alias Create](../images/admin/alias_create.png)

## Edit an alias

1. Open **Alias** in the menu.
2. Select the alias.
3. Change source or destination(s).
4. Save.

## Delete an alias

1. Open **Alias** in the menu.
2. Select the alias.
3. Confirm deletion.

Deleting an alias only removes the forwarding rule; it does not delete user accounts or mail.

## Examples

- Generic addresses: `info@example.com` → `team@example.com`; `support@example.com` → `support1@example.com, support2@example.com`.
- Personal: `john.doe@example.com` → `john.doe@gmail.com`.
- Distribution: `announcements@example.com` → `user1@example.com, user2@example.com`.

For access control, see [User roles reference](../reference/user-roles.md).
