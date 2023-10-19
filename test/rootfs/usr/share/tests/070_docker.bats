#!/usr/bin/env bats

@test "no unhealthy containers exist" {
    run docker ps -q --filter health=unhealthy
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "Virus container is not running when filtering is disabled" {
    if [ "${FILTER_VIRUS}" = "true" ]; then
        echo '# Filtering is enabled, skipping test' >&3
        skip
    fi

    run docker ps -q --filter name=docker-mailserver-virus-1
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "Moved mail was sent to rspamd and learned successfully" {
    run bash -c "dockerlogs.sh docker-mailserver-filter-1 | grep 'learned message as spam: undef' | grep rspamd_controller_learn_fin_task"

    [ "$status" -eq 0 ]
}
