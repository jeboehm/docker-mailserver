#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "http connection to manager web interface" {
	run curl -fsSL "http://${WEB_HTTP_ADDRESS}/"
	assert_success
	assert_output --partial "Email address"
}

@test "http connection to webmail interface" {
	run curl -fsSL "http://${WEB_HTTP_ADDRESS}/webmail/"
	assert_success
	assert_output --partial "jeboehm"
}

@test "http connection to rspamd interface" {
	run curl -fsSL "http://${WEB_HTTP_ADDRESS}/rspamd/"
	assert_success
	assert_output --partial "Rspamd Web Interface"
}

@test "http connection to autoconfigure file" {
	run curl -fsSL "http://${WEB_HTTP_ADDRESS}/mail/config-v1.1.xml"
	assert_success
	assert_output --partial "clientConfig"
}

@test "http connection to autodiscover file" {
	run curl -fsSL "http://${WEB_HTTP_ADDRESS}/autodiscover/autodiscover.xml"
	assert_success
	assert_output --partial "DomainRequired"
}

@test "system:check command succeeds" {
	run exec_in_service web /opt/admin/bin/console system:check --all
	assert_success
}
