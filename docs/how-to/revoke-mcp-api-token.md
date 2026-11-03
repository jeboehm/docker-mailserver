# How to Revoke an MCP API Token

## Revoke one token

1. Log in to the management interface.
2. Open **API tokens** in the menu, under **Security**.
3. Click **Revoke** next to the token.

## Revoke all tokens of a user

1. Open **Users** in the management interface and edit the user.
2. Disable the user, or set a new password.

For someone who has left, do this as well as disabling them at the identity provider, which does not reach their tokens. See [OIDC role and account changes reach tokens late](../explanation/mcp-server.md#oidc-role-and-account-changes-reach-tokens-late).

## Verification

A revoked token gets `401` on its next request. For who can revoke which tokens, see [User roles](../reference/user-roles.md#mcp-server-and-api-tokens).
