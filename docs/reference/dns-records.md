# DNS Records Reference

DNS record types and formats required for the mailserver. Configure these in your domain's DNS zone.

## Summary

| Record Type | Name                 | Purpose                            |
| ----------- | -------------------- | ---------------------------------- |
| MX          | `@`                  | Direct incoming mail               |
| A           | `mail`               | Resolve mailserver hostname (IPv4) |
| AAAA        | `mail`               | Resolve mailserver hostname (IPv6) |
| TXT (SPF)   | `@`                  | Authorize sending servers          |
| TXT (DKIM)  | `default._domainkey` | Email signature verification       |
| TXT (DMARC) | `_dmarc`             | Authentication policy              |

## MX Record

Directs incoming mail to the mailserver. Use the value of `MAILNAME`.

```text
Type: MX
Name: @ (or domain name)
Priority: 10
Value: mail.example.com
```

Example for `example.com`:

```text
example.com.    IN    MX    10    mail.example.com.
```

Lower priority values have higher precedence when multiple MX records exist.

## A and AAAA Records

Resolve the mailserver hostname to IP addresses. Required for the MX record to work.

```text
Type: A
Name: mail (or hostname without domain)
Value: 192.0.2.1

Type: AAAA
Name: mail
Value: 2001:db8::1
```

Example for `mail.example.com`:

```text
mail.example.com.    IN    A        192.0.2.1
mail.example.com.    IN    AAAA    2001:db8::1
```

## SPF Record (TXT)

Authorizes which servers may send mail for the domain. Published as a TXT record.

```text
Type: TXT
Name: @
Value: v=spf1 mx a ip4:192.0.2.1 ip6:2001:db8::1 ~all
```

Common mechanisms:

- `mx`: Authorize MX hosts
- `a`: Authorize A record(s) for the domain
- `ip4:`, `ip6:`: Authorize specific IPs
- `include:domain`: Include another domain's SPF
- `~all`: Soft fail for others (testing)
- `-all`: Hard fail for others (production)

Example:

```text
example.com.    IN    TXT    "v=spf1 mx a ip4:192.0.2.1 ~all"
```

## DKIM Record (TXT)

Publishes the public key for DKIM verification. The management interface generates the exact record; the name uses a selector and `_domainkey`.

```text
Type: TXT
Name: default._domainkey (or selector._domainkey)
Value: v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC...
```

Example for `example.com` with selector `default`:

```text
default._domainkey.example.com.    IN    TXT    "v=DKIM1; k=rsa; p=..."
```

## DMARC Record (TXT)

Defines policy for messages that fail SPF/DKIM and optional reporting.

```text
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none; rua=mailto:dmarc@example.com
```

Policy (`p=`):

- `none`: Monitor only
- `quarantine`: Quarantine failures
- `reject`: Reject failures

Common tags:

- `v=DMARC1`: Version (required)
- `p=`: Policy (none, quarantine, reject)
- `rua=mailto:...`: Aggregate report address
- `ruf=mailto:...`: Forensic report address
- `aspf=r`, `adkim=r`: Alignment (relaxed or strict)

Example monitoring policy:

```text
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=none; rua=mailto:dmarc@example.com"
```

Example reject policy:

```text
_dmarc.example.com.    IN    TXT    "v=DMARC1; p=reject; rua=mailto:dmarc@example.com; aspf=r; adkim=r"
```

## Verification

Use `dig` or `nslookup` to verify records:

```bash
dig MX example.com
dig A mail.example.com
dig TXT example.com
dig TXT default._domainkey.example.com
dig TXT _dmarc.example.com
```

For context on why these records matter, see [DNS and email delivery](../explanation/dns-and-email.md).
