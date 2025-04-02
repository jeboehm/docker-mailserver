#!/bin/sh
# This script is used to initialize the container.
set -e

dockerize \
	-template /etc/dovecot/conf.d/10-master.conf.templ:/etc/dovecot/conf.d/10-master.conf \
	-template /etc/dovecot/conf.d/15-lda.conf.templ:/etc/dovecot/conf.d/15-lda.conf \
	-template /etc/dovecot/conf.d/15-fts-xapian.conf.templ:/etc/dovecot/conf.d/15-fts-xapian.conf \
	-template /etc/dovecot/conf.d/90-sieve.conf.templ:/etc/dovecot/conf.d/90-sieve.conf \
	-template /etc/dovecot/dovecot-sql.conf.ext.templ:/etc/dovecot/dovecot-sql.conf.ext \
	/bin/true
