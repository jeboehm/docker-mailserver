#!/usr/bin/env bats

setup() {
	load '_helper'
	skip_in_kubernetes
}

@test "no unhealthy containers exist" {
	run docker ps -q --filter health=unhealthy
	assert_success
	assert_output ""
}
