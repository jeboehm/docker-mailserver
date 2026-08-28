# Developer Guide

This document provides essential information for developers working on the `docker-mailserver` project.

## Development Commands

The following Make commands are essential for the development workflow:

### `make clean`

Cleans the development environment by:

- Stopping and removing all running containers
- Removing all Docker volumes (data-db, data-mail, data-tls, data-filter, data-redis, data-spool)
- Removing orphaned containers

Built images are not removed. Use `docker image rm` for that.

**Usage:**

```bash
make clean
```

**When to use:**

- Before starting fresh development work
- When switching between different configurations
- To free up disk space from accumulated Docker data
- To have a fresh database
- When encountering persistent issues that might be related to cached data

### `make up`

Starts all mailserver services in development mode and exposes them on local ports for testing.

Images are not rebuilt; run `make build` first when sources changed. The target does not wait for the services to become healthy.

**Usage:**

```bash
make up
```

**What it does:**

- Builds MTA, MDA, Web, Filter, SSL, and other service images
- Configures service networking and dependencies
- Makes services available for testing and development

**When to use:**

- After making code changes to any service
- When setting up a new development environment
- After running `make clean` to rebuild everything

### `make test`

Runs the complete integration test suite against the running mailserver:

- Executes fixtures to populate the database
- Executes BATS (Bash Automated Testing System) tests
- Tests all major mailserver functionality
- Validates TLS/SSL configuration
- Tests database connectivity and user management
- Verifies MTA, MDA, and web service functionality
- Tests DKIM signing and spam filtering
- Validates fetchmail and DNS resolution

**Usage:**

```bash
make test
```

`make test` can be repeated against the same stack: `test/fixtures.sh` exits early when the database is already seeded, and the tests reset the state they depend on themselves. bats writes a JUnit report to `test/report/report.xml` (git-ignored), which CI uploads as an artifact.

**Prerequisites:**

- Services must be running (run `make up` first)
- All services must be healthy and ready

**Test Coverage:**

- TLS certificate generation and validation
- Database initialization and connectivity
- Configuration file generation
- MTA (Postfix) functionality
- Web interface accessibility
- MDA (Dovecot) IMAP/POP3 services
- Docker container health checks
- Relay host configuration
- DKIM signing and verification
- Fetchmail external mail retrieval
- Unbound DNS resolution

### `make lint`

Lints all files in the project to ensure code quality and consistency:

- Checks shell scripts for syntax errors and best practices
- Validates YAML files for proper formatting
- Ensures Dockerfiles follow best practices
- Checks configuration files for syntax issues
- Validates documentation formatting

**Usage:**

```bash
make lint
```

**What it checks:**

- Shell scripts (`.sh` files) using shellcheck
- YAML files (`.yml`, `.yaml`) for syntax and formatting
- Dockerfiles for best practices and security issues
- Configuration files for proper syntax
- Documentation files for formatting consistency

**When to use:**

- Before committing changes to ensure code quality
- As part of the development workflow
- To catch syntax errors and style issues early
- To maintain consistent code formatting across the project

## Development Workflow

The typical development workflow is:

1. **Clean environment:**

   ```bash
   make clean
   ```

2. **Build and start services:**

   ```bash
   make build up
   ```

3. **Run tests:**

   ```bash
   make test
   ```

4. **Make changes to code and repeat steps 2-3 as needed**

5. **Lint your changes before committing:**
   ```bash
   make lint
   ```

## Testing Specific Changes

When making changes to a specific service (e.g., MDA, MTA, Web, Filter), you can test your changes more efficiently:

### Example: Testing MDA Service Changes

1. **Make your changes** to the MDA service (e.g., modify `target/mda/Dockerfile` or configuration files)

2. **Rebuild and restart services:**

   ```bash
   make build up
   ```

   This will rebuild the changed service and restart all services.

3. **Run a specific test** to verify your changes:
   ```bash
   ./bin/test.sh run --rm test bats 070_docker.bats
   ```
   This runs only the Docker-related tests instead of the full test suite.

### Writing integration tests

The tests in `test/bats/integration/` share `_helper.bash`, which also loads bats-support and bats-assert. A few conventions keep them independent of timing and of each other:

- A test that expects a delivery sends the mail itself with `send_mail` (swaks plus a retry when Postfix's connection rate limit answers `421`), with `$(mail_needle)` as body, and waits for it with `wait_for_mail "$(mail_needle)" "$(maildir admin@example.com)"`. The needle is unique per test and per run, so mails from earlier runs in the same Maildir do not satisfy the check.
- Never `sleep`; poll with `wait_for`, `wait_for_log` or `wait_for_mail`, which return as soon as the condition holds and fail with a message after the timeout.
- Use `exec_in_service` and `service_logs` instead of `docker exec` or `kubectl`, so the test runs on Docker Compose and Kubernetes alike.
- Tests that depend on mailbox state reset it first (`mailbox_reset quota@example.com` runs `doveadm` in the `mda` container). A subset such as `./bin/test.sh run --rm test bats -f quota 040_mta.bats` therefore runs on its own.

### Example: DKIM signing test

Rspamd signs outgoing mail only when the public key of the sender domain resolves through unbound (`check_pubkey` in `target/filter/rootfs/etc/rspamd/local.d/dkim_signing.conf`). Nothing publishes DNS records for `example.com` in the test environment, so `test/bats/integration/090_dkim.bats` publishes the record itself:

1. It derives the public key from the private key that `dkim:setup` stored in Redis (`HGET dkim_keys dkim.example.com`).
2. It adds the TXT record `dkim._domainkey.example.com` to the running unbound with `unbound-control local_data`, executed inside the unbound container (`docker exec` on Docker Compose, `kubectl exec` on Kubernetes).
3. It sends a mail through the submission service, checks the `DKIM-Signature` header of the stored message and lets Rspamd verify the signature through its `/checkv2` API.
4. It rotates the key with `dkim:setup example.com --regenerate --enable` while the published record still holds the old public key, sends another mail and checks that this one is not signed.

The record only lives in unbound's memory. It disappears when the container is recreated and is published again on the next test run; `teardown_file` republishes the rotated key so signing keeps working afterwards. Run the file on its own with:

```bash
./bin/test.sh run --rm test bats 090_dkim.bats
```

Useful commands when the test fails:

```bash
bin/test.sh logs filter | grep -iE 'dkim|public key'
docker exec docker-mailserver-unbound-1 unbound-control list_local_data
```

## Additional Development Commands

- **View logs:** `bin/test.sh logs -f [service-name]`
- **Access service shell:** `bin/test.sh exec [service-name] sh`
- **Check service status:** `bin/test.sh ps`
- **Restart specific service:** `bin/test.sh restart [service-name]`

## Troubleshooting Development Issues

- **Services won't start:** Run `make clean` then `make up`
- **Tests failing:** Ensure all services are healthy with `bin/test.sh ps`
- **Build issues:** Check Docker daemon is running and has sufficient resources
- **Port conflicts:** Ensure ports 25, 110, 143, 587, 993, 995, 81 are available

## Project Structure

The project is organized into several key directories:

- `target/` - Contains Dockerfiles and configuration for each service
- `test/` - Integration tests using BATS
- `docs/` - Documentation and example configurations
- `deploy/` - Kubernetes and Compose deployment configurations
- `bin/` - Utility scripts for development and deployment

## Branching Model

The project uses two long-lived branches:

- `main` is the released state. Every push is checked for conventional commits, and a new
  version is tagged and released automatically when they warrant one. Container images are
  published under the resulting semantic version tags plus `latest`.
- `next` collects work for future versions that must not ship yet, typically breaking
  changes. Its images are published under the `next` tag, so they can be tried out without
  affecting anyone on `latest`.

`next` is kept current automatically: every push to `main` triggers
`.github/workflows/sync-next-branch.yml`, which fast-forwards `next` while it carries no
commits of its own and merges `main` into it once it does. If that merge conflicts, the
workflow opens a pull request from `main` into `next` and fails, so the conflict is resolved
once, by hand. Base a pull request on `next` when it targets the next major version;
otherwise base it on `main`. A major version is cut by merging `next` into `main`.

## Contributing

When contributing to the project:

1. Follow the development workflow above
2. Ensure all tests pass before submitting changes
3. Update documentation as needed
4. Test your changes in both Docker Compose and Kubernetes environments
5. Follow the existing code style and patterns
