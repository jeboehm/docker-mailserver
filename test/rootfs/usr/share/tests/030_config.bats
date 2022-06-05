#!/usr/bin/env bats

@test "Check postfix configuration" {
    run docker exec docker-mailserver_mta_1 postfix check
    
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "Check dovecot configuration" {
    run docker exec docker-mailserver_mda_1 doveconf

    [ "$status" -eq 0 ]
}

@test "Check nginx configuration" {
    run docker exec docker-mailserver_web_1 nginx -t

    [ "$status" -eq 0 ]
}

@test "Check rspamd configuration" {
    run docker exec docker-mailserver_filter_1 rspamadm configtest

    [ "$status" -eq 0 ]
}
