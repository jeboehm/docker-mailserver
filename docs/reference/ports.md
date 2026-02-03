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
