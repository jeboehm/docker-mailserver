# Roundcube Configuration

## Overview

The `docker-mailserver`'s web service includes Roundcube webmail interface along with the admin interface. The Dockerfile for the web service supports custom Roundcube plugin installation through build arguments.

## Plugin Installation

### Build Argument: RC_PLUGINS

The web service Dockerfile accepts the `RC_PLUGINS` build argument, which allows you to specify Roundcube plugins that should be installed during the image build process.

**Format**: Space-separated list of plugin names in the format `vendor/plugin-name`

**Example plugins**:

- `johndoh/contextmenu` - Enhanced context menu functionality
- `jfcherng-roundcube/show-folder-size` - Display folder sizes
- `kolab/calendar` - Calendar integration

### Configuration in web.yaml

The `RC_PLUGINS` argument is configured in the `deploy/compose/web.yaml` file:

```yaml
services:
  web:
    image: jeboehm/mailserver-web:latest
    build:
      context: ../../target/web
      args:
        RC_PLUGINS: "johndoh/contextmenu jfcherng-roundcube/show-folder-size"
```

### Adding Custom Plugins

To add or modify Roundcube plugins:

1. **Edit the web.yaml file**:

   ```yaml
   services:
     web:
       build:
         context: ../../target/web
         args:
           RC_PLUGINS: "your-plugin/name another-plugin/name"
   ```

2. **Rebuild the web service**:

   ```bash
   docker-compose build web
   ```

3. **Restart the service**:
   ```bash
   docker-compose up -d web
   ```

### Example: Adding Calendar Plugin

```yaml
# In deploy/compose/web.yaml
services:
  web:
    build:
      context: ../../target/web
      args:
        RC_PLUGINS: "johndoh/contextmenu jfcherng-roundcube/show-folder-size kolab/calendar"
```

Then rebuild:

```bash
docker-compose build web && docker-compose up -d web
```

## Plugin Sources

Plugins are typically installed from:

- [Packagist.org](https://packagist.org/?type=roundcube-plugin) - Official Roundcube plugin repository
- GitHub repositories
- Custom plugin sources

## Notes

- Plugin names must follow the `vendor/plugin-name` format
- Multiple plugins are space-separated
- Plugins are installed during the Docker build process
- Changes to `RC_PLUGINS` require rebuilding the image
- Ensure plugins are compatible with the Roundcube version used in the image
