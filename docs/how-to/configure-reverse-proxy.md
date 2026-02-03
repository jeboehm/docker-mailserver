# How to Configure a Reverse Proxy (Traefik)

To run docker-mailserver behind a reverse proxy (e.g. Traefik) and preserve client IPs, enable PROXY protocol and point internal addresses at the proxy.

## Steps

### 1. Enable PROXY protocol

In `.env`:

```bash
MDA_UPSTREAM_PROXY=true
MTA_UPSTREAM_PROXY=true
```

`MDA_UPSTREAM_PROXY` applies to IMAP, IMAPS, POP3, POP3S. `MTA_UPSTREAM_PROXY` applies to SMTP and submission (587).

### 2. Set trusted proxies (if needed)

If the web interface is behind a proxy, set trusted proxy IPs:

```bash
TRUSTED_PROXIES=10.0.0.0/8
```

Use your proxy’s CIDR range(s).

### 3. Point internal addresses at the proxy

When traffic goes through the proxy, configure internal service addresses to point at the proxy’s internal host/ports, not directly at MTA/MDA. Example for a Traefik internal service:

```bash
MDA_IMAP_ADDRESS=traefik-internal:33143
MDA_IMAPS_ADDRESS=traefik-internal:33993
MDA_POP3_ADDRESS=traefik-internal:33110
MDA_POP3S_ADDRESS=traefik-internal:33995
MTA_SMTP_ADDRESS=traefik-internal:3325
MTA_SMTP_SUBMISSION_ADDRESS=traefik-internal:33587
```

Adjust host and port names to match your Traefik configuration.

### 4. Configure Traefik (Kubernetes)

To use the provided Traefik ingress with Kustomize, add:

```yaml
resources:
  - deploy/kustomize/ingress/traefik
```

This adds IngressRoutes for SMTP (25), submission (587), IMAP (143), IMAPS (993), POP3 (110), POP3S (995). Configure entry points and PROXY protocol (v2) on the Traefik side to match.

## Verification

- Check Traefik logs and IngressRoutes.
- Test connectivity to SMTP, submission, IMAP, and POP3 on the proxy’s public ports.

For variable details, see [Environment variables reference](../reference/environment-variables.md) (Proxy Protocol and Service Addresses). For a Docker Compose example, see [Traefik reverse proxy example](https://github.com/jeboehm/docker-mailserver/tree/main/docs/example-configs/compose/traefik-reverse-proxy).
