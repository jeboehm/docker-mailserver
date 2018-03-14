#!/bin/sh
set -e

if [ -r ${SSL_CERT} ]
then
    echo "SSL certificate found. Exiting..."
    exit 0
fi

echo "No SSL certificate found. Creating a new one..."

openssl req -nodes -newkey rsa:2048 -keyout ${SSL_KEY} -out ${SSL_CSR} -subj "/C=DE/ST=Northrhine-Westfalia/L=Dusseldorf/O=Mail/OU=Mail/CN=${MAILNAME}"
openssl x509 -req -days 3000 -in ${SSL_CSR} -signkey ${SSL_KEY} -out ${SSL_CERT}

cat ${SSL_CERT}

exit 0
