#!/bin/sh
set -e

cd /opt/manager

bin/console doctrine:migrations:migrate -n
bin/console doctrine:schema:update --force
