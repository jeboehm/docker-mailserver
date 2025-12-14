# Local Address Extension

Local address extension allows multiple unique email addresses to be delivered to a single mailbox without additional configuration. This feature implements RFC 5233 subaddressing and is commonly known as plus-addressing.

## Implementation

The feature appends a configurable delimiter followed by any string to the base email address. All emails sent to extended addresses are delivered to the original mailbox. The default delimiter is `-` (dash).

Alternative names for this feature:

- Plus-addressing (traditional `+` delimiter)
- Subaddressing (RFC 5233 standard)
- Address tagging

## Examples

```text
user1-friends@example.com
user1-1382@example.com
user1-newsletter@example.com
user1-shopping@example.com
user1-temp@example.com
```

## Configuration

Configure the delimiter using the `RECIPIENT_DELIMITER` environment variable:

```yaml
environment:
  - RECIPIENT_DELIMITER=+
```

This changes the delimiter from `-` to `+`, allowing addresses like `user1+friends@example.com`.

## Sieve Integration

Extended addresses can be used in Sieve filtering rules for automated email processing. Sieve rules can sort emails into folders, apply actions, or forward based on the extension used.

Example Sieve rule for `user1-newsletter@example.com`:

```sieve
if address :matches :localpart "to" "user1-newsletter*" {
    fileinto "Newsletters";
}
```

## Use Cases

- Email categorisation by source or purpose
- Service-specific addresses without multiple mailboxes
- Spam source identification
- Temporary address generation
- Email routing and filtering
