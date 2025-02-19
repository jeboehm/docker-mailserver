#!/usr/bin/env bats

@test "check DKIM selector map exists" {
    redis-cli redis hget dkim_selectors.map example.com | grep "1337"
    [ "$?" -eq 0 ]
}

@test "check DKIM key for example.com exists" {
    redis-cli redis hmget dkim_keys 1337.example.com | grep "BEGIN PRIVATE KEY"
    [ "$?" -eq 0 ]
}
