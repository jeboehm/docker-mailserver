#!/bin/sh
set -e

/opt/admin/bin/console system:check --wait
/opt/admin/bin/console init:setup
