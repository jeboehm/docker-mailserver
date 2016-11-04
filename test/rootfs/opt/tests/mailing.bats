#!/usr/bin/env bats
@test "send mail to local address" {
    swaks --to admin@example.com
    [ "$?" -eq 0 ]
}

@test "send mail to local address with extension" {
    swaks --to admin-test@example.com
    [ "$?" -eq 0 ]
}

@test "greylisting is active (inbox folder)" {
  if [ "$GREYLISTING_ENABLED" != "true" ]
  then
    skip "Greylisting disabled"
  fi

  files="$(ls -1 /var/vmail/example.com/admin/Maildir/new/ | wc -l)"
  [ "$files" -eq 0 ]
}

@test "send mail with smtp authentification" {
    swaks --to admin@example.com --from admin@example.com -a -au admin@example.com -ap changeme -s example.com -tls
    [ "$?" -eq 0 ]
}

@test "maildir exists" {
    sleep 3
    ls -lh /var/vmail/example.com/admin/Maildir/new/
    [ "$?" -eq 0 ]
}

@test "maildir contains files" {
    if [ "$GREYLISTING_ENABLED" == "true" ]
    then
      echo "Waiting for greylisting"
      sleep 60
      postqueue -f
      sleep 3
    fi

    files="$(ls -1 /var/vmail/example.com/admin/Maildir/new/ | wc -l)"
    [ "$files" -gt 2 ]
}

@test "send junk mail to local address" {
    swaks --to admin@example.com --data sample-spam.txt
    [ "$?" -eq 0 ]
}

@test "check junk mail in junk folder (sieve rule is working)" {
    if [ "$GREYLISTING_ENABLED" == "true" ]
    then
      echo "Waiting for greylisting"
      sleep 60
      postqueue -f
      sleep 3
    else
      sleep 5
    fi

    files="$(ls -1 /var/vmail/example.com/admin/Maildir/.Junk/new/ | wc -l)"
    [ "$files" -gt 0 ]
}
