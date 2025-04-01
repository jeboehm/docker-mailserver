#!/bin/sh
# This script is used to initialize the container.
set -e

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"
postconf recipient_delimiter="${RECIPIENT_DELIMITER}"
postconf smtpd_milters="inet:${FILTER_HOST}:11332"
postconf non_smtpd_milters="inet:${FILTER_HOST}:11332"
postconf virtual_transport="lmtp:${MDA_HOST}:2003"
postconf smtpd_sasl_path="inet:${MDA_HOST}:2004"

if [ "${FILTER_MIME}" = "true" ]; then
	postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${RELAYHOST}" != "false" ]; then
	postconf relayhost="${RELAYHOST}"
	if [ "${RELAY_PASSWD_FILE}" != "false" ]; then
		#fix permissions for postmap
		chown root:root "${RELAY_PASSWD_FILE}"
		chmod 600 "${RELAY_PASSWD_FILE}"
		postmap "${RELAY_PASSWD_FILE}"
		postconf smtp_tls_security_level=may
		postconf smtp_sasl_auth_enable=yes
		postconf smtp_sasl_password_maps=lmdb:"${RELAY_PASSWD_FILE}"
		postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
	fi
	if [ "${RELAY_OPTIONS}" != "false" ]; then
		postconf smtp_sasl_security_options="${RELAY_OPTIONS}"
	fi
fi

dockerize \
	-template /etc/postfix/mysql-email2email.cf.templ:/etc/postfix/mysql-email2email.cf \
	-template /etc/postfix/mysql-virtual-alias-maps.cf.templ:/etc/postfix/mysql-virtual-alias-maps.cf \
	-template /etc/postfix/mysql-virtual-mailbox-domains.cf.templ:/etc/postfix/mysql-virtual-mailbox-domains.cf \
	-template /etc/postfix/mysql-virtual-mailbox-maps.cf.templ:/etc/postfix/mysql-virtual-mailbox-maps.cf \
	-template /etc/postfix/mysql-recipient-access.cf.templ:/etc/postfix/mysql-recipient-access.cf \
	-template /etc/postfix/mysql-email-submission.cf.templ:/etc/postfix/mysql-email-submission.cf \
	/bin/true
