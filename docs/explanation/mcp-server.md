# MCP Server: Risks and Limitations

The MCP server lets an agent act with the role of a user and, if enabled, read and send that user's mail. The tool layer enforces the same role rules as the web interface, but it cannot make the agent trustworthy. This page describes what remains. To set it up, see [How to configure the MCP server](../how-to/configure-mcp-server.md).

## Risks

### Prompt injection

Mail is written by strangers, and an agent cannot reliably tell the content it reads from the instructions it follows. Anyone who can send you mail can put instructions in front of an agent that reads your mailbox.

**A client holding `mail:read` and `mail:send` can be told, by a mail it reads, to send your mail to someone else.** A mail cannot be recalled.

The output of the read tools marks mail content as untrusted, and asks the agent to treat it as data. That is a request to a language model, not a security boundary. The send limits only bound the damage: with the default of 30 sends per hour and token, an agent can still send out 30 mails an hour.

The same applies to `mail:read` together with `manage:write`, and **the token form preselects exactly that combination**. An injected instruction can create an alias that forwards mail elsewhere, or on an admin's token, change a user's password or create a new admin. A regular user's token can only reach their own fetchmail accounts this way.

To reduce the risk:

- Give an agent that reads mail no other scope, and remove the preselected `manage:write` when you create its token.
- Use separate tokens, and separate agents, for reading, sending and managing.
- If a client must hold both `mail:read` and `mail:send`, have a person approve every send in the client.
- Do not use an admin's token for an agent that reads mail.

### Passwords pass through the agent's context

`user_create`, `user_update`, `fetchmail_create` and `fetchmail_update` take a password as a tool argument. It is never echoed in tool output, and cannot be read back. It does however pass through the agent's context: **the model sees it, and so does anything that stores the conversation**, such as the client's history and the provider hosting the model.

Treat a password set this way as known to those systems. Where that is not acceptable, set the password in the web interface instead, or change it there afterwards. Changing a user's password revokes all of that user's API tokens.

### Failing calls can write secrets to the error log

**A failing call can write all its tool arguments to the error log in clear text, including passwords, fetchmail passwords, and the recipients and bodies of `message_send`.** This is accepted behaviour: the logging of the MCP bundle stays unfiltered.

The production log holds back its debug records, which include the raw request and the tool arguments, and writes them all as soon as anything in the same request logs an error. That is typically an unexpected failure such as a database or Redis outage.

A call the agent sees as successful can trigger it too, for example when `message_send` delivers a mail and then hits an unexpected problem saving the Sent copy. A plain refusal, such as a validation message, does not trigger it by itself, but do not plan around that.

The error log goes to the standard error of the `web` container. Whatever reads that stream gets these secrets: `docker logs`, `kubectl logs`, and any log collector with its retention and its readers. Restrict access to these logs and keep them only as long as needed, or do not enable the tools whose arguments you cannot have there.

The [audit log](../reference/mcp-server.md#audit-log) shares that stream as separate records, and those stay free of bodies, passwords and tokens.

## Limitations

### OAuth-only clients cannot connect

The endpoint only accepts personal API tokens as a bearer header. It has no OAuth authorisation flow, so clients that only support that flow cannot connect. This applies even when users log in to the web interface with OAuth2.

Browser-based clients are also affected: the server allows no other origins, so a request with an `Origin` header from another site gets `403`.

### OIDC role and account changes reach tokens late

Tokens never contact the identity provider. A token uses the owner's role and `enabled` flag from the local database, and OIDC only updates those at a web login. Changes at the provider reach a token only through a web login, a local disable or the token's expiry:

- A user removed from the admin group at the provider **keeps admin rights on their tokens** until they next log in to the web interface or the token expires.
- A user deactivated at the provider **keeps working tokens** until they expire, or until an admin disables the user locally or revokes the tokens.
- Disabling a user locally revokes their tokens. If a later OIDC login re-enables the user, which is intended because the provider is authoritative, the old tokens stay revoked and the user can create new ones.

When someone leaves, disable them locally as well as at the provider. `MCP_TOKEN_MAX_LIFETIME_DAYS` bounds how long a forgotten case can last, and only applies to tokens created after it was changed.

### Mail

- Agents only reach the mailbox of the token's owner, for every role. Admins and domain admins get no access to other people's mail.
- Sending uses the owner's own address. Aliases and attachments are not supported.
- Agents cannot move, delete or flag mail, or download attachments.

### Connection limits are shared

All mail tools connect from the address of the `web` container, like Roundcube. The connection limits of Dovecot and Postfix therefore apply to the whole installation or user rather than per token, and a mistyped password in Roundcube can delay every login from that address by up to 15 seconds. Mail tools report the resulting refusals as retryable. See [Limits](../reference/mcp-server.md#limits).
