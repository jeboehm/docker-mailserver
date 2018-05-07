#!/bin/sh

FILTER_VIRUS_ARGS=""
if [ ${FILTER_VIRUS} == "true" ]
then
    FILTER_VIRUS_ARGS="-wait tcp://${FILTER_VIRUS_HOST}:3310"
fi

if ! [ -f /var/lib/rspamd/bayes.spam.sqlite ]
then
    cp /usr/share/rspamd/bayes.spam.sqlite /var/lib/rspamd/bayes.spam.sqlite
fi

if ! [ -f /var/lib/rspamd/bayes.ham.sqlite ]
then
    cp /usr/share/rspamd/bayes.ham.sqlite /var/lib/rspamd/bayes.ham.sqlite
fi

dockerize \
  -template /etc/rspamd/local.d/antivirus.conf.templ:/etc/rspamd/local.d/antivirus.conf \
  ${FILTER_VIRUS_ARGS} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/sbin/rspamd -c /etc/rspamd/rspamd.conf -f
