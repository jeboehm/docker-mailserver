# Case handling of the sender

## Status

Accepted

## Context

Addresses reach the server in any case (`Alice@Example.COM`), and the database stores whatever the administrator entered.

## Decision

The `email-submission` query compares `lower('%s')` with the address built from the stored `name` and domain, as the other queries of the MTA do (`lower('%u')`, `lower('%d')`).
The sender is lower-cased in the query, and the stored data is not lower-cased by the query.
Matching therefore only works when the stored `name@domain` is lower case.
Stored data with upper case characters is never matched by a lower-cased sender and cannot be used to send.

The repository does not enforce lower case in the database. Whether mailserver-admin lower-cases what it stores has not been checked here.

Postfix may fold the key to lower case itself before it reaches the query. The test below cannot tell the two apart, and the behaviour for clients is the same either way: a sender in any case is accepted for the login that owns the lower-case address.

## Consequences

- Clients and tests compare addresses in lower case.
- Mixed-case `MAIL FROM` is accepted for the owner and rejected for everyone else, as for lower case.

## Evidence

Test in `test/bats/integration/040_mta.bats`: `authenticated mail with a mixed case sender is delivered`.

Not covered: stored data with upper case characters (that statement follows from the query), and the `destination` column of aliases, which the query returns as stored. Whether Postfix compares it with the SASL login name case-insensitively has not been checked.
