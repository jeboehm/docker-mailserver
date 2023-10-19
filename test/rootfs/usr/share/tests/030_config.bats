#!/usr/bin/env bats

@test "Check postfix configuration" {
    run docker exec docker-mailserver-mta-1 postfix check

    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "Check dovecot configuration" {
    run docker exec docker-mailserver-mda-1 doveconf

    [ "$status" -eq 0 ]
}

@test "Check nginx configuration" {
    run docker exec docker-mailserver-web-1 nginx -t

    [ "$status" -eq 0 ]
}

@test "Check rspamd configuration" {
    run docker exec docker-mailserver-filter-1 rspamadm configtest

    [ "$status" -eq 0 ]
}
