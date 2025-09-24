# Developer Guide

This document provides essential information for developers working on the `docker-mailserver` project.

## Development Commands

The following Make commands are essential for the development workflow:

### `make clean`

Cleans the development environment by:

- Stopping and removing all running containers
- Removing all Docker volumes (data-db, data-mail, data-tls, data-filter, data-redis)
- Removing all built Docker images
- Cleaning up any temporary files

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

Builds and starts all mailserver services in development mode:

- Builds all Docker images from source
- Waits for services to be ready
- Exposes services on local ports for testing

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
   make up
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
   make up
   ```

   This will rebuild the changed service and restart all services.

3. **Run a specific test** to verify your changes:
   ```bash
   ./bin/test.sh bats 070_docker.bats
   ```
   This runs only the Docker-related tests instead of the full test suite.

## Additional Development Commands

- **View logs:** `bin/test.sh logs -f [service-name]`
- **Access service shell:** `bin/test.sh exec [service-name] sh`
- **Check service status:** `bin/test.sh ps`
- **Restart specific service:** `bin/test.sh restart [service-name]`

## Troubleshooting Development Issues

- **Services won't start:** Run `make clean` then `make up`
- **Tests failing:** Ensure all services are healthy with `bin/test.sh ps`
- **Build issues:** Check Docker daemon is running and has sufficient resources
- **Port conflicts:** Ensure ports 25, 143, 587, 993, 995, 80, 81 are available

## Project Structure

The project is organized into several key directories:

- `target/` - Contains Dockerfiles and configuration for each service
- `test/` - Integration tests using BATS
- `docs/` - Documentation and example configurations
- `deploy/` - Kubernetes and Compose deployment configurations
- `bin/` - Utility scripts for development and deployment

## Contributing

When contributing to the project:

1. Follow the development workflow above
2. Ensure all tests pass before submitting changes
3. Update documentation as needed
4. Test your changes in both Docker Compose and Kubernetes environments
5. Follow the existing code style and patterns
