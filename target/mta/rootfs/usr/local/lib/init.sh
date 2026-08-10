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
fi

# The lookup queries are written to work on both engines, so only the
# connection block differs. DB_DRIVER doubles as the postfix map type.
case "${DB_DRIVER}" in
mysql | pgsql) ;;
*)
	echo "Unsupported DB_DRIVER: ${DB_DRIVER} (expected mysql or pgsql)"
	exit 1
	;;
esac

for map in \
	virtual-mailbox-domains \
	virtual-mailbox-maps \
	virtual-alias-maps \
	email2email \
	email-submission \
	recipient-access; do
	cat "/etc/postfix/sql/connection-${DB_DRIVER}.templ" "/etc/postfix/sql/${map}.query" |
		envsubst >"/etc/postfix/sql/${map}.cf"
done

postconf virtual_mailbox_domains="${DB_DRIVER}:/etc/postfix/sql/virtual-mailbox-domains.cf"
postconf virtual_mailbox_maps="${DB_DRIVER}:/etc/postfix/sql/virtual-mailbox-maps.cf"
postconf virtual_alias_maps="${DB_DRIVER}:/etc/postfix/sql/virtual-alias-maps.cf,${DB_DRIVER}:/etc/postfix/sql/email2email.cf"
postconf smtpd_sender_login_maps="${DB_DRIVER}:/etc/postfix/sql/email-submission.cf"
postconf smtpd_recipient_restrictions="reject_unauth_destination,check_recipient_access ${DB_DRIVER}:/etc/postfix/sql/recipient-access.cf"
