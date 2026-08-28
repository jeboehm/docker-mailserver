#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "Check postfix configuration" {
	run exec_in_service mta postfix check
	assert_success

	# On Kubernetes the mounted configuration and queue directories trigger
	# permission warnings; anything but warnings is unexpected.
	run grep -v 'warning:' <<<"${output}"
	assert_output ""
}

@test "Check frankenphp configuration" {
	run exec_in_service web frankenphp fmt /etc/frankenphp/Caddyfile
	assert_success
}

@test "Check dovecot configuration" {
	run exec_in_service mda doveconf -n
	assert_success
}

@test "Check rspamd configuration" {
	run exec_in_service filter rspamadm configtest
	assert_success
}

@test "Check unbound configuration" {
	run exec_in_service unbound unbound-checkconf
	assert_success
}

@test "Check rspamd user id is 11333 and group id is 11333" {
	run exec_in_service filter id -u
	assert_success
	assert_output "11333"

	run exec_in_service filter id -g
	assert_success
	assert_output "11333"
}

@test "Check vmail user id is 1000 and group id is 1000" {
	run exec_in_service mda id -u
	assert_success
	assert_output "1000"

	run exec_in_service mda id -g
	assert_success
	assert_output "1000"
}
