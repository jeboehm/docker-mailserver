#!/bin/sh
set -e

manager_init() {
  cd /opt/manager

  bin/console doctrine:migrations:migrate -n
  bin/console doctrine:schema:update --force
}

roundcube_init() {
  cd /var/www/html/webmail
  PWD=`pwd`

  bin/initdb.sh --dir=$PWD/SQL || bin/updatedb.sh --dir=$PWD/SQL --package=roundcube || echo "Failed to initialize databse. Please run $PWD/bin/initdb.sh manually."
}

dockerize \
  -wait tcp://${MYSQL_HOST}:3306 \
  -wait tcp://${MDA_HOST}:143 \
  -wait tcp://${MTA_HOST}:25 \
  -wait tcp://${FILTER_HOST}:11334 \
  -timeout ${WAITSTART_TIMEOUT}

manager_init
roundcube_init

/usr/bin/supervisord
