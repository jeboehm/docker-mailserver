#!/bin/sh

FILTER_VIRUS_ARGS=""
if [ ${FILTER_VIRUS} == "true" ]
then
    FILTER_VIRUS_ARGS="-wait tcp://${FILTER_VIRUS_HOST}:3310"
fi

dockerize \
  -template /etc/rspamd/override.d/antivirus.conf.templ:/etc/rspamd/override.d/antivirus.conf \
  ${FILTER_VIRUS_ARGS} \
  /usr/sbin/rspamd -c /etc/rspamd/rspamd.conf -f