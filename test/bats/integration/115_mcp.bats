#!/usr/bin/env bats

# The MCP endpoint of mailserver-admin, spoken with curl as an agent would. Tokens
# go straight into the database, because the web interface is the only other way
# to create one. Runs before 120_mailbox_credentials.bats, whose refused logins
# would delay the logins of the mail tools. Mails use a short hash of mail_needle: the
# server encodes them as quoted-printable, which wraps a long line in the Maildir, and
# Dovecot's full-text search does not find very long words.

setup() {
	load '_helper'
}

teardown() {
	mcp_tokens_clear 2>/dev/null || true
	db_query "DELETE FROM mail_domains WHERE name = 'mcp.example.net';" 2>/dev/null || true
}

@test "mcp refuses a request without a token" {
	run curl -si -X POST "http://${WEB_HTTP_ADDRESS}/mcp" -H "Host: ${MCP_ALLOWED_HOSTS%%,*}"
	assert_success
	assert_line --partial '401 Unauthorized'
	assert_output --regexp '[Ww]{1}ww-[Aa]uthenticate: Bearer'
}

@test "mcp refuses a host outside of MCP_ALLOWED_HOSTS" {
	token="$(mcp_token admin example.com manage:read)"

	run curl -si "http://${WEB_HTTP_ADDRESS}/mcp" \
		-H 'Host: mcp-not-allowed.example.net' \
		-H "Authorization: Bearer ${token}" \
		-H 'Content-Type: application/json' \
		-H 'Accept: application/json, text/event-stream' \
		-d '{"jsonrpc":"2.0","id":1,"method":"ping"}'
	assert_success
	assert_line --partial '403 Forbidden'
}

@test "mcp refuses an expired token" {
	token="$(mcp_token admin example.com manage:read -1)"

	run mcp_post "${token}" '{"jsonrpc":"2.0","id":1,"method":"ping"}'
	assert_success
	assert_line --partial '401 Unauthorized'
}

@test "mcp refuses a revoked token" {
	token="$(mcp_token admin example.com manage:read)"
	db_query "UPDATE api_tokens SET revoked_at = CURRENT_TIMESTAMP WHERE name = 'bats';"

	run mcp_post "${token}" '{"jsonrpc":"2.0","id":1,"method":"ping"}'
	assert_success
	assert_line --partial '401 Unauthorized'
}

@test "mcp refuses the token of a disabled user" {
	token="$(mcp_token disabled example.com manage:read)"

	run mcp_post "${token}" '{"jsonrpc":"2.0","id":1,"method":"ping"}'
	assert_success
	assert_line --partial '401 Unauthorized'
}

@test "mcp whoami names the owner and the scopes of the token" {
	token="$(mcp_token admin example.com manage:read,mail:read)"

	run mcp_tool "${token}" whoami
	assert_success

	run jq -c '[.user, .role, .scopes]' <<<"${output}"
	assert_output '["admin@example.com","admin",["manage:read","mail:read"]]'
}

@test "mcp tools/list only shows what the scopes of the token allow" {
	token="$(mcp_token admin example.com mail:read)"

	run mcp_request "${token}" tools/list
	assert_success

	run jq -r '[.tools[].name] | sort | join(" ")' <<<"${output}"
	assert_output 'mailbox_list message_get message_search whoami'
}

@test "mcp tools/list only shows what the role of the owner allows" {
	token="$(mcp_token fetchmailreceiver example.org manage:read,manage:write)"

	run mcp_request "${token}" tools/list
	assert_success
	tools="${output}"

	run jq -e '[.tools[].name] | index("fetchmail_list") != null and index("domain_list") == null and index("user_list") == null' <<<"${tools}"
	assert_success
}

@test "mcp refuses a tool outside the scopes of the token" {
	token="$(mcp_token admin example.com mail:read)"

	run mcp_tool "${token}" message_send '{"to":["admin@example.com"],"subject":"refused","body":"refused"}'
	assert_failure
	assert_output --partial 'Not found or not allowed.'
}

@test "mcp creates, lists and deletes a domain" {
	token="$(mcp_token admin example.com manage:read,manage:write)"

	run mcp_tool "${token}" domain_create '{"name":"mcp.example.net"}'
	assert_success
	id="$(jq -r '.id' <<<"${output}")"

	run db_query "SELECT name FROM mail_domains WHERE name = 'mcp.example.net';"
	assert_output 'mcp.example.net'

	run mcp_tool "${token}" domain_list
	assert_success
	assert_output --partial '"name":"mcp.example.net"'

	run mcp_tool "${token}" domain_delete "{\"id\":${id}}"
	assert_success

	run db_query "SELECT name FROM mail_domains WHERE name = 'mcp.example.net';"
	assert_output ''
}

@test "mcp sends a mail, keeps a copy and reads the mail back" {
	token="$(mcp_token admin example.com mail:read,mail:send)"
	needle="$(mail_needle | sha256sum | cut -c1-16)"

	run mcp_tool "${token}" message_send "$(jq -nc --arg text "${needle}" '{to: ["admin@example.com"], subject: $text, body: $text}')"
	assert_success
	sent="${output}"

	run jq -r '[.sent, .from, .sent_copy.status] | join(" ")' <<<"${sent}"
	assert_output 'true admin@example.com saved'

	run wait_for_mail "${needle}" "$(maildir admin@example.com)"
	assert_success

	run wait_for_mail "${needle}" "$(maildir admin@example.com Sent)"
	assert_success

	run mcp_tool "${token}" message_search "$(jq -nc --arg text "${needle}" '{subject: $text}')"
	assert_success
	found="${output}"

	run jq -r '.messages[0].untrusted_external_content.subject' <<<"${found}"
	assert_output "${needle}"

	uid="$(jq -r '.messages[0].uid' <<<"${found}")"

	run mcp_tool "${token}" message_get "{\"mailbox\":\"INBOX\",\"uid\":${uid}}"
	assert_success
	message="${output}"

	run jq -r '.untrusted_external_content.body' <<<"${message}"
	assert_output --partial "${needle}"
}

@test "mcp keeps a send-only user out of the mailbox and sends without a copy" {
	token="$(mcp_token sendonly example.com mail:read,mail:send)"
	needle="$(mail_needle | sha256sum | cut -c1-16)"

	run mcp_tool "${token}" mailbox_list
	assert_failure

	run mcp_tool "${token}" message_send "$(jq -nc --arg text "${needle}" '{to: ["admin@example.com"], subject: $text, body: $text}')"
	assert_success
	sent="${output}"

	run jq -r '[.sent, .sent_copy.status] | join(" ")' <<<"${sent}"
	assert_output 'true skipped'

	run wait_for_mail "${needle}" "$(maildir admin@example.com)"
	assert_success
}

@test "mcp mail tools leave no mailbox credential behind" {
	token="$(mcp_token admin example.com mail:read)"

	run mcp_tool "${token}" mailbox_list
	assert_success

	run db_query "SELECT COUNT(*) FROM mail_mailbox_credentials;"
	assert_output '0'
}
