#!/bin/sh
set -e

if [ -r /run/dovecot/master.pid ]; then
	rm /run/dovecot/master.pid
fi

# The driver settings block is named after the engine, so it cannot be
# selected through an environment variable. /run/dovecot is the writable
# location available on a read-only root filesystem.
if [ ! -r "/etc/dovecot/auth-driver-${DB_DRIVER}.conf" ]; then
	echo "Unsupported DB_DRIVER: ${DB_DRIVER} (expected mysql or pgsql)"
	exit 1
fi

# The TLS settings are booleans, which are not expanded from the environment,
# so database TLS lives in a second driver file that is selected here instead.
driver_conf="/etc/dovecot/auth-driver-${DB_DRIVER}.conf"
if [ "${DB_TLS_VERIFY_CERT}" = "true" ] || [ "${DB_TLS_VERIFY_CERT}" = "yes" ]; then
	if [ -r "/etc/dovecot/auth-driver-${DB_DRIVER}-tls.conf" ]; then
		driver_conf="/etc/dovecot/auth-driver-${DB_DRIVER}-tls.conf"
	else
		echo "DB_TLS_VERIFY_CERT is not supported with DB_DRIVER=${DB_DRIVER}"
		exit 1
	fi
fi
cp "${driver_conf}" /run/dovecot/auth-driver.conf

if [ -n "${MDA_UPSTREAM_PROXY}" ]; then
	if [ "${MDA_UPSTREAM_PROXY}" = "true" ]; then
		export MDA_UPSTREAM_PROXY="yes"
	else
		export MDA_UPSTREAM_PROXY="no"
	fi
fi

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

if ! [ -r /etc/dovecot/tls/tls.crt ] || ! [ -r /etc/dovecot/tls/tls.key ]; then
	echo "Error: TLS certificate or key not found"
	echo "Please mount the certificate and key files to /etc/dovecot/tls/tls.crt and /etc/dovecot/tls/tls.key"
	exit 1
fi

exec dovecot -F
