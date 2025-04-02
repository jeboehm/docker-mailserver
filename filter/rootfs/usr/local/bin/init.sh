#!/bin/sh
# This script is used to initialize the container.
set -e

if [ "${CONTROLLER_PASSWORD}" = "changeme" ]; then
	# q1 is disabled in rspamd.
	CONTROLLER_PASSWORD_ENC="q1"
else
	CONTROLLER_PASSWORD_ENC="$(rspamadm pw -e -p "${CONTROLLER_PASSWORD}")"
fi

export CONTROLLER_PASSWORD_ENC

dockerize \
	-template /etc/rspamd/local.d/antivirus.conf.templ:/etc/rspamd/local.d/antivirus.conf \
	-template /etc/rspamd/local.d/worker-controller.inc.templ:/etc/rspamd/local.d/worker-controller.inc \
	-template /etc/rspamd/override.d/redis.conf.templ:/etc/rspamd/override.d/redis.conf \
	/bin/true
