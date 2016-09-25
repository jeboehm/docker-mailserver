#!/bin/sh

echo "Starting spamassassin.."

SA_HOME=/var/lib/spamassassin/.spamassassin

if ! [ -d ${SA_HOME} ]
then
    mkdir ${SA_HOME}
    chown debian-spamd ${SA_HOME}
fi

/usr/local/bin/sa-update.sh --startup

spamd \
    --username=debian-spamd \
    --syslog stderr \
    --pidfile=/run/spamd.pid \
    --max-children 5 \
    --helper-home-dir \
    --nouser-config
