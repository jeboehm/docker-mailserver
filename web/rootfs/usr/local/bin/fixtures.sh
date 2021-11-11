#!/bin/sh

dockerize \
  -wait tcp://${WEB_HOST}:80 \
  -wait tcp://${MYSQL_HOST}:3306 \
  -timeout ${WAITSTART_TIMEOUT} \
  ${@}
