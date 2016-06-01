#!/bin/sh

LOCKFILE="/var/lib/mysql/init.lock"

if ! [ -r $LOCKFILE ]
then
	echo "Initialising database."

	/usr/bin/mysqld --skip-grant-tables --user=mysql --console &
	sleep 10
	cat /scripts/pre-exec.d/init.sql | mysql -u root --host=127.0.0.1 ${MYSQL_DATABASE}
	killall mysqld
	sleep 5

	touch $LOCKFILE

	echo "Database initialised. Exit."
else
	echo "Database already initialised. Exit."
fi
