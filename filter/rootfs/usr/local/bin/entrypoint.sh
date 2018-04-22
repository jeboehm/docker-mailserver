#!/bin/sh

dockerize \
  -template /etc/rspamd/override.d/antivirus.conf.templ:/etc/rspamd/override.d/antivirus.conf \
  /usr/sbin/rspamd -c /etc/rspamd/rspamd.conf -f