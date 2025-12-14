#!/usr/bin/env bats

@test "certificates were created" {
	[ -f /media/tls/tls.crt ]
}

@test "compare certificate fingerprints" {
	MDA_FINGERPRINT=$(echo | openssl s_client -showcerts -connect "${MDA_IMAPS_ADDRESS}" 2>&1 | openssl x509 -fingerprint -noout)
	MTA_FINGERPRINT=$(echo | openssl s_client -showcerts -connect "${MTA_SMTP_ADDRESS}" -starttls smtp 2>&1 | openssl x509 -fingerprint -noout)

	[ "$MDA_FINGERPRINT" = "$MTA_FINGERPRINT" ]
}

@test "connection to imaps" {
	run bash -c 'echo -e "a1 LOGOUT\r\n" | openssl s_client -showcerts -quiet -brief -connect ${MDA_IMAPS_ADDRESS}'
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

@test "connection to submission with starttls" {
	run bash -c 'echo -e "QUIT\r\n" | openssl s_client -quiet -brief -connect ${MTA_SMTP_SUBMISSION_ADDRESS} -starttls smtp'
	[ "$status" -eq 0 ]
}
