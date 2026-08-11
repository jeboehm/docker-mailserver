#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "user table exists" {
	run db_query "select * from mail_users;"
	[ "$status" = 0 ]
}

@test "alias table exists" {
	run db_query "select * from mail_aliases;"
	[ "$status" = 0 ]
}

@test "domain table exists" {
	run db_query "select * from mail_domains;"
	[ "$status" = 0 ]
}

@test "addresses are stored in lower case" {
	# Postfix and dovecot look addresses up with lower('%s'), which only
	# resolves mixed case input as long as the stored values are lower case.
	run db_query "select count(*) from mail_users where name <> lower(name);"
	[ "$status" = 0 ]
	[[ "$output" =~ 0 ]]

	run db_query "select count(*) from mail_domains where name <> lower(name);"
	[ "$status" = 0 ]
	[[ "$output" =~ 0 ]]
}
