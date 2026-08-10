#!/usr/bin/env bats

@test "user table exists" {
	run mariadb --skip-ssl-verify-server-cert --batch -u "${DB_USER}" --password="${DB_PASSWORD}" \
		-h "${DB_HOST}" -P "${DB_PORT}" "${DB_NAME}" \
		-e "select * from mail_users;"
	[ "$status" = 0 ]
}

@test "alias table exists" {
	run mariadb --skip-ssl-verify-server-cert --batch -u "${DB_USER}" --password="${DB_PASSWORD}" \
		-h "${DB_HOST}" -P "${DB_PORT}" "${DB_NAME}" \
		-e "select * from mail_aliases;"
	[ "$status" = 0 ]
}

@test "domain table exists" {
	run mariadb --skip-ssl-verify-server-cert --batch -u "${DB_USER}" --password="${DB_PASSWORD}" \
		-h "${DB_HOST}" -P "${DB_PORT}" "${DB_NAME}" \
		-e "select * from mail_domains;"
	[ "$status" = 0 ]
}
