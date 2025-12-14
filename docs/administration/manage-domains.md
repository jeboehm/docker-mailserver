# Manage Domains

Domain management allows administrators to configure mail domains for the mailserver. Each domain represents a distinct email namespace that can host multiple users and aliases.

## Overview

Domains define the email addresses that your mailserver can receive and send emails for. All email addresses must belong to a configured domain before users can be created or aliases can be defined.

## Access Control

Domain management is restricted to users with **Admin** role. Domain administrators and regular users cannot add, edit, or delete domains.

## Domain Operations

### Domain List

The domain list shows all configured domains in the system:

![Domain List](../images/admin/domain_list.png)

### Adding a Domain

1. Access the management interface
2. Navigate to **Domain** in the menu bar
3. Click **Add Domain**
4. Enter the domain name (e.g., `example.com`)
5. Save the domain

The domain must be a valid domain name format. Once added, the domain is immediately available for user and alias configuration.

### Editing a Domain

It would be a destructive action to change the domain name. If you need to change the domain name, you should delete the domain and create a new one with the new name.

### Deleting a Domain

1. Navigate to **Domain** in the menu bar
2. Select the domain to delete
3. Confirm the deletion

**Warning**: Deleting a domain removes all associated users, aliases, and DKIM configurations. This action cannot be undone. Ensure all data is backed up before deletion.
