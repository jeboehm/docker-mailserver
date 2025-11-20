#!/bin/sh
# This script is used to initialize the container.
set -e

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"
postconf recipient_delimiter="${RECIPIENT_DELIMITER}"
postconf smtpd_milters="inet:${FILTER_MILTER_ADDRESS}"
postconf non_smtpd_milters="inet:${FILTER_MILTER_ADDRESS}"
postconf virtual_transport="lmtp:${MDA_LMTP_ADDRESS}"
postconf smtpd_sasl_path="inet:${MDA_AUTH_ADDRESS}"

if [ "${FILTER_MIME}" = "true" ]; then
	echo "Enabling MIME header checks"
	postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${RELAYHOST}" != "false" ]; then
	echo "Setting relayhost to ${RELAYHOST}"
	postconf relayhost="${RELAYHOST}"

	if [ "${RELAY_PASSWD_FILE}" != "false" ]; then
		if [ ! -f "${RELAY_PASSWD_FILE}" ]; then
			echo "Relay password file not found: ${RELAY_PASSWD_FILE}"
			exit 1
		fi

		echo "Setting relay password file to ${RELAY_PASSWD_FILE}"

		#fix permissions for postmap
		chown root:root "${RELAY_PASSWD_FILE}"
		chmod 600 "${RELAY_PASSWD_FILE}"
		postmap "${RELAY_PASSWD_FILE}"
		postconf smtp_sasl_auth_enable=yes
		postconf smtp_sasl_security_options=noanonymous
		postconf smtp_sasl_password_maps=lmdb:"${RELAY_PASSWD_FILE}"

		postconf smtp_tls_security_level=may
		postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
	fi
fi

if [ "${MTA_UPSTREAM_PROXY}" = "true" ]; then
	echo "Enabling upstream proxy protocol"
	postconf smtpd_upstream_proxy_protocol=haproxy
	postconf postscreen_upstream_proxy_protocol=haproxy
	postconf submission_upstream_proxy_protocol=haproxy
fi

dockerize \
	-template /etc/postfix/mysql-email2email.cf.templ:/etc/postfix/mysql-email2email.cf \
	-template /etc/postfix/mysql-virtual-alias-maps.cf.templ:/etc/postfix/mysql-virtual-alias-maps.cf \
	-template /etc/postfix/mysql-virtual-mailbox-domains.cf.templ:/etc/postfix/mysql-virtual-mailbox-domains.cf \
	-template /etc/postfix/mysql-virtual-mailbox-maps.cf.templ:/etc/postfix/mysql-virtual-mailbox-maps.cf \
	-template /etc/postfix/mysql-recipient-access.cf.templ:/etc/postfix/mysql-recipient-access.cf \
	-template /etc/postfix/mysql-email-submission.cf.templ:/etc/postfix/mysql-email-submission.cf \
	/bin/true

# Configure resolver for Postfix to use $UNBOUND_DNS_ADDRESS
# Accept formats like "host:port" or "ip:port"; default port 53 if omitted
if [ -n "${UNBOUND_DNS_ADDRESS}" ]; then
	UNBOUND_DNS_HOST=$(echo "${UNBOUND_DNS_ADDRESS}" | cut -d: -f1)
	UNBOUND_DNS_PORT=$(echo "${UNBOUND_DNS_ADDRESS}" | cut -s -d: -f2)
	if [ -z "${UNBOUND_DNS_PORT}" ]; then
		UNBOUND_DNS_PORT=53
	fi

	# Resolve hostname to IP if necessary
	UNBOUND_DNS_IP=$(getent hosts "${UNBOUND_DNS_HOST}" | awk '{print $1}' | head -n1)
	if [ -z "${UNBOUND_DNS_IP}" ]; then
		UNBOUND_DNS_IP=${UNBOUND_DNS_HOST}
	fi

	mkdir -p /var/spool/postfix/etc
	echo "nameserver ${UNBOUND_DNS_IP}" > /var/spool/postfix/etc/resolv.conf
	# glibc resolv.conf does not support custom port; rely on Unbound standard port 53
fi
