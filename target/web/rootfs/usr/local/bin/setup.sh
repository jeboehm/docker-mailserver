#!/bin/sh
set -e

/opt/admin/bin/console system:check --wait

exec /opt/admin/bin/console init:setup
