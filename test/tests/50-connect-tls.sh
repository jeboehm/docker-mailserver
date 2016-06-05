#!/bin/sh

true | openssl s_client -showcerts -connect mda:993
true | openssl s_client -showcerts -connect mda:995
true | openssl s_client -showcerts -connect mda:110 -starttls pop3
true | openssl s_client -showcerts -connect mda:143 -starttls imap
