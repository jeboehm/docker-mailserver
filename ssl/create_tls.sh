#!/bin/sh
set -e

if [ -r ${SSL_CERT} ]
then
    echo "SSL certificate found. Exiting..."
    exit 0
fi

echo "No SSL certificate found. Creating a new one..."

openssl req -nodes -newkey rsa:2048 -keyout ${SSL_KEY} -out ${SSL_CSR} -subj "/C=${SSL_SUBJ_COUNTRY}/ST=${SSL_SUBJ_STATE}/L=${SSL_SUBJ_LOCALITY}/O=${SSL_SUBJ_ORGANIZATION}/OU=${SSL_SUBJ_ORGANIZATIONAL_UNIT}/CN=${MAILNAME}"
openssl x509 -req -days 3000 -in ${SSL_CSR} -signkey ${SSL_KEY} -out ${SSL_CERT}

echo "SSL certificate was successfully created! Exiting..."

exit 0
