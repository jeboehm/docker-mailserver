#!/bin/sh
set -e

# Test DNS resolution using dig
if ! dig @127.0.0.1 -p 5353 github.com >/dev/null 2>&1; then
	echo "Healthcheck failed: DNS resolution test failed"
	exit 1
fi

# Test UDP connectivity (unbound typically uses UDP for DNS)
if ! dig @127.0.0.1 -p 5353 +tcp github.com >/dev/null 2>&1; then
	echo "Healthcheck failed: TCP DNS resolution test failed"
	exit 1
fi

echo "Healthcheck passed"

exit 0
