# Development Guide for mailserver-admin

This document describes the development setup and workflow for the ```mailserver-admin``` project.
The project is located in a separate repository: https://github.com/jeboehm/mailserver-admin/

## Technical Stack

- PHP
- Symfony
- EasyAdmin
- MySQL
- Redis
- PHPUnit

## Development Environment Setup

The project uses [devenv](https://devenv.sh/) to provide a reproducible development environment with all necessary services and dependencies.

### Prerequisites

- [Nix](https://nixos.org/download.html) installed on your system
- [devenv](https://devenv.sh/getting-started/) installed

### Initial Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd mailserver-admin
   ```

2. Start the development environment:
   ```bash
   devenv up
   ```

   This command will:
   - Set up PHP 8.4 with required extensions (Redis, PDO MySQL, Xdebug)
   - Start MySQL database server
   - Start Redis server
   - Start Caddy web server on port 8000
   - Configure PHP-FPM pool for the web server
   - Set up environment variables for database and Redis connections

3. Install dependencies:
   ```bash
   composer install
   ```

### Starting the Web Server

**Important**: You must run `devenv up` to start the web server. This command starts all required services including:

- **Caddy web server** on `http://localhost:8000`
- **MySQL database** (accessible at `127.0.0.1`)
- **Redis server** (accessible at `localhost:6379`)

The web server is configured to serve files from the `public/` directory and uses PHP-FPM for PHP execution.

### Development Services

The devenv configuration provides:

- **PHP 8.4** with extensions:
  - Redis
  - PDO MySQL
  - Xdebug (configured for debugging on port 9003)

- **MySQL** database:
  - Database name: `app`
  - User: `root`
  - Connection string: `mysql://root@127.0.0.1/app?version=mariadb-10.11.5`

- **Redis** server:
  - Host: `localhost`
  - Port: `6379`
  - Connection string: `redis://localhost:6379/0`

- **Caddy** web server:
  - Port: `8000`
  - Document root: `public/`
  - PHP-FPM integration enabled

### Environment Variables

The following environment variables are automatically set by devenv:

- `DATABASE_URL`: MySQL connection string
- `REDIS_DSN`: Redis connection string
- `CORS_ALLOW_ORIGIN`: CORS configuration for localhost

## Development Commands

The project includes several composer scripts for development tasks:

### Code Style Fixing

Fix code style issues using PHP CS Fixer:

```bash
composer run csfix
```

This command runs PHP CS Fixer with the configuration defined in `.php-cs-fixer.dist.php`. It applies PSR-2, Symfony, and PHP 8.0 migration rules to files in:
- `bin/`
- `public/`
- `tests/`
- `src/`
- `migrations/`

### Static Analysis

Run PHPStan to perform static analysis:

```bash
composer run phpstan
```

PHPStan is configured to analyze code at level 6 (as defined in `phpstan.dist.neon`) and checks:
- `bin/`
- `config/`
- `public/`
- `src/`
- `tests/`

### Running Tests

Execute the test suite:

```bash
composer run test
```

This runs PHPUnit with the configuration from `phpunit.dist.xml`. The test suite includes:
- Unit tests in `tests/Unit/`
- Integration tests in `tests/Integration/`

Tests run in the `test` environment and use the database configured in `.env.test`.

### Test Coverage

Generate test coverage report:

```bash
composer run coverage
```

This runs PHPUnit with Xdebug coverage enabled and outputs a text-based coverage report.

### Code Refactoring

Run Rector to automatically refactor code:

```bash
composer run rector
```

Rector uses the configuration from `rector.php` to apply automated code improvements and migrations.

## Project Structure

- `src/`: Application source code
- `tests/`: Test files (Unit and Integration)
- `config/`: Symfony configuration files
- `public/`: Web server document root
- `migrations/`: Database migration files
- `templates/`: Twig templates
- `bin/`: Executable scripts (console, phpunit)

## Development Workflow

1. **Start the environment**: `devenv up`
2. **Make your changes** in the appropriate directories
3. **Fix code style**: `composer run csfix`
4. **Check static analysis**: `composer run phpstan`
5. **Run tests**: `composer run test`
6. **Commit your changes** following the project's commit message conventions

## Debugging

Xdebug is configured in the devenv setup with:
- Mode: `debug`
- Client port: `9003`
- Start with request: enabled

Configure your IDE to connect to Xdebug on port 9003 for debugging.

## Database Migrations

When making database schema changes:

1. Create a migration:
   ```bash
   php bin/console doctrine:migrations:generate
   ```

2. Edit the generated migration file in `migrations/`

3. Run migrations:
   ```bash
   php bin/console doctrine:migrations:migrate
   ```

## Additional Resources

- [Symfony Documentation](https://symfony.com/doc/current/index.html)
- [EasyAdmin Bundle Documentation](https://symfony.com/bundles/EasyAdminBundle/current/index.html)
- [devenv Documentation](https://devenv.sh/)
- [PHP CS Fixer Documentation](https://cs.symfony.com/)
- [PHPStan Documentation](https://phpstan.org/)
