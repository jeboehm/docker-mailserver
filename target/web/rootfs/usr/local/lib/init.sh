#!/bin/sh
# This script is used to initialize the container.
set -e

dockerize \
	-template "/opt/autoconfig/config-v1.1.xml.templ:${SERVER_ROOT}/autoconfig/config-v1.1.xml" \
	/bin/true

/usr/local/lib/init_database.sh
