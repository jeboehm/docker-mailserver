#!/bin/sh

echo "Starting spamassassin.."

sa-update

SA_HOME=/var/lib/spamassassin/.spamassassin

if ! [ -d ${SA_HOME} ]
then
    mkdir ${SA_HOME}
    chown debian-spamd ${SA_HOME}
fi

spamd \
    --username=debian-spamd \
    --syslog stderr \
    --pidfile=/run/spamd.pid \
    --max-children 5 \
    --helper-home-dir \
    --nouser-config
