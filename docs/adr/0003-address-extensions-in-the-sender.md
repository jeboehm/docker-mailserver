# Address extensions in the sender

## Status

Accepted

## Context

With `RECIPIENT_DELIMITER` (default `-`), `user-tag@example.com` is delivered to `user@example.com`. A client may use such an address as its envelope sender, for example one address per web shop.

## Decision

A sender with the recipient delimiter appended is accepted for the login that owns the address without the extension. `user-tag@example.com` is accepted for the login `user@example.com`.

The query in `email-submission.query` compares the sender exactly and has no knowledge of the delimiter.
The extension is removed by Postfix: when a lookup of the full address finds nothing, Postfix retries the address without the extension.
This was not found in the `smtpd_sender_login_maps` documentation, which lists only `user@domain`, `user` and `@domain`, so it was checked by behaviour instead.
A sender in `example.org`, a domain with no catch-all, is accepted with an extension (`fetchmailsource-extension@example.org`).
A sender in a domain with a catch-all is accepted for the catch-all destination regardless of the extension ([ADR-0002](0002-sender-ownership-is-defined-by-the-login-map-query.md)), which means that the older test for `example.com` does not prove the mechanism.

## Consequences

- The delimiter has to be the same for Postfix and Dovecot. Both read `RECIPIENT_DELIMITER` (`target/mta/rootfs/usr/local/lib/init.sh`, `target/mda/rootfs/etc/dovecot/conf.d/90-sieve.conf`).
- The behaviour is Postfix's and not the query's. A change of the Postfix version must be checked against the test.

## Evidence

Tests in `test/bats/integration/040_mta.bats`:

- `authenticated mail with address extension in the sender of a domain without catch-all is delivered` (the one that proves the mechanism)
- `authenticated mail with address extension in the sender is delivered` (`example.com`, masked by the catch-all)

Not checked: an extension on an alias address, and the behaviour for a user whose own local part contains the delimiter.
