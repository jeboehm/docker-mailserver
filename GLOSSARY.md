# docker-mailserver

A mail server built from one container per service, with its domains, users, aliases and DKIM configuration kept in a database that mailserver-admin manages. This glossary fixes the words used in code, issues and documentation; the decisions behind them are in [`docs/adr/`](docs/adr/).

## Mail objects

**Domain**:
A mail domain the server accepts mail for. Stored in the database.
_Avoid_: Zone, host

**User**:
A login with a mailbox on a domain, addressed as `name@domain`. The word covers the login and the mailbox together.
_Avoid_: Account, login (for the address), mailbox (when the login is meant)

**Alias**:
An address on a domain whose mail goes to one or more destinations.
_Avoid_: Forward, redirect

**Catch-all**:
An alias with an empty local part (`@domain`) that receives mail for every address of the domain that nothing else claims.
_Avoid_: Wildcard

**Send-only user**:
A user that may authenticate and send but whose address does not accept mail.
_Avoid_: Outbound-only, relay user

**Admin**:
A user with the admin flag, who manages all domains, users, aliases and DKIM in mailserver-admin. See [user roles](docs/reference/user-roles.md).
_Avoid_: Superuser, root

**Domain admin**:
A user who manages the users, aliases and fetchmail accounts of their own domain only. See [user roles](docs/reference/user-roles.md).
_Avoid_: Postmaster, domain owner

**Address extension**:
A tag appended to the local part after a delimiter (`user-tag@domain`). Mail to it goes to the base address ([ADR-0003](docs/adr/0003-address-extensions-in-the-sender.md)).
_Avoid_: Plus address, subaddress, tag

**Sender login**:
The SASL login name of the user that is allowed to send as a given envelope sender on submission ([ADR-0001](docs/adr/0001-submission-accepts-only-senders-the-login-owns.md)).
_Avoid_: Sender owner (as a role), from user

**Owned address**:
An address a login may use as envelope sender: its own address, every alias it is a destination of, and, for a catch-all destination, the other addresses of that domain ([ADR-0002](docs/adr/0002-sender-ownership-is-defined-by-the-login-map-query.md)).
_Avoid_: Allowed sender, identity

**Sender mode**:
The setting of an MCP API token that decides which owned address `message_send` and `message_draft` use: the user's own address, one fixed address, or any owned address chosen per call. mailserver-admin counts fewer addresses as owned than Postfix accepts: no catch-all domains and no address extensions. See the [MCP server reference](docs/reference/mcp-server.md#sender).
_Avoid_: Sender binding, identity

**DKIM selector**:
The name that identifies one DKIM key of a domain. See [Configure DKIM](docs/how-to/configure-dkim.md).
_Avoid_: DKIM key name

## Services

**mta**:
Postfix. Receives mail from the outside and accepts authenticated mail on submission.

**mda**:
Dovecot. Stores mail and lets users read it.

**filter**:
Rspamd. Scans and DKIM-signs mail.
_Avoid_: Spam filter (the service also signs)

**web**:
The web interfaces: mailserver-admin and Roundcube.
_Avoid_: Admin (for the service)

**unbound**:
The validating DNS resolver used by the filter.

**`ssl`**:
The job that creates the self-signed certificate.

**db**:
The database of domains, users and aliases. Its schema belongs to mailserver-admin.

**redis**:
The key-value store that holds the state of the filter, including DKIM keys.

**fetchmail**:
The service that fetches mail from external accounts into local users.

The addresses and ports of the services are listed in [`AGENTS.md`](AGENTS.md) and [`docs/reference/service-architecture.md`](docs/reference/service-architecture.md).
