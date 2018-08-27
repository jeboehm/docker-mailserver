#!/bin/sh
set -e

openssl dhparam -out /etc/dovecot/dh.pem.tmp 4096
mv /etc/dovecot/dh.pem.tmp /etc/dovecot/dh.pem
touch /etc/dovecot/dh.pem.created

echo "The Diffie Hellman file was generated."
echo "YOU SHOULD RESTART THIS CONTAINER NOW."

exit 0
