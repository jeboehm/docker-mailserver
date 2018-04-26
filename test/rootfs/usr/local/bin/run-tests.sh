#!/bin/sh

dockerize \
  -wait tcp://db:3306 \
  -wait tcp://mta:25 \
  -wait tcp://web:80 \
  -wait tcp://mda:143 \
  -timeout ${WAITSTART_TIMEOUT} \
  bats /usr/share/tests/*.bats
