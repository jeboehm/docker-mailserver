#!/usr/bin/env bats
@test "database contains tables" {
    tables="$(echo "show tables" | mysql -u "${MYSQL_USER}" --password="${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" "${MYSQL_DATABASE}" | wc -l)"
    [ "$tables" -gt 3 ]
}
