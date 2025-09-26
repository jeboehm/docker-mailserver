# Features

This document describes the features available in docker-mailserver.

## Local Address Extension

Local address extension allows multiple unique email addresses to be delivered to a single mailbox without additional configuration. This feature implements RFC 5233 subaddressing and is commonly known as plus-addressing.

### Implementation

The feature appends a configurable delimiter followed by any string to the base email address. All emails sent to extended addresses are delivered to the original mailbox. The default delimiter is `-` (dash).

Alternative names for this feature:


- Plus-addressing (traditional `+` delimiter)
- Subaddressing (RFC 5233 standard)
- Address tagging

### Examples

```text
user1-friends@example.com
user1-1382@example.com
user1-newsletter@example.com
user1-shopping@example.com
user1-temp@example.com
```

### Configuration

Configure the delimiter using the `RECIPIENT_DELIMITER` environment variable:

```yaml
environment:
  - RECIPIENT_DELIMITER=+
```

This changes the delimiter from `-` to `+`, allowing addresses like `user1+friends@example.com`.

### Sieve Integration

Extended addresses can be used in Sieve filtering rules for automated email processing. Sieve rules can sort emails into folders, apply actions, or forward based on the extension used.

Example Sieve rule for `user1-newsletter@example.com`:

```
if address :matches :localpart "to" "user1-newsletter*" {
    fileinto "Newsletters";
}
```

### Use Cases

- Email categorisation by source or purpose
- Service-specific addresses without multiple mailboxes
- Spam source identification
- Temporary address generation
- Email routing and filtering

## DKIM Signing

DKIM (DomainKeys Identified Mail) signing provides cryptographic authentication for outgoing emails. This feature signs all outgoing emails from configured domains with a private key, allowing recipients to verify email authenticity through DNS records.

### Implementation details

DKIM signing is implemented using the Rspamd DKIM module. Each domain requires a separate DKIM key pair consisting of a private key (stored in docker-mailserver) and a public key (published in DNS).

Rspamd verifies the DNS record for each domain before signing outgoing messages. This ensures that only domains with valid DKIM DNS records will have their emails signed, preventing false signatures.

### Configuration steps

Configure DKIM through the management interface:

1. Access the management interface
2. Navigate to DKIM in the menu bar
3. Select the domain for DKIM configuration
4. Generate the private key
5. Add the provided DNS TXT record to your domain's DNS
6. Verify the DNS record through the management interface
7. Enable DKIM signing for the domain

### DNS Record

The management interface provides a DNS TXT record that must be added to your domain's DNS configuration. The record contains the public key used for DKIM verification by receiving mail servers.

### Operation

Once enabled, all outgoing emails from the configured domain are automatically signed with the DKIM private key. Receiving mail servers can verify the signature using the public key published in DNS, confirming the email's authenticity and integrity.
