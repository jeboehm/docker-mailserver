#!/bin/sh
# This script is used to initialize the admin user.

if [ -z "${INIT_ADMIN_DOMAIN}" ] || [ -z "${INIT_ADMIN_NAME}" ] || [ -z "${INIT_ADMIN_PASSWORD}" ]; then
	echo "Error: INIT_ADMIN_DOMAIN, INIT_ADMIN_NAME, and INIT_ADMIN_PASSWORD must be set."
	exit 1
fi

/opt/manager/bin/console domain:add "${INIT_ADMIN_DOMAIN}"
/opt/manager/bin/console user:add --admin --password="${INIT_ADMIN_PASSWORD}" --enable "${INIT_ADMIN_NAME}" "${INIT_ADMIN_DOMAIN}"

exit 0
