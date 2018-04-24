#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${DIR}" || exit

postfix start

dockerize \
  -wait tcp://${MYSQL_HOST}:3306 \
  -wait tcp://example.com:25 \
  -wait tcp://web:80 \
  -wait tcp://mda:143 \
  -timeout ${WAITSTART_TIMEOUT} \
  bats *.bats
