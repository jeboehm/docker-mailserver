#!/bin/sh
# This script is used to initialize the database.
set -e

roundcube_init() {
	cd /var/www/html/webmail
	PWD=$(pwd)

	bin/initdb.sh --dir="$PWD/SQL" || bin/updatedb.sh --dir="$PWD/SQL" --package=roundcube || echo "Failed to initialize databse. Please run $PWD/bin/initdb.sh manually."
	rm -f /var/www/html/webmail/logs/errors.log
}

wait_for_database() {
	dockerize \
		-wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
		-wait "tcp://${REDIS_HOST}:${REDIS_PORT}" \
		-wait "tcp://${MDA_IMAP_ADDRESS}" \
		-wait "tcp://${MTA_SMTP_SUBMISSION_ADDRESS}" \
		-wait "tcp://${FILTER_WEB_ADDRESS}" \
		-timeout "${WAITSTART_TIMEOUT}" \
		/bin/true
}

wait_for_database || echo "Failed to reach services. Aborting."; exit 1
roundcube_init

/opt/manager/bin/console doctrine:migrations:migrate -n
/opt/manager/bin/console dkim:refresh
