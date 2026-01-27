#!/usr/bin/env bats

setup() {
	load '_helper'
	skip_in_kubernetes
}

@test "Check postfix configuration" {
	run docker exec docker-mailserver-mta-1 postfix check

	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "Check frankenphp configuration" {
	run docker exec docker-mailserver-web-1 frankenphp fmt /etc/frankenphp/Caddyfile

	[ "$status" -eq 0 ]
}

@test "Check dovecot configuration" {
	run docker exec docker-mailserver-mda-1 doveconf -n

	[ "$status" -eq 0 ]
}

@test "Check rspamd configuration" {
	run docker exec docker-mailserver-filter-1 rspamadm configtest

	[ "$status" -eq 0 ]
}

@test "Check unbound configuration" {
	run docker exec docker-mailserver-unbound-1 unbound-checkconf

	[ "$status" -eq 0 ]
}

@test "Check rspamd user id is 11333 and group id is 11333" {
	run docker exec docker-mailserver-filter-1 id -u

	[ "$status" -eq 0 ]
	[ "$output" -eq 11333 ]

	run docker exec docker-mailserver-filter-1 id -g

	[ "$status" -eq 0 ]
	[ "$output" -eq 11333 ]
}

@test "Check vmail user id is 1000 and group id is 1000" {
	run docker exec docker-mailserver-mda-1 id -u

	[ "$status" -eq 0 ]
	[ "$output" -eq 1000 ]

	run docker exec docker-mailserver-mda-1 id -g

	[ "$status" -eq 0 ]
	[ "$output" -eq 1000 ]
}
