# About DNS and Email Delivery

DNS records tell the rest of the internet how to reach your mailserver and whether to trust mail from it. Correct DNS is required for reliable delivery and for authentication (SPF, DKIM, DMARC).

## Why MX matters

The MX (Mail Exchange) record says which host accepts mail for your domain. When someone sends to `user@example.com`, the sender’s server looks up MX for `example.com`. Without a correct MX record pointing to your mailserver, other servers will not deliver mail to you or may deliver to the wrong host.

## Why SPF matters

SPF (Sender Policy Framework) lists which servers are allowed to send mail for your domain. Receiving servers check SPF to reduce spoofing: if mail claims to be from your domain but comes from an IP not in your SPF record, it can be marked as suspicious or rejected. Without SPF, your domain is easier to spoof and more likely to be treated as untrusted.

## Why DKIM matters

DKIM (DomainKeys Identified Mail) lets receiving servers verify that mail was signed by a server that holds the private key for your domain. The public key is in DNS. Signing all outgoing mail and publishing the key improves deliverability and helps receivers distinguish legitimate mail from forgeries. Many providers and filters use DKIM as a signal for reputation and filtering.

## Why DMARC matters

DMARC (Domain-based Message Authentication, Reporting and Conformance) tells receivers what to do with mail that fails SPF or DKIM (quarantine, reject) and where to send reports. It ties SPF and DKIM together and gives you visibility into authentication failures. Starting with a monitoring policy (`p=none`) and then tightening to quarantine or reject is a common approach.

## How they fit together

MX gets mail to your server. SPF and DKIM help other servers trust mail from your server and reject or down-rank spoofed mail. DMARC defines policy and reporting so you can improve authentication over time. For record types and formats, see [DNS records reference](../reference/dns-records.md). For step-by-step configuration, see [How to configure DNS for your domain](../how-to/configure-dns.md).
