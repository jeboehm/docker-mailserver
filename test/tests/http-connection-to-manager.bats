#!/usr/bin/env bats
@test "http connection to management interface" {
  curl http://manager/
  [ "$?" -eq 0 ]
}
