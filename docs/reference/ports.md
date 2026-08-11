# Ports Reference

Services and ports exposed by docker-mailserver.

## Docker Compose

Host ports published by `docker-compose.production.yml`, with the container port they map to:

| Service                             | Host port | Container port | Path        |
| ----------------------------------- | --------- | -------------- | ----------- |
| POP3 (STARTTLS required)            | 110       | 31110          | —           |
| POP3S                               | 995       | 31995          | —           |
| IMAP (STARTTLS required)            | 143       | 31143          | —           |
| IMAPS                               | 993       | 31993          | —           |
| SMTP                                | 25        | 25             | —           |
| Mail Submission (STARTTLS required) | 587       | 587            | —           |
| Management Interface                | 81        | 8080           | `/`         |
| Webmail                             | 81        | 8080           | `/webmail/` |
| Rspamd web interface                | 81        | 8080           | `/rspamd/`  |

## Kubernetes

The Kustomize Services publish different ports than the containers listen on. Variables such as `MDA_IMAP_ADDRESS` and `WEB_HTTP_ADDRESS` are overridden in `deploy/kustomize/common/configmap.yaml` to match.

| Service | Service ports                              |
| ------- | ------------------------------------------ |
| mta     | 25, 587                                    |
| mda     | 110, 143, 993, 995, 2003, 2004, 4190, 8080 |
| web     | 80                                         |
| filter  | 11332, 11334                               |
| redis   | 6379                                       |
| unbound | 53 (TCP and UDP)                           |

## Binding and exposure

The base `docker-compose.yml` creates no host port bindings. `bin/production.sh` includes `docker-compose.production.yml`, which binds all mail and web ports to `0.0.0.0` — making them accessible from the internet. Use host firewall rules to control which source IPs can reach these ports.

The management interface, webmail, and Rspamd web interface (port 81) use plain HTTP. Terminate TLS at a reverse proxy before exposing these to a network. See [How to configure a reverse proxy](../how-to/configure-reverse-proxy.md).
