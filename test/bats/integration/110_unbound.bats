#!/usr/bin/env bats

setup() {
	load '_helper'

	mapfile -t parts < <(split_by_colon "${UNBOUND_DNS_ADDRESS}")
	UNBOUND_DNS_HOST="${parts[0]}"
	UNBOUND_DNS_PORT="${parts[1]}"
}

@test "unbound is able to resolve dns" {
	run dig "@${UNBOUND_DNS_HOST}" -p "${UNBOUND_DNS_PORT}" github.com
	[ "$status" -eq 0 ]
}
