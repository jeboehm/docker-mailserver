# Observability

Observability is the ability to understand a system's internal state by examining its external outputs, crucial for complex, modern software systems.

`mailserver-admin` provides observability features for monitoring the mailserver components, enabling administrators to monitor service health, message processing statistics, and operational metrics through web-based dashboards.

## Overview

The observability features integrate with the Rspamd filter service and Dovecot mail delivery agent to collect and display real-time statistics and historical trends. These dashboards provide visibility into message processing, spam filtering effectiveness, authentication patterns, and mail delivery rates.

## Rspamd Statistics

The Rspamd Statistics dashboard displays metrics from the Rspamd controller service, providing insights into spam filtering operations and message processing.

![Rspamd Statistics](../images/admin/obs_rspamd.png)

The dashboard includes:

- **Service Status**: Health check indicator showing Rspamd controller availability and response time
- **Summary Metrics**: Key performance indicators including:
  - Total messages scanned
  - Spam messages detected
  - Ham (clean) messages identified
  - Messages used for machine learning
  - Active connections to the service
- **Throughput Chart**: Time-series visualization of message processing rates per minute, showing action distributions including rejections, soft rejections, subject rewrites, header additions, greylisting, and no-action messages. Supports time aggregation for day, week, month, and year views
- **Action Distribution**: Donut chart showing the proportion of messages categorised by Rspamd actions (clean, rejected, temporarily rejected, probable spam, greylisted)
- **Configuration Details**: Displays action thresholds and top symbols used in spam scoring

## Dovecot Statistics

The Dovecot Statistics dashboard presents metrics from the Dovecot mail delivery agent via the Doveadm HTTP API, focusing on authentication and mail delivery operations.

![Dovecot Statistics](../images/admin/obs_dovecot.png)

The dashboard provides:

- **API Status**: Connection status and authentication verification for the Doveadm HTTP API, including last update timestamp
- **Summary Metrics**: Overview cards showing:
  - Authentication successes
  - Authentication failures
  - Index operations count
- **Authentication Rate Chart**: Time-series graph displaying authentication success and failure rates per minute, enabling identification of authentication patterns and potential security issues
- **Mail Deliveries Chart**: Time-series visualization of mail delivery rates per minute, showing message throughput to user mailboxes
- **Data Collection**: Charts are calculated from consecutive samples, with rates computed as deltas between measurements
