#!/usr/bin/env bats

@test "unbound is able to resolve dns" {
	run nslookup github.com unbound
	[ "$status" -eq 0 ]
}
