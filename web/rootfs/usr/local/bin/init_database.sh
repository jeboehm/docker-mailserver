#!/bin/sh
# This script is used to initialize the database.
set -e

roundcube_init() {
	cd /var/www/html/webmail
	PWD=$(pwd)

	bin/initdb.sh --dir="$PWD/SQL" || bin/updatedb.sh --dir="$PWD/SQL" --package=roundcube || echo "Failed to initialize databse. Please run $PWD/bin/initdb.sh manually."
	rm -f /var/www/html/webmail/logs/errors.log
}

roundcube_init

/opt/manager/bin/console doctrine:migrations:migrate -n
/opt/manager/bin/console dkim:refresh
