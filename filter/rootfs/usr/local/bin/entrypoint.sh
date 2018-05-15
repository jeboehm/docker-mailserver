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

if [ "${CONTROLLER_PASSWORD}" == "changeme" ]
then
    # q1 is disabled in rspamd.
    export CONTROLLER_PASSWORD_ENC="q1"
else
    export CONTROLLER_PASSWORD_ENC=`rspamadm pw -e -p ${CONTROLLER_PASSWORD}`
fi

dockerize \
  -template /etc/rspamd/local.d/antivirus.conf.templ:/etc/rspamd/local.d/antivirus.conf \
  -template /etc/rspamd/local.d/worker-controller.inc.templ:/etc/rspamd/local.d/worker-controller.inc \
  ${FILTER_VIRUS_ARGS} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/sbin/rspamd -c /etc/rspamd/rspamd.conf -f
