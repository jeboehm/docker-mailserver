#!/bin/sh
set -e

# UDP check
if ! dig @127.0.0.1 -p 53 github.com +time=2 +tries=1 +short >/dev/null 2>&1; then
    echo "Healthcheck failed: dig UDP to 127.0.0.1:53"
    exit 1
fi

# TCP check (no nc dependency)
if ! dig +tcp @127.0.0.1 -p 53 github.com +time=2 +tries=1 +short >/dev/null 2>&1; then
    echo "Healthcheck failed: dig TCP to 127.0.0.1:53"
    exit 1
fi

echo "Healthcheck passed"
exit 0
