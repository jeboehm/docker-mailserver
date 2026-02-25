# Ports Reference

Services and ports exposed by docker-mailserver.

| Service                             | Address                      |
| ----------------------------------- | ---------------------------- |
| POP3 (STARTTLS required)            | 127.0.0.1:110                |
| POP3S                               | 127.0.0.1:995                |
| IMAP (STARTTLS required)            | 127.0.0.1:143                |
| IMAPS                               | 127.0.0.1:993                |
| SMTP                                | 127.0.0.1:25                 |
| Mail Submission (STARTTLS required) | 127.0.0.1:587                |
| Management Interface                | http://127.0.0.1:81/manager/ |
| Webmail                             | http://127.0.0.1:81/webmail/ |
| Rspamd web interface                | http://127.0.0.1:81/rspamd/  |

## Binding and exposure

The base `docker-compose.yml` creates no host port bindings. `bin/production.sh` includes `docker-compose.production.yml`, which binds all mail and web ports to `0.0.0.0` — making them accessible from the internet. Use host firewall rules to control which source IPs can reach these ports.

The management interface, webmail, and Rspamd web interface (port 81) use plain HTTP. Terminate TLS at a reverse proxy before exposing these to a network. See [How to configure a reverse proxy](../how-to/configure-reverse-proxy.md).
