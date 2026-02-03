# How to Add Roundcube Plugins

The web image supports installing Roundcube plugins at build time via the `RC_PLUGINS` build argument.

## Steps

### 1. Set RC_PLUGINS in the web build

In `deploy/compose/web.yaml` (or your override), add or edit the build args:

```yaml
services:
  web:
    build:
      context: ../../target/web
      args:
        RC_PLUGINS: "vendor/plugin-name another-vendor/another-plugin"
```

Use a space-separated list of plugins in `vendor/plugin-name` form. Example:

```yaml
RC_PLUGINS: "johndoh/contextmenu jfcherng-roundcube/show-folder-size kolab/calendar"
```

### 2. Rebuild and start the web service

```bash
docker-compose build web
docker-compose up -d web
```

(or `bin/production.sh` if you use that). Changes to `RC_PLUGINS` require a rebuild.

## Plugin sources

Plugins are typically installed from Packagist ([roundcube-plugin](https://packagist.org/?type=roundcube-plugin)), GitHub, or other Composer-compatible sources. Ensure plugins match the Roundcube version in the image.

## Notes

- Plugin names must be `vendor/plugin-name`.
- Multiple plugins are space-separated.
- Plugins are installed during the Docker build; changing `RC_PLUGINS` means rebuilding the image.
