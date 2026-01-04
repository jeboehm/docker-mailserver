#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
}

@test "http connection to manager web interface" {
	run curl -L "http://${WEB_HTTP_ADDRESS}/"
	assert_output --partial "Email address"
}

@test "http connection to webmail interface" {
	run curl "http://${WEB_HTTP_ADDRESS}/webmail/"
	assert_output --partial "jeboehm"
}

@test "http connection to rspamd interface" {
	run curl "http://${WEB_HTTP_ADDRESS}/rspamd/"
	assert_output --partial "Rspamd Web Interface"
}

@test "http connection to autoconfigure file" {
	run curl "http://${WEB_HTTP_ADDRESS}/mail/config-v1.1.xml"
	assert_output --partial "clientConfig"
}

@test "http connection to autodiscover file" {
	run curl "http://${WEB_HTTP_ADDRESS}/autodiscover/autodiscover.xml"
	assert_output --partial "DomainRequired"
}
