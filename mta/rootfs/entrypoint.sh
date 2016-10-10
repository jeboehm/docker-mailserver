#!/bin/sh

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

for file in /config/postfix/*.cf
do
    if ! [ -e "${file}" ]; then break; fi
    sed \
        -e "s/#dbname#/${MYSQL_DATABASE}/g" \
        -e "s/#hosts#/${MYSQL_HOST}/g" \
        -e "s/#password#/${MYSQL_PASSWORD}/g" \
        -e "s/#user#/${MYSQL_USER}/g" \
        "${file}" > "/etc/postfix/`basename ${file}`"
done

rm -f /etc/supervisor.d/postgrey.ini
postconf -X smtpd_recipient_restrictions

if [ $GREYLISTING_ENABLED == "true" ]
then
  cp /config/supervisord/postgrey.ini /etc/supervisor.d/postgrey.ini
  postconf smtpd_recipient_restrictions="permit_mynetworks permit_sasl_authenticated reject_unauth_destination check_policy_service inet:127.0.0.1:10023"
fi

newaliases
/usr/bin/supervisord
