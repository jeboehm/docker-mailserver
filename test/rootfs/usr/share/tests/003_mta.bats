#!/usr/bin/env bats

@test "send mail to local account address" {
    run swaks -s mta --to admin@example.com --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to local address with extension" {
    run swaks -s mta --to admin-test@example.com --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail with smtp authentification" {
    run swaks -s mta --to admin@example.com --from admin@example.com -a -au admin@example.com -ap changeme -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to local alias" {
    run swaks -s mta --to foo@example.com --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send junk mail to local address" {
    run swaks -s mta --to admin@example.com --body "$BATS_TEST_DESCRIPTION" --header "X-Spam: Yes"
    [ "$status" -eq 0 ]
}

@test "maildir was created" {
    sleep 10 # MTA + MDA need some time. :)
    [ -d /var/vmail/example.com/admin/Maildir/new/ ]
}

@test "mail to local account address is stored" {
    run grep -r "send mail to local account address" /var/vmail/example.com/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail to local alias is stored" {
    run grep -r "send mail to local alias" /var/vmail/example.com/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail with smtp authentification is stored" {
    run grep -r "send mail with smtp authentification" /var/vmail/example.com/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail to local address with extension is stored" {
    run grep -r "send mail to local address with extension" /var/vmail/example.com/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "junk mail is assorted to the junk folder" {
    run grep -r "send junk mail to local address" /var/vmail/example.com/admin/Maildir/.Junk/
    [ "$status" -eq 0 ]
}

@test "send gtube mail is rejected" {
    run swaks -s mta --to admin@example.com --data /usr/share/tests/resources/gtube.txt
    [ "$status" -eq 26 ]
}

@test "virus is rejected" {
    if [ ${FILTER_VIRUS} = "false" ]; then
        skip
    fi

    run swaks -s mta --to admin@example.com --attach - < /usr/share/tests/resources/eicar.com
    [ "$status" -eq 26 ]
}
