# DNS Configuration

This document describes the DNS records required for the mailserver to function properly. All DNS records must be configured in your domain's DNS zone to enable email delivery, authentication, and reputation management.

## Overview

The mailserver requires several DNS record types to operate correctly:

- **MX Record**: Directs incoming emails to your mailserver
- **A/AAAA Records**: Resolve the mailserver hostname to IP addresses
- **SPF Record**: Authorizes your mailserver to send emails for your domain
- **DKIM Record**: Provides public key for email signature verification
- **DMARC Record**: Defines email authentication policy and reporting

## MX Record

The Mail Exchange (MX) record directs incoming emails to your mailserver. This is the primary DNS record that tells other mail servers where to deliver emails for your domain.

### MX Record Configuration

Create an MX record in your domain's DNS zone:

```text
Type: MX
Name: @ (or your domain name)
Priority: 10
Value: mail.example.com
```

Replace `mail.example.com` with the value configured in the `MAILNAME` environment variable. The priority value (10 in this example) determines the order when multiple MX records exist. Lower numbers have higher priority.

### MX Record Example

For domain `example.com` with mailserver hostname `mail.example.com`:

```text
example.com.    IN    MX    10    mail.example.com.
```

### MX Record Verification

Verify the MX record using DNS lookup tools:

```bash
dig MX example.com
# or
nslookup -type=MX example.com
```

## A and AAAA Records

A and AAAA records resolve the mailserver hostname to IPv4 and IPv6 addresses respectively. These records are required for the MX record to function, as the MX record points to a hostname that must resolve to an IP address.

### A/AAAA Record Configuration

Create A and AAAA records for your mailserver hostname:

```text
Type: A
Name: mail (or your mailserver hostname without domain)
Value: 192.0.2.1

Type: AAAA
Name: mail (or your mailserver hostname without domain)
Value: 2001:db8::1
```

Replace the IP addresses with your mailserver's actual IPv4 and IPv6 addresses. If your mailserver only has IPv4, you can omit the AAAA record, though IPv6 is recommended for modern email infrastructure.

### A/AAAA Record Example

For mailserver hostname `mail.example.com`:

```text
mail.example.com.    IN    A        192.0.2.1
mail.example.com.    IN    AAAA    2001:db8::1
```

### A/AAAA Record Verification

Verify the A and AAAA records:

```bash
dig A mail.example.com
dig AAAA mail.example.com
# or
nslookup mail.example.com
```

## SPF Record

The Sender Policy Framework (SPF) record authorizes your mailserver to send emails on behalf of your domain. SPF helps prevent email spoofing by specifying which mail servers are allowed to send emails for your domain.

### SPF Record Configuration

Create a TXT record with SPF policy:

```text
Type: TXT
Name: @ (or your domain name)
Value: v=spf1 mx a ip4:192.0.2.1 ip6:2001:db8::1 ~all
```

### SPF Mechanisms

Common SPF mechanisms used in mailserver configurations:

- `mx`: Authorizes the mail servers listed in MX records
- `a`: Authorizes the IP addresses of A records for the domain
- `ip4:192.0.2.1`: Explicitly authorizes a specific IPv4 address
- `ip6:2001:db8::1`: Explicitly authorizes a specific IPv6 address
- `include:example.com`: Includes SPF policy from another domain
- `~all`: Soft fail for all other sources (recommended during testing)
- `-all`: Hard fail for all other sources (recommended for production)

### SPF Record Example

For domain `example.com` with mailserver at `mail.example.com`:

```text
example.com.    IN    TXT    "v=spf1 mx a ip4:192.0.2.1 ~all"
```

### SPF Record Verification

Verify the SPF record:

```bash
dig TXT example.com
# or use SPF validation tools
```

SPF records must be published as TXT records. Some DNS providers may also support the deprecated SPF record type, but TXT is the standard.

## DKIM Record

DomainKeys Identified Mail (DKIM) records publish the public key used to verify email signatures. DKIM signing is configured through the management interface, which generates the DNS TXT record that must be published.

### DKIM Record Configuration

DKIM records are generated through the management interface:

1. Access the management interface
2. Navigate to **DKIM** in the menu bar
3. Select the domain for DKIM configuration
4. Generate the DKIM key pair
5. Copy the provided DNS TXT record
6. Add the record to your domain's DNS

### Record Format

DKIM records use a specific subdomain format:

```text
Type: TXT
Name: default._domainkey (or selector._domainkey)
Value: v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...
```

The record name includes a selector (typically `default`) and the `_domainkey` subdomain. The value contains the DKIM version, key type, and public key.

### DKIM Record Example

For domain `example.com` with selector `default`:

```text
default._domainkey.example.com.    IN    TXT    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."
```

### DKIM Record Verification

After publishing the DKIM record, verify it through the management interface. The interface checks DNS propagation and validates the record format. You can also verify manually:

```bash
dig TXT default._domainkey.example.com
```

See [DKIM Signing](dkim-signing.md) for detailed DKIM configuration instructions.

## DMARC Record

Domain-based Message Authentication, Reporting & Conformance (DMARC) records define email authentication policy and enable reporting. DMARC works in conjunction with SPF and DKIM to provide comprehensive email authentication.

### DMARC Record Configuration

Create a TXT record with DMARC policy:

```text
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:dmarc@example.com
```

### DMARC Policy Options

Common DMARC policy settings:

- `p=none`: Monitor mode - no action taken, useful for initial deployment
- `p=quarantine`: Quarantine emails that fail authentication
- `p=reject`: Reject emails that fail authentication (recommended for production)

### DMARC Tags

- `v=DMARC1`: DMARC version (required)
- `p=`: Policy for emails that fail authentication (none, quarantine, reject)
- `rua=mailto:dmarc@example.com`: Email address for aggregate reports
- `ruf=mailto:dmarc@example.com`: Email address for forensic reports
- `pct=100`: Percentage of emails to apply policy to (default: 100)
- `aspf=r`: SPF alignment mode (relaxed or strict)
- `adkim=r`: DKIM alignment mode (relaxed or strict)
- `fo=0`: Failure reporting options

### Example Policies

**Monitoring mode** (recommended for initial deployment):

```text
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=none; rua=mailto:dmarc@example.com"
```

**Quarantine mode** (after monitoring period):

```text
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com; pct=100"
```

**Reject mode** (production, after validation):

```text
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=reject; rua=mailto:dmarc@example.com; aspf=r; adkim=r"
```

### DMARC Record Verification

Verify the DMARC record:

```bash
dig TXT _dmarc.example.com
```

## DNS Record Summary

For a complete mailserver setup, configure the following DNS records:

| Record Type | Name                 | Value                       | Purpose                            |
| ----------- | -------------------- | --------------------------- | ---------------------------------- |
| MX          | `@`                  | `10 mail.example.com`       | Direct incoming emails             |
| A           | `mail`               | `192.0.2.1`                 | Resolve mailserver hostname (IPv4) |
| AAAA        | `mail`               | `2001:db8::1`               | Resolve mailserver hostname (IPv6) |
| TXT (SPF)   | `@`                  | `v=spf1 mx a ~all`          | Authorize sending servers          |
| TXT (DKIM)  | `default._domainkey` | `v=DKIM1; k=rsa; p=...`     | Email signature verification       |
| TXT (DMARC) | `_dmarc`             | `v=DMARC1; p=none; rua=...` | Authentication policy              |

## Troubleshooting

### Common Issues

**Emails not being received:**

- Verify MX record points to correct hostname
- Ensure A/AAAA records resolve the mailserver hostname
- Check firewall rules allow connections on port 25

**Emails marked as spam:**

- Verify SPF record is correctly configured
- Ensure DKIM record is published and verified
- Check DMARC policy is not too restrictive during initial setup
- Review DMARC reports for authentication failures

**DKIM verification failures:**

- Verify DKIM DNS record is published correctly
- Check DNS propagation is complete
- Ensure the selector matches between DNS and mailserver configuration
- Verify the public key in DNS matches the private key in mailserver

**SPF failures:**

- Verify all sending IP addresses are included in SPF record
- Check for syntax errors in SPF record
- Ensure SPF record is published as TXT record type
- Review SPF mechanisms (mx, a, ip4, ip6) are appropriate for your setup
