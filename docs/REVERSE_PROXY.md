# Reverse Proxy Configuration

This document describes how to configure docker-mailserver to work behind a reverse proxy, specifically using Traefik as an example. The configuration uses environment variables to enable proxy protocol support and configure trusted proxy networks.

## Overview

When deploying docker-mailserver behind a reverse proxy, you need to:

1. Configure the mail server to accept connections from the proxy
2. Enable PROXY protocol support to preserve client IP addresses
3. Set up the reverse proxy to route traffic to the appropriate mail services

## Environment Variables

The following environment variables control reverse proxy behavior:

### Proxy Protocol Support

| Variable             | Default | Description                                                |
| -------------------- | ------- | ---------------------------------------------------------- |
| `MDA_UPSTREAM_PROXY` | `false` | Enable PROXY protocol for MDA (Dovecot) IMAP/POP3 services |
| `MTA_UPSTREAM_PROXY` | `false` | Enable PROXY protocol for MTA (Postfix) SMTP services      |

### Trusted Proxy Networks

| Variable          | Default | Description                                                     |
| ----------------- | ------- | --------------------------------------------------------------- |
| `TRUSTED_PROXIES` | -       | Comma-separated list of trusted proxy IP ranges (CIDR notation) |

### Service Address Configuration

**Important**: When using a reverse proxy, you must configure the internal service addresses to point to the reverse proxy's internal service ports, not directly to the mail server services. This ensures proper traffic routing through the proxy.

| Variable                      | Description                                                |
| ----------------------------- | ---------------------------------------------------------- |
| `MDA_IMAP_ADDRESS`            | Internal IMAP service address (points to proxy)            |
| `MDA_IMAPS_ADDRESS`           | Internal IMAPS service address (points to proxy)           |
| `MDA_POP3_ADDRESS`            | Internal POP3 service address (points to proxy)            |
| `MDA_POP3S_ADDRESS`           | Internal POP3S service address (points to proxy)           |
| `MTA_SMTP_ADDRESS`            | Internal SMTP service address (points to proxy)            |
| `MTA_SMTP_SUBMISSION_ADDRESS` | Internal SMTP submission service address (points to proxy) |

The addresses should reference the reverse proxy's internal service name and the specific port configured for each mail protocol. This allows the mail server to route internal traffic through the proxy, maintaining consistent behavior and enabling proper PROXY protocol handling.

## Example Configuration

Here's a complete example configuration for use with Traefik:

```bash
# Enable PROXY protocol support
MDA_UPSTREAM_PROXY=true
MTA_UPSTREAM_PROXY=true

# Configure trusted proxy networks
TRUSTED_PROXIES=10.0.0.0/8

# Configure internal service addresses to point to Traefik's internal service
# These addresses route through the proxy, not directly to mail services
MDA_IMAP_ADDRESS=traefik-internal:33143
MDA_IMAPS_ADDRESS=traefik-internal:33993
MDA_POP3_ADDRESS=traefik-internal:33110
MDA_POP3S_ADDRESS=traefik-internal:33995
MTA_SMTP_ADDRESS=traefik-internal:3325
MTA_SMTP_SUBMISSION_ADDRESS=traefik-internal:33587
```

## Traefik Configuration

### Using Kustomize

To deploy Traefik resources with your mail server, include the Traefik ingress configuration in your Kustomize setup:

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deploy/kustomize/ingress/traefik
  # ... other resources
```

This will include the following Traefik resources:

- **MDA IngressRoutes**: Routes for IMAP (143), IMAPS (993), POP3 (110), and POP3S (995)
- **MTA IngressRoutes**: Routes for SMTP (25) and SMTP submission (587)

### Traefik Entry Points

The Traefik configuration defines the following entry points:

```yaml
ports:
  smtp:
    port: 3325
    expose:
      default: true
      internal: true
  submission:
    port: 33587
    expose:
      default: true
      internal: true
  imap:
    port: 33143
    expose:
      default: true
      internal: true
  imaps:
    port: 33993
    expose:
      default: true
      internal: true
  pop3:
    port: 33110
    expose:
      default: true
      internal: true
  pop3s:
    port: 33995
    expose:
      default: true
      internal: true
```

### IngressRoute Configuration

The IngressRoutes are configured with:

- **HostSNI matching**: `HostSNI(*)` to accept all hostnames
- **Native load balancing**: `nativeLB: true` for optimal performance
- **PROXY protocol**: Version 2 support for client IP preservation

Example IngressRoute for IMAP:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRouteTCP
metadata:
  name: ingress-imap
spec:
  entryPoints:
    - imap
  routes:
    - match: HostSNI(`*`)
      services:
        - name: mda
          port: imap
          nativeLB: true
          proxyProtocol:
            version: 2
```

## Traffic Flow

1. **Client Connection**: Client connects to Traefik on standard mail ports (25, 587, 143, 993, 110, 995)
2. **Traefik Routing**: Traefik routes traffic to internal mail services using IngressRoutes
3. **PROXY Protocol**: Traefik sends PROXY protocol headers to preserve original client IP
4. **Mail Server**: Mail server processes the connection with original client IP information

## Verification

To verify the Traefik configuration is working correctly:

```bash
# Check Traefik pod logs
kubectl logs -l app.kubernetes.io/name=traefik

# Verify IngressRoutes are created
kubectl get ingressroutetcp

# Test mail connectivity
telnet your-domain.com 25
telnet your-domain.com 587
telnet your-domain.com 143
```
