#!/usr/bin/env bats

@test "check DKIM selector map exists" {
    [ -r /media/dkim/dkim_selectors.map ]
}

@test "check DKIM key for example.com exists" {
    [ -r /media/dkim/example.com.1337.key ]
}
