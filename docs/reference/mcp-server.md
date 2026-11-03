# MCP Server Reference

The MCP endpoint of mailserver-admin. For setup, see [How to configure the MCP server](../how-to/configure-mcp-server.md). For the risks, see [MCP server: risks and limitations](../explanation/mcp-server.md).

## Endpoint

| Property        | Value                                                  |
| --------------- | ------------------------------------------------------ |
| Path            | `/mcp`                                                 |
| Transport       | MCP Streamable HTTP                                    |
| Authentication  | `Authorization: Bearer <token>`                        |
| Session storage | Redis, so requests can reach any replica of `web`      |
| Enabled by      | `MCP_ENABLED=true`                                     |
| Hostnames       | `MCP_ALLOWED_HOSTS`, matched against the `Host` header |

### HTTP responses

| Status | Cause                                                                                                           |
| ------ | --------------------------------------------------------------------------------------------------------------- |
| `401`  | Missing, unknown, expired or revoked token, or a disabled owner. Carries `WWW-Authenticate: Bearer`             |
| `403`  | With a valid token: the `Host` header is not in `MCP_ALLOWED_HOSTS`, or an `Origin` header names another origin |
| `404`  | `MCP_ENABLED` is not `true`. The API token pages answer the same way, and their menu entry is hidden            |

The `Host` match ignores case and port. `X-Forwarded-Host` is not considered.

## API tokens

| Property | Value                                                                                                                                       |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Format   | `msa_` followed by 64 hexadecimal characters. Only a SHA-256 hash is stored, and the token is shown once                                    |
| Lifetime | 1 day up to `MCP_TOKEN_MAX_LIFETIME_DAYS`. Mandatory. Lowering the variable does not shorten existing tokens                                |
| Owner    | The user who created it. Nobody can create a token for someone else                                                                         |
| Role     | The owner's role and `enabled` flag, read from the database on every request                                                                |
| Revoked  | By hand; automatically when the owner's password changes or the owner is disabled. A revoked token stays revoked if the owner is re-enabled |
| Listed   | Users see their own tokens, domain admins those of their domain, admins all. Revoked tokens stay listed until their owner is deleted        |

## Scopes

A call succeeds only if the token carries the scope and the owner's current role allows the action on that object.

| Scope          | Allows                                                                                 | Preselected |
| -------------- | -------------------------------------------------------------------------------------- | ----------- |
| `manage:read`  | List and read domains, users, aliases, fetchmail accounts, DKIM status; DNS validation | yes         |
| `manage:write` | Create, update and delete the same                                                     | yes         |
| `mail:read`    | Read the owner's own mailbox                                                           | yes         |
| `mail:send`    | Send from the owner's own address                                                      | no          |

## Tools

"Own domain" means the domain of a domain admin. "None" means the tool is not listed and a call is refused. For the same rules in the web interface, see [User roles](user-roles.md).

| Tool                                                       | Scope          | Admin       | Domain Admin | User         |
| ---------------------------------------------------------- | -------------- | ----------- | ------------ | ------------ |
| `whoami`                                                   | _(none)_       | yes         | yes          | yes          |
| `domain_list`                                              | `manage:read`  | all         | none         | none         |
| `domain_create`, `domain_delete`                           | `manage:write` | all         | none         | none         |
| `user_list`, `user_get`                                    | `manage:read`  | all         | own domain   | none         |
| `user_create`, `user_update`, `user_delete`                | `manage:write` | all         | own domain   | none         |
| `alias_list`, `alias_get`                                  | `manage:read`  | all         | own domain   | none         |
| `alias_create`, `alias_update`, `alias_delete`             | `manage:write` | all         | own domain   | none         |
| `fetchmail_list`, `fetchmail_get`                          | `manage:read`  | all         | own domain   | own accounts |
| `fetchmail_create`, `fetchmail_update`, `fetchmail_delete` | `manage:write` | all         | own domain   | own accounts |
| `dkim_status`                                              | `manage:read`  | all         | none         | none         |
| `dkim_enable`, `dkim_disable`, `dkim_recreate_key`         | `manage:write` | all         | none         | none         |
| `dns_validate`                                             | `manage:read`  | all domains | own domain   | none         |
| `mailbox_list`, `message_search`, `message_get`            | `mail:read`    | own mailbox | own mailbox  | own mailbox  |
| `message_send`                                             | `mail:send`    | own address | own address  | own address  |

The mail tools also need `MCP_MAIL_READ_ENABLED` or `MCP_MAIL_SEND_ENABLED`, and no mail tool takes a mailbox user as an argument.

### Rules for all tools

- `tools/list` only shows the tools a token can use, given its scopes, its owner's role and the feature flags. Calls are checked the same way.
- Missing scopes, denied objects and objects that do not exist all answer `Not found or not allowed.`, so other domains cannot be probed.
- Password hashes, passwords, fetchmail passwords and DKIM private keys never appear in tool output.

### Pagination

| Tools                                                      | Default limit | Maximum | Out of range                    |
| ---------------------------------------------------------- | ------------- | ------- | ------------------------------- |
| `domain_list`, `user_list`, `alias_list`, `fetchmail_list` | 50            | 100     | Corrected; the answer states it |
| `mailbox_list`                                             | 50            | 100     | Refused                         |
| `message_search`                                           | 20            | 100     | Refused                         |
| `dns_validate`, by `next_cursor` instead of an offset      | 10            | 50      | Refused                         |

### Management tools

- `domain_create` generates a DKIM key and leaves DKIM disabled. `domain_delete` only works on a domain without users and aliases.
- `user_create` and `alias_create` default to the domain of the owner. Only admins can choose another domain or set `admin`.
- `user_update` keeps the role and `enabled` state of the owner's own user. A changed password revokes that user's tokens, including the calling token if the user is its owner. Disabling a user revokes their tokens.
- `user_delete` refuses the owner's own user.
- `fetchmail_create` and `fetchmail_update` accept a password that can never be read back.
- `dkim_enable` creates a key if the domain has none. `dkim_disable` keeps the key. `dkim_recreate_key` only runs with `confirm` set to `true`, because the published DNS record stops matching.
- `dns_validate` works through the domains in pages, with a budget of 20 seconds per call. Domains listed in `timed_out` were not checked, so nothing is known about their records.

### Mail read tools

- Each call opens its own IMAP session as the token's owner and closes it again. The tools do not change flags such as `\Seen`.
- `message_search` returns headers, newest first. `message_get` returns headers, a text body and a list of attachments without their content. HTML is converted to text, and a body over `MCP_MAIL_MESSAGE_MAX_BYTES` is cut off and marked with `body_truncated`.
- Everything the sender controls is under the key `untrusted_external_content`, with a `notice` telling the agent to treat it as data. This does not make it safe, see [prompt injection](../explanation/mcp-server.md#prompt-injection).
- Disabled and send-only users are refused.
- There are no tools to move, delete or flag mail, or to download attachments.

### Mail send tool

`message_send` sends a plain text mail from the owner's own address, with Postfix submission as the owner. Sending from aliases and attachments are not supported.

Recipients must be plain addresses such as `name@example.com`. A non-ASCII character before the `@` is refused.

| Result field       | Meaning                                                                                    |
| ------------------ | ------------------------------------------------------------------------------------------ |
| `sent`             | `true`: the mail has gone out, whatever the rest says. Do not send it again                |
| `message_id`       | The Message-ID of the mail                                                                 |
| `recipients`       | All recipients, including `bcc`                                                            |
| `sent_copy.status` | `saved`, `skipped` (send-only user, no copy is kept) or `failed` (the mail still went out) |

A refused or failed send answers with an error message that says whether to retry. After a lost connection the mail may have gone out, and the message says so.

## Limits

| Limit                             | Variable                                | Default   |
| --------------------------------- | --------------------------------------- | --------- |
| Parallel IMAP sessions per user   | `MCP_MAIL_MAX_IMAP_SESSIONS`            | `5`       |
| Body returned by `message_get`    | `MCP_MAIL_MESSAGE_MAX_BYTES`            | `65536`   |
| Recipients per mail               | `MCP_MAIL_SEND_MAX_RECIPIENTS`          | `20`      |
| Size of a sent message            | `MCP_MAIL_SEND_MAX_BYTES`               | `1048576` |
| Sends per hour, per token         | `MCP_MAIL_SEND_TOKEN_LIMIT_PER_HOUR`    | `30`      |
| Sends per hour, per user          | `MCP_MAIL_SEND_USER_LIMIT_PER_HOUR`     | `60`      |
| Sends per rolling minute, overall | `MCP_MAIL_SEND_GLOBAL_LIMIT_PER_MINUTE` | `15`      |

All connections to Dovecot and Postfix come from the address of the `web` container, which Roundcube shares. Dovecot allows 10 connections per user and address, and Postfix 20 connections per minute and client address. A send over a limit is refused before anything is tried, and the message says when to retry.

## Audit log

Every tool call writes one JSON record with the message `MCP tool call` on the channel `mcp_audit`, to the standard error of the `web` container.

| Field                                   | Content                                                          |
| --------------------------------------- | ---------------------------------------------------------------- |
| `token_id`, `user_id`, `user`           | The token and its owner                                          |
| `tool`                                  | The tool name                                                    |
| `target`                                | The object, for example `domain:example.com`                     |
| `result`                                | `ok`, `denied`, `failed` or `error`                              |
| `client_ip`                             | The client address, which needs `TRUSTED_PROXIES` behind a proxy |
| `recipients`, `message_id`, `sent_copy` | `message_send` only                                              |

The audit log never contains mail bodies, passwords or tokens. The error log is a separate matter, see [failing calls](../explanation/mcp-server.md#failing-calls-can-write-secrets-to-the-error-log).
