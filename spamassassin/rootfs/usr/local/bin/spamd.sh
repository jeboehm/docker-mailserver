#!/bin/sh
echo "Starting spamassassin.."

/usr/local/bin/sa-update.sh --startup

/usr/sbin/spamd \
    --syslog stderr \
    --pidfile=${SA_HOME}/spamd.pid \
    --max-children 5 \
    --helper-home-dir=${SA_HOME} \
    --nouser-config \
    --listen 127.0.0.1:1783
