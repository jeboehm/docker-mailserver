#!/bin/sh
set -e

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"
postconf recipient_delimiter="${RECIPIENT_DELIMITER}"

if [ "${FILTER_MIME}" == "true" ]
then
  postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${RELAYHOST}" != "false" ]
then
  postconf relayhost=${RELAYHOST}
  if [ "${RELAY_PASSWD_FILE}" != "false" ]
  then
    #fix permissions for postmap
    chgrp postfix /etc/postfix/
    chmod 775 /etc/postfix/
    postmap ${RELAY_PASSWD_FILE}
    postconf smtp_use_tls=yes
    postconf smtp_sasl_auth_enable=yes
    postconf smtp_sasl_password_maps=hash:${RELAY_PASSWD_FILE}
    postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
  fi
  if [ "${RELAY_OPTIONS}" != "false" ]
  then
    postconf smtp_sasl_security_options=${RELAY_OPTIONS}
  fi
fi

dockerize \
  -template /etc/postfix/mysql-email2email.cf.templ:/etc/postfix/mysql-email2email.cf \
  -template /etc/postfix/mysql-virtual-alias-maps.cf.templ:/etc/postfix/mysql-virtual-alias-maps.cf \
  -template /etc/postfix/mysql-virtual-mailbox-domains.cf.templ:/etc/postfix/mysql-virtual-mailbox-domains.cf \
  -template /etc/postfix/mysql-virtual-mailbox-maps.cf.templ:/etc/postfix/mysql-virtual-mailbox-maps.cf \
  -template /etc/postfix/mysql-recipient-access.cf.templ:/etc/postfix/mysql-recipient-access.cf \
  -wait tcp://${MYSQL_HOST}:3306 \
  -wait tcp://${MDA_HOST}:2003 \
  -wait tcp://${RSPAMD_HOST}:11332 \
  -wait file://${SSL_CERT} \
  -wait file://${SSL_KEY} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/bin/supervisord
