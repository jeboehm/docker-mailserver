#!/usr/bin/env bats

@test "check DKIM key for example.com exists" {
    redis-cli -h redis hmget dkim_keys dkim.example.com | grep "BEGIN PRIVATE KEY"
    [ "$?" -eq 0 ]
}
