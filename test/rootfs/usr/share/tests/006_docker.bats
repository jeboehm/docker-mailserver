#!/usr/bin/env bats

@test "no unhealthy containers exist" {
    run docker ps -q --filter health=unhealthy
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "no starting containers exist" {
    run docker ps -q --filter health=starting
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
