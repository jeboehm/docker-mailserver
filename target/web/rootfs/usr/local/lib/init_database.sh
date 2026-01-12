#!/bin/sh
# This script is used to initialize the database.
set -e

roundcube_init() {
	cd /opt/roundcube
	PWD=$(pwd)

	bin/initdb.sh --dir="$PWD/SQL" || bin/updatedb.sh --dir="$PWD/SQL" --package=roundcube || echo "Failed to initialize databse. Please run $PWD/bin/initdb.sh manually."
	rm -f /opt/roundcube/logs/errors.log
}

/opt/admin/bin/console system:check --wait --allow-empty-database
roundcube_init

/opt/admin/bin/console doctrine:migrations:migrate -n
/opt/admin/bin/console dkim:refresh
