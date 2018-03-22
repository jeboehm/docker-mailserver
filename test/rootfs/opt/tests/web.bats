#!/usr/bin/env bats
@test "http connection to manager web interface" {
    curl http://web/manager/ | grep "Redirecting to"
    [ "$?" -eq 0 ]
}

@test "http connection to webmail interface" {
    curl http://web/webmail/ | grep "ispmail-logo"
    [ "$?" -eq 0 ]
}
