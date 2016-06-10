#!/usr/bin/env bats
@test "send mail to local address" {
  swaks --to admin@example.com
  [ "$?" -eq 0 ]
}

@test "send mail to remote non existent address" {
  swaks --to wtf@example.invalid --from admin@example.com -a -au admin@example.com -ap changeme -s mta -tls
  [ "$?" -eq 0 ]
}

@test "send mail with smtp authentification" {
  swaks --to admin@example.com --from admin@example.com -a -au admin@example.com -ap changeme -s example.com -tls
  [ "$?" -eq 0 ]
}

@test "maildir exists" {
  ls -lh /var/vmail/example.com/admin/Maildir/new/
  [ "$?" -eq 0 ]
}

@test "maildir contains files" {
  files="$(ls -1 /var/vmail/example.com/admin/Maildir/new/ | wc -l)"
  [ "$files" -gt 0 ]
}
