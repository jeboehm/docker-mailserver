#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load'
	load '/usr/lib/bats/bats-assert/load'
}

@test "check DKIM key for example.com exists" {
	run redis-cli -a "${REDIS_PASSWORD}" -h redis hmget dkim_keys dkim.example.com
	assert_output --partial "BEGIN PRIVATE KEY"
}
