#!/bin/sh

set -e

for plugin in ${RC_PLUGINS}
do
    echo "Installing Roundcube plugin: ${plugin}:"

    composer --working-dir=/var/www/html/webmail --ignore-platform-reqs --prefer-dist --prefer-stable --no-interaction --optimize-autoloader --apcu-autoloader require $plugin
done

echo "Done."
