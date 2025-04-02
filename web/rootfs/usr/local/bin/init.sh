#!/bin/sh
# This script is used to initialize the container.
set -e

dockerize \
	-template /etc/nginx/nginx.conf.templ:/etc/nginx/nginx.conf \
	-template /var/www/html/autoconfig/config-v1.1.xml.templ:/var/www/html/autoconfig/config-v1.1.xml \
	/bin/true
