#!/bin/sh

FILTER_VIRUS_ARGS=""
if [ "${FILTER_VIRUS}" = "true" ]
then
    FILTER_VIRUS_ARGS="-wait tcp://${FILTER_VIRUS_HOST}:3310"
fi

if [ "${CONTROLLER_PASSWORD}" = "changeme" ]
then
    # q1 is disabled in rspamd.
    CONTROLLER_PASSWORD_ENC="q1"
else
    CONTROLLER_PASSWORD_ENC="$(rspamadm pw -e -p "${CONTROLLER_PASSWORD}")"
fi

export CONTROLLER_PASSWORD_ENC

# shellcheck disable=SC2086
dockerize \
  -template /etc/rspamd/local.d/antivirus.conf.templ:/etc/rspamd/local.d/antivirus.conf \
  -template /etc/rspamd/local.d/worker-controller.inc.templ:/etc/rspamd/local.d/worker-controller.inc \
  -template /etc/rspamd/override.d/redis.conf.templ:/etc/rspamd/override.d/redis.conf \
  -template /etc/rspamd/local.d/classifier-bayes.conf.templ:/etc/rspamd/local.d/classifier-bayes.conf \
  ${FILTER_VIRUS_ARGS} \
  -timeout "${WAITSTART_TIMEOUT}" \
  /usr/bin/rspamd -c /etc/rspamd/rspamd.conf -f
