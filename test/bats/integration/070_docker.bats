#!/usr/bin/env bats

setup() {
	load '_helper'
	skip_in_kubernetes
}

@test "no unhealthy containers exist" {
	run docker ps -q --filter health=unhealthy
	[ "$status" -eq 0 ]
	[ "$output" = "" ]
}

@test "Moved mail was sent to rspamd and learned successfully" {
	run bash -c "dockerlogs.sh docker-mailserver-filter-1 | grep 'learned message as spam:' | grep rspamd_controller_learn_fin_task"

	[ "$status" -eq 0 ]
}

@test "system:check command succeeds" {
	run docker exec docker-mailserver-web-1 /opt/admin/bin/console system:check --all

	[ "$status" -eq 0 ]
}
