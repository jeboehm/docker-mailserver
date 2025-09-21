#!/usr/bin/env bats

@test "unbound is able to resolve dns" {
	run dig @unbound -p 5353 github.com
	[ "$status" -eq 0 ]
}
