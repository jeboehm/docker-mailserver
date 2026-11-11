# Submission accepts only senders the authenticated login owns

## Status

Accepted

## Context

A client that authenticates on the submission port could otherwise put any address into `MAIL FROM`, including the address of another user on the same server. Postfix only knows the SASL login name, so it cannot tell on its own which sender addresses that login may use.

## Decision

The `submission` service in `target/mta/rootfs/etc/postfix/master.cf` sets `smtpd_sender_restrictions=reject_sender_login_mismatch,permit_sasl_authenticated,reject`.
`reject_sender_login_mismatch` compares the `MAIL FROM` address with the owners that `smtpd_sender_login_maps` returns for it.
`target/mta/rootfs/usr/local/lib/init.sh` points that map at the `email-submission` SQL query.
What counts as an owned address is defined in [ADR-0002](0002-sender-ownership-is-defined-by-the-login-map-query.md).

The restriction applies to the `submission` service only. Port 25 does not offer authentication, so the check has nothing to compare there: mail from the outside is subject to the `smtpd_recipient_restrictions` from `init.sh` instead.

A sender that is not owned, or not known at all, is refused. The tests observe this as a failure of the `RCPT TO` command (`RCPT failed`, cURL exit code 55).

## Consequences

- A login cannot forge the address of another user, nor of an alias that points to another user.
- The check is on the envelope sender (`MAIL FROM`). The `From:` header is not compared with it.
- Any change that makes the owner list wider, for example per-alias sender permissions, has to go through the query that [ADR-0002](0002-sender-ownership-is-defined-by-the-login-map-query.md) describes.

## Evidence

Tests in `test/bats/integration/040_mta.bats`:

- `unauthenticated mail is rejected`
- `authenticated mail is delivered`
- `authenticated mail with an unknown sender is rejected`
- `authenticated mail with the address of another mailbox as sender is rejected`
- `smtp authentication is not offered on port 25`

Not covered: that port 25 has no sender login check. `master.cf` sets `reject_sender_login_mismatch` for the `submission` service only; no test asserts the absence.
