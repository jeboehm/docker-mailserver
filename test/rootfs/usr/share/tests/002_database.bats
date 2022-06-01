#!/usr/bin/env bats

@test "user table exists" {
    run mysql --batch -u "${MYSQL_USER}" --password="${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" -e "select * from mail_users;"
    [ "$status" = 0 ]
}

@test "alias table exists" {
    run mysql --batch -u "${MYSQL_USER}" --password="${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" -e "select * from mail_aliases;"
    [ "$status" = 0 ]
}

@test "domain table exists" {
    run mysql --batch -u "${MYSQL_USER}" --password="${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" -e "select * from mail_domains;"
    [ "$status" = 0 ]
}
