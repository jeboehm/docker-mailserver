#!/usr/bin/env bats

@test "no unhealthy containers exist" {
	run docker ps -q --filter health=unhealthy
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "Moved mail was sent to rspamd and learned successfully" {
	run bash -c "dockerlogs.sh docker-mailserver-filter-1 | grep 'learned message as spam: undef' | grep rspamd_controller_learn_fin_task"

	[ "$status" -eq 0 ]
}

@test "DNS is resolved by unbound" {
	run bash -c "dockerlogs.sh docker-mailserver-filter-1 | grep 'DNS query blocked on'"

	[ "$status" -eq 1 ]
}
