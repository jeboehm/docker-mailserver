#!/bin/sh

sleep 60

while true
do
    if ! [ -r /run/spamd.pid ]
    then
        "spamd not running. Exit."
        exit 1
    fi

	echo "Updating spamassassin ruleset.."
	sa-update
	kill -1 $(cat /var/run/spamd.pid)

	sleep 6h
done
