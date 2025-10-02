## Preserving the real client IP for MTA and MDA (Kubernetes)

This document explains why Mail Transfer Agent (MTA, e.g., SMTP) and Mail Delivery Agent (MDA, e.g., IMAP/POP/Submission/Webmail API) components must receive the real client source IP, and how to achieve this on Kubernetes. It also covers configuring `TRUSTED_PROXIES` when operating behind reverse proxies such as Traefik.

### Why the real client IP matters

- **Rate limiting and abuse controls**: MTAs commonly throttle by client IP to deter brute-force logins, SMTP auth guessing, or spam bursts. If the proxy IP is seen instead, a single misbehaving user can poison limits for all users behind the proxy, or evade limits entirely.
- **Access control and allowlists**: IP-based allow/deny rules (e.g., submission from office IP ranges) require correct client IP visibility.
- **Logging, audit, and incident response**: Mail logs, DMARC/ARC forensics, and SIEM pipelines rely on accurate source IPs. Seeing only the proxy IP hinders investigations.
- **Reputation and greylisting**: Some filters and reputation systems correlate behavior with source IP; proxy IP masking breaks heuristics and increases false positives/negatives.
- **Geo/IP policy**: If you enforce geo-based rules or present CAPTCHAs only for certain regions, you need accurate client IPs.

### Approaches on Kubernetes

There are two mainstream ways to deliver the real client IP through a proxy/load balancer:

1) **TCP-level PROXY protocol (v1/v2)**
   - Suitable for raw TCP services such as SMTP (25/465), Submission (587), IMAP (143/993), POP (110/995).
   - The front proxy (e.g., Traefik, NGINX, HAProxy, cloud LB) terminates the connection and prepends a small header that conveys the original client IP and port.
   - The backend service must explicitly support and be configured to expect the PROXY protocol on those listener ports.

2) **HTTP-level forwarded headers (X-Forwarded-For / Forwarded)**
   - Suitable only for HTTP(S) workloads (e.g., webmail UI/API) and SMTP over HTTP gateways if any.
   - The proxy adds `X-Forwarded-For` (or standardized `Forwarded`) headers with the real client IP. The application must trust only configured proxy IPs and use the header to determine the client IP.

This project supports configuring trusted proxies via the `TRUSTED_PROXIES` environment variable. Ensure this is set to the IP/CIDR of your ingress/proxy components (node-local LB ranges, Traefik service ClusterIPs, or cloud LB addresses).

### Traefik examples (as front proxy)

Traefik can sit in front of both MTA and MDA services and forward the real client IP using either the PROXY protocol (for TCP) or HTTP forwarded headers (for web). Below are sketches for Kubernetes IngressRoute resources. Adjust hostnames, ports, and namespaces to your deployment.

#### TCP with PROXY protocol (SMTP/IMAP/POP/Submission)

Enable PROXY protocol on Traefik entrypoints and on the backend listeners.

1) Traefik static configuration (Helm values excerpt):

```yaml
traefik:
  additionalArguments:
    - "--entrypoints.smtp.address=:25/tcp"
    - "--entrypoints.submission.address=:587/tcp"
    - "--entrypoints.smtps.address=:465/tcp"
    - "--entrypoints.imap.address=:143/tcp"
    - "--entrypoints.imaps.address=:993/tcp"
    - "--entrypoints.pop3.address=:110/tcp"
    - "--entrypoints.pop3s.address=:995/tcp"
    - "--entrypoints.smtp.proxyprotocol"
    - "--entrypoints.submission.proxyprotocol"
    - "--entrypoints.smtps.proxyprotocol"
    - "--entrypoints.imap.proxyprotocol"
    - "--entrypoints.imaps.proxyprotocol"
    - "--entrypoints.pop3.proxyprotocol"
    - "--entrypoints.pop3s.proxyprotocol"
```

2) Traefik TCPRoute/IngressRouteTCP:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRouteTCP
metadata:
  name: smtp
  namespace: mail
spec:
  entryPoints:
    - smtp
  routes:
    - services:
        - name: mta
          port: 25
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRouteTCP
metadata:
  name: submission
  namespace: mail
spec:
  entryPoints:
    - submission
  routes:
    - services:
        - name: mta
          port: 587
```

3) Backend listeners: enable PROXY protocol support on the MTA/MDA containers for the respective ports. Refer to your MTA/MDA configuration to accept HAProxy PROXY protocol on those sockets.

4) Application trust: set `TRUSTED_PROXIES` to the IP/CIDR ranges of Traefik and any cloud load balancer addresses.

#### HTTP with forwarded headers (Webmail/API)

For HTTP(S) endpoints fronted by Traefik `IngressRoute`, Traefik automatically sets `X-Forwarded-For` and related headers. Ensure the application trusts only the proxy IPs:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: webmail
  namespace: mail
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`mail.example.com`)
      kind: Rule
      services:
        - name: web
          port: 8080
```

Set `TRUSTED_PROXIES` accordingly so the application uses `X-Forwarded-For` safely.

### Setting TRUSTED_PROXIES

`TRUSTED_PROXIES` accepts one or more CIDRs or IPs that are allowed to supply the real client address via PROXY protocol or forwarded headers.

Examples:

```yaml
env:
  - name: TRUSTED_PROXIES
    value: "10.42.0.0/16,172.16.0.0/12,192.168.0.0/16"
```

If you use a cloud load balancer in front of Traefik, include its source ranges as well as Traefik Service ClusterIP or node CIDR ranges, depending on where the connection originates from.

See `docs/example-configs/kustomize/external-db-and-https-ingress/config.yaml` for a concrete example.

### Verification

- Connect from a known IP and verify server logs record the correct client IP.
- For TCP services: use `openssl s_client -starttls smtp -connect mail.example.com:587` and confirm logs show your real IP.
- For HTTP services: curl with `-v` and inspect application access logs for the client IP.
- Temporarily restrict an allowlist to your IP and confirm access works only from that IP.

### Security hardening tips

- Keep `TRUSTED_PROXIES` as narrow as possible; never include `0.0.0.0/0`.
- Enable PROXY protocol only on entrypoints really used for TCP mail protocols.
- Ensure backends expecting PROXY protocol do not accept plain connections on those ports from untrusted networks.
- Prefer TLS for submission and IMAP/POP (465/587/993/995) and enforce modern ciphers.
- Monitor for anomalies where many users appear from a single proxy IP—often a misconfiguration of trust lists.

