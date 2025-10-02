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

@test "Check nginx configuration" {
	run docker exec docker-mailserver-web-1 nginx -t

	[ "$status" -eq 0 ]
}
