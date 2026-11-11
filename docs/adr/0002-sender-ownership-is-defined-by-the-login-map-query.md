# Ownership of an address is defined by the sender login map query

## Status

Accepted

## Context

[ADR-0001](0001-submission-accepts-only-senders-the-login-owns.md) needs a definition of "the addresses a login owns". Postfix asks `smtpd_sender_login_maps` for the owners of the sender and compares them with the SASL login name, which is the full address of the user (`name@domain`).

## Decision

The query `target/mta/rootfs/etc/postfix/sql/email-submission.query` is the definition. For a sender it returns:

1. the user's own address, when a user with exactly that `name@domain` exists, and
2. the `destination` of every alias whose source is exactly that `name@domain`.

A login therefore owns its own mailbox address and every alias that has the login's address as one of its destinations. The match is exact on `name@domain`, apart from the two lookups Postfix adds (see below and [ADR-0003](0003-address-extensions-in-the-sender.md)).

An alias with several destinations is stored as several rows with the same source (`mail_aliases`), so the query returns several owners and each destination is an owner of the alias.

A catch-all alias is stored with an empty `name`, so its source reads `@domain`. Postfix looks up `@domain` as the last key after `user@domain`, so the destination of the catch-all owns every address of that domain that is not owned through a more specific row. This follows from how the data is laid out; the query has no special case for it. It is covered by a test so that a change shows up.

Not part of the definition:

- **Alias chains.** Only one level is followed. If an alias points to another alias, the owner is that alias address, which no login can have. This follows from the query; no test covers it.
- **Aliases pointing at external addresses.** The destination is an external address, and no login equals it, so nobody owns such an alias.
- **Wildcards other than the catch-all.** There is no pattern matching in the query.
- **Disabled and send-only users.** The query does not look at `enabled` or `send_only`. They are enforced when logging in: disabled accounts cannot authenticate (`authentication with disabled account is refused`), send-only accounts can authenticate and send (`authenticated mail from send only account is delivered`).

## Consequences

- There is no per-alias sender permission. Whoever receives mail for an alias may also send as it, and nobody else can.
- An alias that points to an external address cannot be used as a sender by anybody. Forwarding `info@example.com` to `someone@gmail.com` does not let anybody send as `info@example.com`.
- Two destinations of one alias are equal owners. Removing one destination removes that login's right to send as the alias.
- Because the catch-all counts, a domain with a catch-all lets the catch-all destination send as any address of the domain.

## Evidence

Tests in `test/bats/integration/040_mta.bats`:

- `authenticated mail with an alias as sender is delivered`
- `authenticated mail with an unknown sender is rejected`
- `authenticated mail with an alias of another login as sender is rejected`
- `authenticated mail with an alias with several destinations as sender is delivered for each destination`
- `authenticated mail with an alias with several destinations as sender is rejected for other logins`
- `authenticated mail with any sender of a domain with a catch-all is delivered for the catch-all destination only`
- `authenticated mail from send only account is delivered`

The fixtures in `test/fixtures.sh` provide `foo@example.com`, `foo@example.org`, `team@example.org` (two destinations) and the catch-all of `example.com`.

Not covered by a test: alias chains and aliases with an external destination.
