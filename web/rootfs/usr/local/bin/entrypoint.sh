#!/bin/sh
set -e

dockerize \
  -wait tcp://${MYSQL_HOST}:3306 \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/local/bin/rc_init.sh

/usr/local/bin/manager_init.sh

dockerize \
  -wait tcp://${MDA_HOST}:143 \
  -wait tcp://${MTA_HOST}:25 \
  -wait tcp://${FILTER_HOST}:11334 \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/bin/supervisord
