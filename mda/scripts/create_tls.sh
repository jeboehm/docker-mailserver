#!/bin/sh

CERTNAME="/media/tls/mailserver"

openssl req -nodes -newkey rsa:2048 -keyout $CERTNAME.key -out $CERTNAME.csr -subj "/C=DE/ST=Northrhine-Westfalia/L=Dusseldorf/O=Mail/OU=Mail/CN=${MAILNAME}"
openssl x509 -req -days 3000 -in $CERTNAME.csr -signkey $CERTNAME.key -out $CERTNAME.crt
