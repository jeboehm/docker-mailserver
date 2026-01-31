#!/bin/sh
set -e

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

/usr/local/lib/init.sh

if ! [ -r /etc/postfix/tls/tls.crt ] || ! [ -r /etc/postfix/tls/tls.key ]; then
	echo "Error: TLS certificate or key not found"
	echo "Please mount the certificate and key files to /etc/postfix/tls/tls.crt and /etc/postfix/tls/tls.key"
	exit 1
fi

/usr/local/lib/wait-for-services.sh

exec /usr/sbin/postfix start-fg
