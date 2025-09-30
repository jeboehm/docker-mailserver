#!/bin/sh
set -e

# 1. test connection to 0.0.0.0:53 (UDP via dig) and TCP via nc
if ! dig @127.0.0.1 -p 53 github.com +time=2 +tries=1 +short >/dev/null 2>&1; then
    echo "Healthcheck failed: dig to 127.0.0.1:53"
    exit 1
fi

if ! nc -z 0.0.0.0 53; then
    echo "Healthcheck failed: cannot connect to 0.0.0.0:53 (TCP)"
    exit 1
fi

echo "Healthcheck passed"
exit 0
