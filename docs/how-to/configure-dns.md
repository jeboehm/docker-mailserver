# How to Configure DNS for Your Domain

To receive and send mail reliably, configure DNS records for your domain. This guide gives practical steps; for record formats and options, see [DNS records reference](../reference/dns-records.md).

## Steps

### 1. Add MX record

Create an MX record pointing to your mailserver hostname (the value of `MAILNAME`, e.g. `mail.example.com`). Use priority 10 (or another value; lower = higher priority if you have multiple MX records).

### 2. Add A and AAAA records

Create A (and optionally AAAA) records for the mailserver hostname so it resolves to your server’s IP(s).

### 3. Add SPF record

Add a TXT record at the domain root with your SPF policy, e.g. `v=spf1 mx a ~all`. Adjust mechanisms (e.g. `ip4:`, `ip6:`) to match your sending IPs. Use `~all` for testing and `-all` for production once stable.

### 4. Add DKIM record

Configure DKIM in the management interface (see [How to configure DKIM signing](configure-dkim.md)). The interface shows the TXT record to add; publish it at the indicated name (e.g. `default._domainkey.example.com`).

### 5. Add DMARC record (recommended)

Add a TXT record at `_dmarc` with a DMARC policy. Start with `p=none` and `rua=mailto:...` for monitoring; move to `p=quarantine` or `p=reject` after you are satisfied with authentication.

## Verification

- Use the [DNS Validation Wizard](validate-dns.md) in the management interface.
- Use `dig` or `nslookup` to check MX, A, AAAA, and TXT records.

DNS changes can take from minutes up to 48 hours to propagate. If validation fails right after adding records, wait for propagation and check again.

For record formats and examples, see [DNS records reference](../reference/dns-records.md). For context on why these records matter, see [DNS and email delivery](../explanation/dns-and-email.md).
