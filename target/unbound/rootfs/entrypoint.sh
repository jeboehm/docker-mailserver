#!/bin/sh
set -e

[ "$#" -gt 0 ] && exec "$@"

if [ -r /.banner.sh ]; then
	/.banner.sh
fi

# The root filesystem is read-only: the remote-control keys and the trust
# anchor live in the writable /run/unbound (tmpfs / emptyDir).
if ! [ -f /run/unbound/unbound_server.key ] || ! [ -f /run/unbound/unbound_control.key ]; then
	unbound-control-setup -d /run/unbound
fi

# unbound-anchor exits 1 when it had to (re)create the anchor.
unbound-anchor -a /run/unbound/root.key || true

exec unbound -dp
