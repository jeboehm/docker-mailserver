#!/usr/bin/env bats

@test "http connection to manager web interface" {
	run curl -L http://web/manager/ | grep "Email address"
	assert_output --partial "Email address"
}

@test "http connection to webmail interface" {
	run curl http://web/webmail/
	assert_output --partial "jeboehm"
}

@test "http connection to rspamd interface" {
	run http://web/rspamd/
	assert_output --partial "Rspamd Web Interface"
}

@test "http connection to autoconfigure file" {
	run curl http://web/.well-known/autoconfig/mail/config-v1.1.xml
	assert_output --partial "clientConfig"
}
