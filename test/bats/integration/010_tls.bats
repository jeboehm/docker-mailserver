#!/usr/bin/env bats

@test "certificates were created" {
	[ -f /media/tls/tls.crt ]
}

@test "connection to imaps" {
	run bash -c 'echo -e "a1 LOGOUT\r\n" | openssl s_client -quiet -brief -connect ${MDA_IMAPS_ADDRESS}'
	[ "$status" -eq 0 ]
}

@test "connection to pop3s" {
	run bash -c 'echo -e "QUIT\r\n" | openssl s_client -quiet -brief -connect ${MDA_POP3S_ADDRESS}'
	[ "$status" -eq 0 ]
}

@test "connection to pop3 with starttls" {
	run bash -c 'echo -e "QUIT\r\n" | openssl s_client -quiet -brief -connect ${MDA_POP3_ADDRESS} -starttls pop3'
	[ "$status" -eq 0 ]
}

@test "connection to imap with starttls" {
	run bash -c 'echo -e "a1 LOGOUT\r\n" | openssl s_client -quiet -brief -connect ${MDA_IMAP_ADDRESS} -starttls imap'
	[ "$status" -eq 0 ]
}

@test "connection to smtp with starttls" {
	run bash -c 'echo -e "QUIT\r\n" | openssl s_client -quiet -brief -connect ${MTA_SMTP_ADDRESS} -starttls smtp'
	[ "$status" -eq 0 ]
}
