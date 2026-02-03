# How to Manage Fetchmail Accounts

Fetchmail retrieves mail from external servers (POP3/IMAP) and delivers it to local mailboxes. **Admin** can manage all fetchmail accounts; **Domain Admin** only for users in their domain; **User** only their own accounts.

## Add a fetchmail account

1. Log in to the management interface.
2. Open **Fetchmail** in the menu.
3. Click **Add Fetchmail Account**.
4. Enter:
   - **User:** Local user that will receive the mail
   - **Server:** Hostname or IP of the external mail server
   - **Port:** 110 (POP3), 143 (IMAP), 995 (POP3S), 993 (IMAPS)
   - **Protocol:** POP3 or IMAP
   - **Username** and **Password** for the external server
   - **SSL** and **SSL Verify** as needed
5. Save.

![Fetchmail Create](../images/admin/fetchmail_create.png)

## Edit a fetchmail account

1. Open **Fetchmail** in the menu.
2. Select the account.
3. Change server, port, protocol, credentials, or SSL settings.
4. Save.

The “Last run log” field shows the last transaction with the external server and helps with troubleshooting.

## Delete a fetchmail account

1. Open **Fetchmail** in the menu.
2. Select the account.
3. Confirm deletion.

Deleting stops retrieval; mail already delivered to the local mailbox is not removed.

## Security

- Use strong, unique passwords for external accounts.
- Enable SSL to protect credentials in transit.
- Review and disable unused fetchmail accounts.
- Ensure the mailserver can reach the external servers (firewall, DNS).

Fetchmail runs on a schedule defined at the mailserver level. For access control, see [User roles reference](../reference/user-roles.md).
