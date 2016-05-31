#!/bin/sh

sed -i /scripts/pre-exec.d/init.sql -e "s/##db##/${MYSQL_DATABASE}/g"
/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < /scripts/pre-exec.d/init.sql
