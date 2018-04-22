#!/bin/sh

if [ ${FILTER_VIRUS} == "false" ]
then
    exit 0
fi

/usr/bin/freshclam -d -l /dev/stdout
/usr/sbin/clamd