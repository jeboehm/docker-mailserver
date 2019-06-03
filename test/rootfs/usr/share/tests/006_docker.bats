#!/usr/bin/env bats

@test "no unhealthy containers exist" {
    run docker ps -q --filter health=unhealthy
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "Virus container is not running when filtering is disabled" {
    if [ ${FILTER_VIRUS} = "true" ]; then
        echo '# Filtering is disabled, skipping test' >&3
        skip
    fi

    run docker ps -q --filter name=docker-mailserver_virus_1
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
