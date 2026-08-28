#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "unbound is able to resolve dns" {
	run dns_query +short github.com A
	assert_success
	assert_output --regexp '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
}
