# How to Use the iOS / macOS Mail Profile

The iOS / macOS Profile feature in mailserver-admin generates configuration profiles for Apple Mail. These profiles set up IMAP and SMTP so users do not have to enter server details manually.

Use the feature from the management interface to generate and download the profile for the user’s device. For Apple’s documentation on configuring Mail:

- [macOS](https://support.apple.com/en-us/guide/mac-help/mh35561/mac)
- [iOS](https://support.apple.com/en-us/102400)

**Note:** Profile generation uses the same TLS certificate the mailserver presents to clients, so the `web` container needs it at `/opt/admin/tls`. Compose and Kustomize mount it by default; if you mount your own certificates, see [How to configure TLS certificates](configure-tls.md) and the [volume mounts](../reference/service-architecture.md#volume-mounts-by-service).
