# How to Configure the MCP Server

mailserver-admin can offer an [MCP](https://modelcontextprotocol.io) endpoint, so that an agent can manage domains, users, aliases, fetchmail accounts and DKIM, run DNS validation, and read and send mail in the mailbox of the token's owner. It is off by default.

**Read [MCP server: risks and limitations](../explanation/mcp-server.md) first.** Mail can put instructions in front of an agent that reads it, passwords given to a tool pass through the agent, and a failing call can write its arguments to the error log.

## Prerequisites

- A `web` image whose mailserver-admin release contains the MCP server.
- For reading or sending mail: an `mda` image from the first docker-mailserver release that contains the `mailbox_credentials` passdb. See [step 6](#6-optional-enable-reading-and-sending-mail).
- HTTPS in front of the `web` service. The token travels in a request header, and the `web` service itself only speaks HTTP. See [How to configure a reverse proxy](configure-reverse-proxy.md).

## Steps

### 1. Set the environment variables

In `.env`:

```bash
MCP_ENABLED=true
MCP_ALLOWED_HOSTS=mail.example.com
```

`MCP_ALLOWED_HOSTS` is the comma-separated list of hostnames clients use to reach the server, without a port. Requests for any other hostname get `403 Forbidden: Invalid Host header.`

### 2. Apply the configuration

Docker Compose:

```bash
bin/production.sh up -d web
```

Kubernetes, when you apply the root `kustomization.yaml`:

```bash
bin/kubernetes-env.sh
kubectl apply -k .
kubectl rollout restart deployment/web
```

An overlay with its own ConfigMap sets both variables in `config-env`.

### 3. Preserve the `Host` header

The endpoint matches the raw `Host` header, so a reverse proxy must pass it on unchanged. See [Preserve the Host header](configure-reverse-proxy.md#5-preserve-the-host-header).

### 4. Create a token

1. Log in to the management interface. This works with a local password and with OAuth2.
2. Open **API tokens** in the menu, under **Security**.
3. Click **Create API token**.
4. Enter a name, choose the [scopes](../reference/mcp-server.md#scopes) and set the validity in days. Only `manage:read` and `mail:read` are preselected. Tick `manage:write` and `mail:send` if the agent needs them, and remove the scopes it does not need:
   - Give an agent that reads mail no other scope.
   - Use separate tokens, and separate agents, for reading, sending and managing.
   - Do not use an admin's token for an agent that reads mail.
5. Copy the token, which starts with `msa_`. It is only shown once.

Use one token per agent, so that you can [revoke them](revoke-mcp-api-token.md) separately.

### 5. Configure the client

The endpoint is `https://<hostname>/mcp`. It uses the MCP Streamable HTTP transport and expects the token as `Authorization: Bearer <token>`. Any client that can send this header can connect. Clients that only support the OAuth flow cannot.

For example, Claude Code reads this from `.mcp.json`:

```json
{
  "mcpServers": {
    "mailserver": {
      "type": "http",
      "url": "https://mail.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${MAILSERVER_MCP_TOKEN}"
      }
    }
  }
}
```

Keep the token in the environment variable, not in a file you commit. If the client can ask for approval before a tool runs, require it for `message_send` and for the tools that write. If one client holds both `mail:read` and `mail:send`, have a person approve every send.

### 6. Optional: enable reading and sending mail

These tools log in to Dovecot and Postfix with short-lived credentials, which only the first docker-mailserver release that contains the `mailbox_credentials` passdb accepts. Upgrade `mda` first and check it:

```bash
# Docker Compose
bin/production.sh exec mda doveconf -n | grep 'passdb mailbox_credentials'
# Kubernetes
kubectl exec statefulset/mda -c dovecot -- doveconf -n | grep 'passdb mailbox_credentials'
```

The command prints `passdb mailbox_credentials {`. If it prints nothing, leave both flags off: every mail tool would fail, and each refused login delays further logins from the `web` container, including those of Roundcube.

Then set the flags you need in `.env` and apply the configuration as in step 2:

```bash
MCP_MAIL_READ_ENABLED=true
MCP_MAIL_SEND_ENABLED=true
```

The two are independent. `message_send` also logs in over IMAP to keep a copy in the Sent mailbox, whether or not reading is enabled.

### 7. Protect what passes through

1. Restrict who can read the logs of the `web` container (`docker logs`, `kubectl logs`, log collectors) and how long they are kept.
2. Set passwords in the web interface wherever the agent's context and its history must not hold them, or change them there afterwards.

## Verification

Without a token, the endpoint answers `401` with `WWW-Authenticate: Bearer`. A `404` means `MCP_ENABLED` is not `true`:

```bash
curl -i -X POST https://mail.example.com/mcp
```

With a token, this answers `200` with an `Mcp-Session-Id` header. A `403` means the hostname is not in `MCP_ALLOWED_HOSTS`, or a proxy changed the `Host` header:

```bash
curl -i https://mail.example.com/mcp \
  -H "Authorization: Bearer ${MAILSERVER_MCP_TOKEN}" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'
```

In the client, call the `whoami` tool. It returns the user, role, domain and the scopes of the token.

For every tool, scope and limit, see [MCP server reference](../reference/mcp-server.md). For variables, see [Environment variables reference](../reference/environment-variables.md#mcp-server).
