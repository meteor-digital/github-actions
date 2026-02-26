# Setup Environment Action

Sets up PHP, Node.js, and installs dependencies with intelligent caching.

## Usage

```yaml
- name: Setup Environment
  uses: ./actions/setup-environment
  with:
    config_file: '.github/pipeline-config.yml'     # Optional, defaults to .github/pipeline-config.yml
    composer_with_dev: 'yes'                       # Optional, defaults to 'yes'
    composer_auth: '${{ secrets.COMPOSER_AUTH }}'  # Optional, for private repositories
    node_skip_setup: 'false'                       # Optional, defaults to 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `composer_with_dev` | Install dev dependencies (yes/no) | No | `yes` |
| `composer_auth` | Composer authentication JSON | No | `{}` |
| `node_skip_setup` | Whether to skip Node.js setup | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `php_version` | PHP version that was configured |
| `node_version` | Node.js version that was configured |
| `project_type` | Detected project type (shopware, laravel, symfony) |
| `cache_hit` | Whether dependencies were restored from cache |

## Configuration

Reads from `.github/pipeline-config.yml`:

```yaml
runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache, redis, mysql"
```

## How It Works

1. Auto-detects project type (Shopware, Laravel, Symfony)
2. Sets up PHP with configured version and extensions
3. Sets up Node.js (unless skipped)
4. Restores dependencies from cache (if available)
5. Installs Composer and NPM dependencies (on cache miss)
6. Saves cache for future runs
7. Validates framework-specific requirements

## Related Actions

- **`detect-project-type`**: Auto-detects framework type
- **`parse-pipeline-config`**: Reads runtime configuration
- **`composer-setup`**: Handles Composer dependency installation
- **`build-project`**: Uses this action to prepare environment before building
