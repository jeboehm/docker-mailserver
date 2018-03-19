#!/bin/sh
set -e

dockerize \
  -wait tcp://${MYSQL_HOST}:3306 \
  -timeout 30s \
  /usr/local/bin/rc_init.sh

dockerize \
  -wait tcp://${MYSQL_HOST}:3306 \
  -wait tcp://${MDA_HOST}:143 \
  -wait tcp://${MTA_HOST}:25 \
  -timeout 30s \
  /usr/bin/supervisord
