#!/usr/bin/env bats

@test "check DKIM key for example.com exists" {
	run redis-cli -a "${REDIS_PASSWORD}" -h redis hmget dkim_keys dkim.example.com
	assert_output --partial "BEGIN PRIVATE KEY"
}
