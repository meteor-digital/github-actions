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

## Usage Examples

### Parse CI Configuration Only

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

### Parse CI and Deployment Configuration

```yaml
- name: Parse full configuration
  id: config
  uses: meteor-digital/github-actions/.github/actions/parse-pipeline-config@main
  with:
    config_file: '.github/pipeline-config.yml'
    environment: 'production'
    project_type: 'shopware'

- name: Build and deploy
  run: |
    echo "Building with PHP ${{ steps.config.outputs.php_version }}"
    echo "Deploying to ${{ steps.config.outputs.host }}"
```

## Configuration File Format

The action expects a unified YAML configuration file with the following structure:

```yaml
# Unified CI/CD Configuration
project:
  name: "my-project"

runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache"

build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"

artifacts:
  retention_days: 7

notifications:
  notification_webhook: "https://hooks.example.com/webhook"

deployment:
  environments:
    test:
      host: "test.example.com"
      path: "/var/www/test"
    prod:
      host: "prod.example.com"
      path: "/var/www/prod"
  
  hosting:
    provider: "level27"
    ssh_user: "deploy"
    php_service: "php8.1-fpm"
  
  # Optional: Override framework defaults
  shared_folders:
    - "custom/shared/folder"
  
  commands:
    pre_deploy:
      - "custom-pre-deploy-command"
    post_deploy:
      - "custom-post-deploy-command"
```

## Framework Defaults

The action automatically applies framework-specific defaults:

### Shopware
- **Shared folders**: `files`, `public/media`, `public/sitemap`, `public/thumbnail`, `config/jwt`, `var/log`
- **Pre-deploy**: `bin/console cache:warmup --no-optional-warmers``
- **Post-deploy**: `bin/console theme:compile --active-only`, `bin/console scheduled-task:register`, `bin/console dal:refresh:index`

### Laravel
- **Shared folders**: `storage`, `bootstrap/cache`
- **Post-deploy**: `php artisan config:cache`, `php artisan route:cache`, `php artisan view:cache`, `php artisan optimize`

### Symfony
- **Shared folders**: `var`, `public/uploads`
- **Pre-deploy**: `bin/console cache:warmup --no-optional-warmers`
- **Post-deploy**: `bin/console doctrine:migrations:migrate --no-interaction`

## Migration from Separate Parsers

This action replaces the separate `parse-ci-config` and `parse-deployment-config` actions:

```yaml
# Old approach
- uses: meteor-digital/github-actions/.github/actions/parse-ci-config@main
- uses: meteor-digital/github-actions/.github/actions/parse-deployment-config@main

# New approach
- uses: meteor-digital/github-actions/.github/actions/parse-pipeline-config@main
```

The action automatically parses CI configuration and will parse deployment configuration when `environment` and `project_type` parameters are provided.