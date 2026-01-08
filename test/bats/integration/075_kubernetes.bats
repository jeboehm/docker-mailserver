#!/usr/bin/env bats

setup() {
	load '_helper'
	skip_in_non_kubernetes
}

@test "Moved mail was sent to rspamd and learned successfully" {
	run bash -c "kubectl logs statefulset/filter | grep 'learned message as spam:' | grep rspamd_controller_learn_fin_task"

	[ "$status" -eq 0 ]
}

@test "system:check command succeeds" {
	run kubectl exec deploy/web -c web -- /opt/admin/bin/console system:check --all

	[ "$status" -eq 0 ]
}
