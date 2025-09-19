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
# Unified CI/CD Configuration
project:
  name: "my-project"
  # type: "shopware"  # Auto-detected if not specified

runtime:
  php_version: "8.1"  # Required
  #node_version: "18"  # Optional, defaults to 18
  # php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache"  # Optional

quality_checks:
  enabled_tools:
    - "php-cs-fixer"
    - "psalm"
    - "phpstan"
    - "rector"
    - "phpunit"
    - "composer-validate"
    - "phpunuhi"
  
  # Override default binary paths (optional)
  tool_binaries:
    php-cs-fixer: "./vendor/bin/php-cs-fixer"
    psalm: "./vendor/bin/psalm"

build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
    *.log
    *.cache
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"

  # Build artifact configuration
  artifacts:
    retention_days: 7

notifications:
  notification_webhook: "https://hooks.example.com/webhook"

deployment:
  environments:
    test:
      host: "test.example.com"
      path: "/var/www/test"
      ssh_user: "deploy"  # Can be environment-specific
      messenger_worker_id: "1"  # Optional, Shopware/Symfony specific
    prod:
      host: "prod.example.com"
      path: "/var/www/prod"
      ssh_user: "deploy"
      messenger_worker_id: "2"
  
  hosting:
    provider: "level27"  # level27, byte, hipex, hostedpower, generic
    ssh_user: "deploy"  # Global default, can be overridden per environment
    php_service: "php8.1-fpm"
  
  # Optional: Override framework defaults
  shared_folders:
    - "custom/shared/folder"
  
  commands:
    pre_deploy:
      - "custom-pre-deploy-command"
    post_deploy:
      - "custom-post-deploy-command"
  
  cleanup:
    keep_releases: 3  # Number of releases to keep
```

## Framework Defaults

The action automatically applies framework-specific defaults:

### Shopware
- **Shared folders**: `files`, `public/media`, `public/sitemap`, `public/thumbnail`, `config/jwt`, `var/log`
- **Pre-deploy**: `bin/console cache:warmup --no-optional-warmers`
- **Post-deploy**: `bin/console theme:dump`, `bin/console theme:compile --active-only``
- **Migration command**: `bin/console database:migrate --all`
- **Maintenance enable**: `bin/console sales-channel:maintenance:enable --all`
- **Maintenance disable**: `bin/console sales-channel:maintenance:disable --all`

### Laravel
- **Shared folders**: `storage`, `bootstrap/cache`
- **Pre-deploy**: (none)
- **Post-deploy**: `php artisan config:cache`, `php artisan route:cache`, `php artisan view:cache`, `php artisan optimize`
- **Migration command**: `php artisan migrate --force`
- **Maintenance enable**: `php artisan down`
- **Maintenance disable**: `php artisan up`

### Symfony
- **Shared folders**: `var`, `public/uploads`
- **Pre-deploy**: `bin/console cache:warmup --no-optional-warmers`
- **Post-deploy**: `bin/console doctrine:migrations:migrate --no-interaction`
- **Migration command**: `bin/console doctrine:migrations:migrate --no-interaction`
- **Maintenance enable**: `touch maintenance.html`
- **Maintenance disable**: `rm -f maintenance.html`

## Configuration Validation

The action performs comprehensive validation:

- **File existence**: Ensures the configuration file exists
- **YAML syntax**: Validates YAML syntax using `yq`
- **Required fields**: Validates that required fields like `runtime.php_version` are present
- **Format validation**: Validates PHP version format (X.Y), Node version (integer), retention days (integer)
- **Environment validation**: Validates environment names contain only letters, numbers, and hyphens
- **Deployment validation**: When parsing deployment config, validates required fields like host, path, provider, and ssh_user

## Quality Tools Integration

The action supports comprehensive quality tool configuration:

- **Default tools**: `php-cs-fixer`, `psalm`, `phpstan`, `rector`, `phpunit`, `composer-validate`
- **Optional tools**: `phpunuhi` for translation validation
- **Binary path overrides**: Customize paths to tool binaries (useful for project-specific tool locations)
- **Tool selection**: Enable/disable specific tools per project

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