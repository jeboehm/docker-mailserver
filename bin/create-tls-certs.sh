#!/bin/bash
# Helper script to create a self-signed tls certificate.
# Usage: bin/create-tls-certs.sh
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

## Guard against empty $DIR
if [[ "$DIR" != */bin ]]; then
	echo "Could not detect working directory."
	exit 1
fi

echo "This creates a self-signed tls certificate."

OPENSSL=$(which openssl)
TARGET_DIRECTORY="${DIR}/../config/tls"

if [ -z "$OPENSSL" ]; then
	echo "Could not find openssl."
	exit 1
fi

if ! [ -d "$TARGET_DIRECTORY" ]; then
	mkdir -p "$TARGET_DIRECTORY" || exit 1
fi

openssl req -x509 -newkey rsa:4096 -keyout "${TARGET_DIRECTORY}/tls.key" -out "${TARGET_DIRECTORY}/tls.crt" -sha256 \
	-days 365 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname"

chmod 0644 "${TARGET_DIRECTORY}/tls.crt" "${TARGET_DIRECTORY}/tls.key"

echo "TLS certificate was successfully created! Exiting..."

exit 0
