#!/bin/sh

dockerize \
  -wait tcp://web:80 \
  -wait tcp://${MYSQL_HOST}:3306 \
  -timeout ${WAITSTART_TIMEOUT} \
  ${@}
