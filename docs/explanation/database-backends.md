# Database Backends

docker-mailserver stores domains, users, aliases and DKIM configuration in a relational database.
Both MySQL/MariaDB and PostgreSQL are supported, selected with `DB_DRIVER`. MySQL is the default.

## Why Two Backends

The mailserver never needed more than one engine, but the environment it runs in often already has
one. Requiring MySQL next to an existing PostgreSQL cluster means operating a second database for
no functional gain: another backup schedule, another upgrade path, another set of credentials.

Neither engine is better here. The data is small, the queries are simple lookups, and both handle
the load without tuning. Pick whichever one is already operated.

## What Talks to the Database

Three services connect to it:

- **mta** (Postfix) resolves domains, mailboxes and aliases through SQL lookup tables
- **mda** (Dovecot) authenticates users and reads quotas through `passdb` and `userdb`
- **web** (mailserver-admin and Roundcube) owns the schema and writes it through Doctrine

`filter` (Rspamd), `redis`, `unbound`, `ssl` and `fetchmail` never touch it. Rspamd keeps
everything including DKIM keys in Redis.

Postfix and Dovecot query the database directly rather than going through the admin application.
Their queries are therefore part of this repository, while the schema belongs to
[mailserver-admin](https://github.com/jeboehm/mailserver-admin).

## How the Engine Is Selected

`DB_DRIVER` is the only switch, and its value is used verbatim by all four consumers: it is the
Postfix lookup table type, Dovecot's `sql_driver`, Roundcube's DSN scheme and Doctrine's DSN
scheme. No translation table is involved.

The images ship both client libraries, so switching engines needs no rebuild:

- `mta` contains `postfix-mysql` and `postfix-pgsql`
- `mda` contains `dovecot-mysql` and `dovecot-pgsql`
- `web` uses FrankenPHP, which bundles `pdo_mysql` and `pdo_pgsql`

The lookup queries themselves are written to run unchanged on both engines. Only the connection
block differs, so `mta` keeps one set of `.query` files and two `connection-*.templ` files that
its entrypoint combines. Dovecot cannot do the same, because its driver settings block is named
after the engine and cannot be selected through a variable; its entrypoint writes the matching
block to `/run/dovecot/auth-driver.conf` instead, which is the writable location available on a
read-only root filesystem.

## Case Sensitivity

This is the one behavioural difference that matters.

The MySQL collation used so far compares case insensitively, so `Bob@Example.COM` matched the
stored `bob@example.com`. PostgreSQL's default collation compares case sensitively, and the same
delivery or login attempt would return no rows: mail bounces, IMAP authentication fails.

Rather than reproduce the MySQL behaviour in the schema, addresses are normalised on the way in
and on the way out. The admin application validates and stores them lowercase, and every lookup
wraps its input in `lower()`. The comparison stays index friendly, because the column is not
wrapped, only the value being searched for.

Two alternatives were rejected. A nondeterministic ICU collation breaks the admin interface, since
PostgreSQL refuses `LIKE` on nondeterministic collations and the search in the user lists relies on
it. The `citext` type needs `CREATE EXTENSION` privileges during bootstrap and a custom Doctrine
type.

If you migrate data from an older installation that predates the address validation, check for
mixed case rows before switching engines. They resolve on MySQL and stop resolving on PostgreSQL:

```sql
SELECT name FROM mail_users WHERE name <> lower(name);
SELECT name FROM mail_domains WHERE name <> lower(name);
```

## Schema Differences

The two schemas are equivalent but not identical, because MySQL installations carry history that
PostgreSQL ones do not.

The MySQL schema grew through migrations reaching back to a 2018 table rename, and that rename
left the foreign keys under their previous names. A PostgreSQL database is created from a baseline
migration and gets the canonical names instead. Likewise, `mail_users.domain_admin` has a default
of `0` on MySQL, added by the migration that introduced it, and no default on PostgreSQL, because
the mapping declares none. Nothing writes to these tables outside the ORM, so neither difference is
observable at runtime.

PostgreSQL installations need no bootstrap SQL at all. Doctrine creates its own bookkeeping table,
the baseline migration builds the schema, and Roundcube picks its PostgreSQL schema based on the
DSN. `target/db/mysql/initdb.d/` exists only because the MySQL migration history cannot be replayed
from scratch.

## Server Version

`DB_SERVER_VERSION` has to be set to match the server. Doctrine detects the MySQL version by
itself, but not the PostgreSQL one in this image, and an undetected version aborts the connection
with `Invalid platform version ""`.

## Switching Engines

There is no migration path between the two. `DB_DRIVER` selects which engine to talk to; it does
not move data. Switching an existing installation means exporting the domains, users and aliases
and recreating them against the new database.

When using the bundled database container, run `make clean` before switching. PostgreSQL refuses
to initialise into a data directory that already holds MySQL files, and reports it as a permission
error rather than an obvious one.
