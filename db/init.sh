#!/bin/sh

LOCKFILE="/var/lib/mysql/init.lock"

if ! [ -r $LOCKFILE ]
then
	echo "Initialising database."

	sed -i /scripts/pre-exec.d/init.sql -e "s/##db##/${MYSQL_DATABASE}/g"
	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < /scripts/pre-exec.d/init.sql
	touch $LOCKFILE

	echo "Database initialised. Exit."
else
	echo "Database already initialised. Exit."
fi
