# How to Manage Users

Users are email accounts that can send and receive mail through the mailserver. Access depends on role: **Admin** can manage all users; **Domain Admin** only users in their domain; **User** can only change their own settings.

## Add a user

1. Log in to the management interface.
2. Open **User** in the menu.
3. Click **Add User**.
4. Enter:
   - **Email Address** (e.g. `user@example.com`)
   - **Password**
   - **Quota** (optional, MB)
   - **Admin** / **Domain Admin** / **Enabled** / **Send Only** as needed
5. Save.

The email must belong to an existing domain. The password must meet the configured policy.

![User List](../images/admin/user_list.png)

## Edit a user

1. Open **User** in the menu.
2. Select the user.
3. Change password, quota, Admin, Domain Admin, Enabled, or Send Only as needed.
4. Save.

![User Edit](../images/admin/user_edit.png)

Changing the email address is not supported. To use a new address, create a new user and migrate data if needed.

## Delete a user

1. Open **User** in the menu.
2. Select the user.
3. Confirm deletion.

Deleting a user removes the account and all mail. This cannot be undone. Back up important mail first.

## User properties

- **Email Address:** Local part + domain; must be valid (RFC 5322).
- **Password:** Stored hashed; policies enforced by the mailserver.
- **Quota:** Mailbox size limit in MB. When exceeded, incoming mail can be rejected and the user cannot send until space is freed; warnings are sent.
- **Send Only:** User can only send; no IMAP/POP3/webmail.
- **Admin / Domain Admin:** See [User roles reference](../reference/user-roles.md).

Users access mail via IMAP (143 with TLS), POP3 (110 with TLS), SMTP submission (587 with TLS), and webmail. They log in with full email and password.

For roles and permissions, see [User roles reference](../reference/user-roles.md).
