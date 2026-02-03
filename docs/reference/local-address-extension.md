# Local Address Extension Reference

Local address extension (RFC 5233 subaddressing) delivers mail to extended addresses at the same mailbox without extra configuration. A configurable delimiter plus a tag is appended to the local part; all such mail is delivered to the base mailbox.

## Configuration

| Variable              | Default | Description         |
| --------------------- | ------- | ------------------- |
| `RECIPIENT_DELIMITER` | `-`     | Delimiter character |

Example with default delimiter `-`:

```text
user1-friends@example.com
user1-newsletter@example.com
```

Example with `RECIPIENT_DELIMITER=+`:

```text
user1+friends@example.com
user1+newsletter@example.com
```

## Sieve

Extended addresses can be matched in Sieve. Example for `user1-newsletter@example.com`:

```sieve
if address :matches :localpart "to" "user1-newsletter*" {
    fileinto "Newsletters";
}
```
