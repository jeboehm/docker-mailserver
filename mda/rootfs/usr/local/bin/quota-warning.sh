#!/bin/sh

PERCENT="$1"
USER="$2"

if [ "${PERCENT}" == "" ] || [ "${USER}" == "" ]
then
    echo "Error: Missing parameters!"
    echo
    echo "Usage:"
    echo "$0 <percent> <user>"

    exit 1
fi

cat << EOF | /usr/libexec/dovecot/dovecot-lda -d $USER -o "plugin/quota=maildir:User quota:noenforcing"
From: docker-mailserver <$USER>
Subject: Quota warning - $PERCENT% reached

Your mailbox can only store a limited amount of emails.
Currently it is $PERCENT% full. If you reach 100% then
new emails cannot be stored. Thanks for your understanding.
EOF

