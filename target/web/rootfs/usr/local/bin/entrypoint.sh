#!/bin/sh
set -e

if [ "${SKIP_INIT}" != "true" ]; then
	/usr/local/bin/init.sh
fi

/usr/local/bin/init_database.sh

# shellcheck disable=SC3028,SC2155
export APP_SECRET="$(echo $RANDOM | md5sum | head -c 20)"

/usr/bin/supervisord -c /etc/supervisord.conf
