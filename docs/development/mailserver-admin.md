# Development Guide for mailserver-admin

mailserver-admin is developed in a separate repository, [jeboehm/mailserver-admin](https://github.com/jeboehm/mailserver-admin). It is a PHP application built with Symfony and EasyAdmin, backed by PostgreSQL or MySQL and Redis. The `AGENTS.md` in that repository is the authoritative guide to its layout, conventions and commands; this page only shows how to start.

The development environment is Docker Compose, and every PHP command runs in the `php` container:

```bash
docker compose up -d
docker compose exec php composer run csfix
docker compose exec php composer run phpstan
docker compose exec php composer run test
```

`docker compose up -d` serves the application on `http://localhost:8000` with PostgreSQL. To use MySQL instead, add `-f compose.yaml -f compose.mysql.yaml`. `docker compose down -v` resets all data.

To use a mailserver-admin release in docker-mailserver, set `ADMIN_VER` in `target/web/Dockerfile`.

## Additional resources

- [Symfony documentation](https://symfony.com/doc/current/index.html)
- [EasyAdmin documentation](https://symfony.com/bundles/EasyAdminBundle/current/index.html)
