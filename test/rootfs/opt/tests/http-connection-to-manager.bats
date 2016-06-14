#!/usr/bin/env bats
@test "http connection to management interface" {
  curl http://manager/ | grep Password
  [ "$?" -eq 0 ]
}
