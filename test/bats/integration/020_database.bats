#!/usr/bin/env bats

setup() {
	load '_helper'
}

@test "user table exists" {
	run db_query "select * from mail_users;"
	assert_success
}

@test "alias table exists" {
	run db_query "select * from mail_aliases;"
	assert_success
}

@test "domain table exists" {
	run db_query "select * from mail_domains;"
	assert_success
}

@test "addresses are stored in lower case" {
	# Postfix and dovecot look addresses up with lower('%s'), which only
	# resolves mixed case input as long as the stored values are lower case.
	run db_query "select count(*) from mail_users where name <> lower(name);"
	assert_success
	assert_output "0"

	run db_query "select count(*) from mail_domains where name <> lower(name);"
	assert_success
	assert_output "0"
}
