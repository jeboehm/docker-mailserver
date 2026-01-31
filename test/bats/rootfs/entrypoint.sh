#!/bin/sh

if [ "${IS_KUBERNETES}" -eq "1" ]; then
	/usr/local/lib/kubectl.sh
fi

/usr/local/lib/wait-for-services.sh

exec "$@"
