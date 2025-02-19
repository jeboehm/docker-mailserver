#!/bin/sh
set -e

manager_init() {
  cd /opt/manager

  bin/console doctrine:migrations:migrate -n
}

roundcube_init() {
  cd /var/www/html/webmail
  PWD=$(pwd)

  bin/initdb.sh --dir="$PWD/SQL" || bin/updatedb.sh --dir="$PWD/SQL" --package=roundcube || echo "Failed to initialize databse. Please run $PWD/bin/initdb.sh manually."
  rm -f /var/www/html/webmail/logs/errors.log
}

dkim_refresh() {
  cd /opt/manager

  bin/console dkim:refresh
}

dockerize \
  -wait "tcp://${MYSQL_HOST}:${MYSQL_PORT}" \
  -wait "tcp://${MDA_HOST}:143" \
  -wait "tcp://${MTA_HOST}:25" \
  -wait "tcp://${FILTER_HOST}:11334" \
  -timeout "${WAITSTART_TIMEOUT}" \
  -template /etc/nginx/nginx.conf.templ:/etc/nginx/nginx.conf \
  -template /var/www/html/autoconfig/config-v1.1.xml.templ:/var/www/html/autoconfig/config-v1.1.xml

manager_init
roundcube_init
dkim_refresh

# shellcheck disable=SC3028,SC2155
export APP_SECRET="$(echo $RANDOM | md5sum | head -c 20)"

/usr/bin/supervisord -c /etc/supervisord.conf
