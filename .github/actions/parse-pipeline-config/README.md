# Parse Pipeline Configuration Action

This action parses unified CI/CD pipeline configuration from a YAML file, supporting both CI and deployment configuration parsing from a single source.

## Features

- **Unified Configuration**: Parse both CI and deployment settings from one file
- **Framework Defaults**: Automatically applies framework-specific defaults for Shopware, Laravel, and Symfony
- **Flexible Parsing**: Can parse CI-only, deployment-only, or both configurations
- **Validation**: Validates configuration syntax and required fields
- **Fallback Support**: Works with or without `yq` tool

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `environment` | Target environment (required for deployment parsing) | No | - |
| `project_type` | Project type (shopware, laravel, symfony) | No | - |


## Outputs

### CI Configuration Outputs

| Output | Description |
|--------|-------------|
| `project_name` | Project name from configuration |
| `php_version` | PHP version from configuration |
| `node_version` | Node.js version from configuration |
| `php_extensions` | PHP extensions from configuration |
| `build_commands` | Build commands from configuration |
| `exclude_patterns` | File exclusion patterns from configuration |
| `retention_days` | Artifact retention days from configuration |
| `notification_webhook` | Notification webhook URL |

### Quality Configuration Outputs

| Output | Description |
|--------|-------------|
| `enabled_tools` | Enabled quality tools from configuration |
| `php_cs_fixer_bin` | PHP-CS-Fixer binary path |
| `psalm_bin` | Psalm binary path |
| `phpstan_bin` | PHPStan binary path |
| `rector_bin` | Rector binary path |
| `phpunit_bin` | PHPUnit binary path |
| `phpunuhi_bin` | PHPUnuhi binary path |

### Deployment Configuration Outputs

| Output | Description |
|--------|-------------|
| `host` | Deployment host |
| `path` | Deployment path |
| `provider` | Hosting provider |
| `ssh_user` | SSH username for deployment |
| `ssh_port` | SSH port |
| `php_service` | PHP service name |
| `maintenance_mode` | Enable maintenance mode |
| `keep_releases` | Number of releases to keep |
| `messenger_worker_id` | Messenger worker ID |
| `shared_folders` | Shared folders list |
| `pre_deploy_commands` | Pre-deployment commands |
| `post_deploy_commands` | Post-deployment commands |
| `migration_command` | Database migration command |
| `maintenance_enable_cmd` | Maintenance enable command |
| `maintenance_disable_cmd` | Maintenance disable command |

## Usage

```yaml
- name: Read CI configuration
  id: config
  uses: meteor-digital/github-actions/.github/actions/parse-pipeline-config@main
  with:
    config_file: '.github/pipeline-config.yml'

- name: Use configuration
  run: |
    echo "Project: ${{ steps.config.outputs.project_name }}"
    echo "PHP Version: ${{ steps.config.outputs.php_version }}"
```

## Configuration File Format

The action expects a unified YAML configuration file with the following structure:

```yaml
project:
  name: "my-project"

runtime:
  php_version: "8.1"  # Required
  node_version: "18"  # Optional, defaults to 18
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache"  # Optional

quality_checks:
  enabled_tools:
    - "php-cs-fixer"
    - "psalm"
    - "phpstan"
    - "rector"
    - "phpunit"
    - "composer-validate"
  tool_binaries:  # Optional overrides
    php-cs-fixer: "./vendor/bin/php-cs-fixer"

build:
  build_commands:
    - "npm run build"
    - "composer install --no-dev"
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
  artifacts:
    retention_days: 1

notifications:
  notification_webhook: "https://hooks.example.com/webhook"

# Deployment configuration (per environment)
environments:
  test:
    host: "test.example.com"
    path: "/var/www/test"
    messenger_worker_id: "1"  # Optional, Shopware/Symfony
  prod:
    host: "prod.example.com"
    path: "/var/www/prod"

hosting:
  provider: "level27"  # level27, byte, hipex, hostedpower, forge, generic
  ssh_user: "deploy"
  ssh_port: 22
  php_service: "php8.1-fpm"

# Optional: Override framework defaults
deployment:
  shared_folders:
    - "custom/shared/folder"
  commands:
    pre_deploy:
      - "custom-command"
    post_deploy:
      - "custom-command"
  cleanup:
    keep_releases: 3
```

## Framework Defaults

| Setting | Shopware | Laravel | Symfony |
|---------|----------|---------|---------|
| **Shared Folders** | `files`, `public/media`, `config/jwt`, `var/log` | `storage`, `bootstrap/cache` | `var`, `public/uploads` |
| **Pre-deploy** | `bin/console cache:warmup` | _(none)_ | `bin/console cache:warmup` |
| **Post-deploy** | `bin/console theme:dump`<br/>`bin/console theme:compile`<br/>`bin/console asset:install` | `php artisan config:cache`<br/>`php artisan route:cache`<br/>`php artisan view:cache` | `bin/console doctrine:migrations:migrate` |
| **Migration** | `bin/console database:migrate --all` | `php artisan migrate --force` | `bin/console doctrine:migrations:migrate` |
| **Maintenance Enable** | `bin/console sales-channel:maintenance:enable --all` | `php artisan down` | `touch maintenance.html` |
| **Maintenance Disable** | `bin/console sales-channel:maintenance:disable --all` | `php artisan up` | `rm -f maintenance.html` |

## Configuration Validation

The action performs comprehensive validation:

- **File existence**: Ensures the configuration file exists
- **YAML syntax**: Validates YAML syntax using `yq`
- **Required fields**: Validates that required fields like `runtime.php_version` are present
- **Format validation**: Validates PHP version format (X.Y), Node version (integer), retention days (integer)
- **Environment validation**: Validates environment names contain only letters, numbers, and hyphens
- **Deployment validation**: When parsing deployment config, validates required fields like host, path, provider, and ssh_user

## Quality Tools Integration

**Default tools** (enabled if not specified):
- `php-cs-fixer`, `psalm`, `phpstan`, `rector`, `phpunit`, `composer-validate`

**Optional tools** (add to `enabled_tools` to use):
- `phpunuhi` - Translation validation

**Binary path overrides**: Customize paths via `tool_binaries` (e.g., for project-specific tool locations)

Example quality configuration:

```yaml
quality_checks:
  enabled_tools:
    - "php-cs-fixer"
    - "psalm"
    - "rector"
    - "phpunit"
    - "composer-validate"
    - "phpunuhi"
  
  tool_binaries:
    php-cs-fixer: "./vendor/meteor/shop6-project-conventions/tools/php-cs-fixer"
    phpunuhi: "./vendor/bin/phpunuhi"
```