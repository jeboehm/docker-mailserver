#!/bin/sh
set -e

for PLUGIN in ${RC_PLUGINS}; do
	echo "Installing Roundcube plugin: ${PLUGIN}:"

	composer --working-dir=/var/www/html/webmail --ignore-platform-reqs --prefer-dist --prefer-stable --no-interaction --optimize-autoloader --apcu-autoloader require "${PLUGIN}"
done

echo "Done."
