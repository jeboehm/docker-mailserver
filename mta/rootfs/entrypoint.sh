#!/bin/sh

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

for file in /etc/postfix/mysql-*.cf
do
    if ! [ -e "${file}" ]; then break; fi
    sed -i \
        -e "s/#dbname#/${MYSQL_DATABASE}/g" \
        -e "s/#hosts#/${MYSQL_HOST}/g" \
        -e "s/#password#/${MYSQL_PASSWORD}/g" \
        -e "s/#user#/${MYSQL_USER}/g" \
        "${file}"
done

if [ "${GREYLISTING_ENABLED}" == "true" ]
then
  postconf smtpd_recipient_restrictions="permit_mynetworks permit_sasl_authenticated reject_unauth_destination check_policy_service inet:127.0.0.1:10023"

  if [ "${TEST_MODE}" == "true" ]
  then
    postconf mynetworks="127.0.0.0/8"
  fi
else
  rm -f /etc/supervisor.d/postgrey.ini
fi

newaliases
/usr/bin/supervisord
