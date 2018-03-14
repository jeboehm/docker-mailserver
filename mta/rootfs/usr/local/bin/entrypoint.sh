#!/bin/sh
postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

if [ "${FILTER_MIME}" == "true" ]
then
  postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${DISCARD_DSN}" == "true" ]
then
  postconf "smtpd_discard_ehlo_keywords=silent-discard, dsn"
fi

dockerize \
  -template /etc/postfix/mysql-email2email.cf.templ:/etc/postfix/mysql-email2email.cf \
  -template /etc/postfix/mysql-virtual-alias-maps.cf.templ:/etc/postfix/mysql-virtual-alias-maps.cf \
  -template /etc/postfix/mysql-virtual-mailbox-domains.cf.templ:/etc/postfix/mysql-virtual-mailbox-domains.cf \
  -template /etc/postfix/mysql-virtual-mailbox-maps.cf.templ:/etc/postfix/mysql-virtual-mailbox-maps.cf \
  -wait tcp://${MYSQL_HOST}:3306 \
  -wait tcp://${MDA_HOST}:2003 \
  -wait tcp://${RSPAMD_HOST}:11332 \
  -wait file://${SSL_CERT} \
  -wait file://${SSL_KEY} \
  /usr/bin/supervisord
