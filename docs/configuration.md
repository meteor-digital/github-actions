# Configuration Guide

This guide explains how to configure the generic CI/CD workflows for your project.

## Configuration Files

The workflows use three main configuration files that should be placed in your project's `.github/` directory:

- `.github/pipeline-config.yml` - Unified CI/CD configuration including build, runtime, deployment, and hosting settings
- `.github/quality-config.yml` - Code quality and notification settings

## CI Configuration

### Basic Configuration

```yaml
# .github/ci-config.yml
project:
  name: "my-project"  # Used for artifacts, notifications, releases
  
runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache"
  
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
  build_commands:
    - "npm run build"
    - "composer install --no-dev"
  
artifacts:
  retention_days: 7
  naming_pattern: "{environment}-build-{version}"
```

### Project Type Detection

The system automatically detects your project type:

- **Shopware**: `shopware-project.yml` exists
- **Laravel**: `artisan` file exists
- **Symfony**: `symfony.lock` exists
- **Generic**: Default fallback (uses Shopware conventions)

### Runtime Configuration

#### PHP Configuration
- `php_version`: PHP version to use (e.g., "8.1", "8.2")
- `php_extensions`: Comma-separated list of PHP extensions

#### Node.js Configuration
- `node_version`: Node.js version to use (e.g., "18", "20")

### Build Configuration

#### Exclude Patterns
Use glob patterns to exclude files from the build artifact:

```yaml
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
    *.log
    var/cache/*
```

#### Custom Build Commands
Add custom commands to run during the build process:

```yaml
build:
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"
    - "bin/console assets:install"
```

## Deployment Configuration

### Basic Configuration

```yaml
# .github/deployment-config.yml
environments:
  test:
    auto_deploy: true
    branches: ["test/*"]
    host: "${TEST_HOST}"
    path: "${TEST_PATH}"
    maintenance_mode: true
    
  acc:
    auto_deploy: true
    branches: ["release/*"]
    host: "${ACC_HOST}"
    path: "${ACC_PATH}"
    maintenance_mode: true
    
  prod:
    auto_deploy: false
    triggers: ["tag"]
    host: "${PROD_HOST}"
    path: "${PROD_PATH}"
    maintenance_mode: true

hosting:
  provider: "level27"  # level27, byte, hipex, hostedpower, generic
  ssh_port: 22
  php_service: "php8.1-fpm"
  
deployment:
  shared_folders:
    - "files"
    - "public/media"
    - "public/sitemap"
    - "public/thumbnail"
    - "config/jwt"
    - "var/log"
  
  commands:
    pre_deploy: []
    post_deploy:
      - "bin/console cache:warmup"
      - "bin/console theme:compile --active-only"
    
  cleanup:
    keep_releases: 3
```

### Environment Configuration

Each environment can have the following settings:

- `auto_deploy`: Whether to automatically deploy when conditions are met
- `branches`: Array of branch patterns that trigger deployment
- `triggers`: Array of trigger types (`tag`, `manual`)
- `host`: Hostname or IP address (can use environment variables)
- `path`: Deployment path on the host
- `maintenance_mode`: Whether to enable maintenance mode during deployment

### Hosting Providers

#### Level27
```yaml
hosting:
  provider: "level27"
  ssh_port: 22
  php_service: "php8.1-fpm"
```

#### Byte
```yaml
hosting:
  provider: "byte"
  ssh_port: 22
  php_service: "php81-fpm"
```

#### Generic
```yaml
hosting:
  provider: "generic"
  ssh_port: 22
  php_service: "php-fpm"
  custom_commands:
    restart_services: "sudo service nginx reload && sudo service php-fpm restart"
```

### Shared Folders

Configure folders that should be shared between releases:

```yaml
deployment:
  shared_folders:
    - "files"              # Shopware uploads
    - "public/media"       # Shopware media
    - "public/sitemap"     # Generated sitemaps
    - "public/thumbnail"   # Generated thumbnails
    - "config/jwt"         # JWT certificates
    - "var/log"           # Application logs
    - "storage"           # Laravel storage (if Laravel)
```

### Deployment Commands

#### Pre-deployment Commands
Run before the atomic switch:

```yaml
deployment:
  commands:
    pre_deploy:
      - "bin/console database:migrate --all"
      - "bin/console plugin:refresh"
```

#### Post-deployment Commands
Run after the atomic switch:

```yaml
deployment:
  commands:
    post_deploy:
      - "bin/console cache:warmup"
      - "bin/console theme:compile --active-only"
      - "bin/console scheduled-task:register"
```

## Quality Configuration

### Basic Configuration

```yaml
# .github/quality-config.yml
quality_checks:
  enabled_tools:
    - "php-cs-fixer"
    - "psalm"           # Legacy static analysis
    - "phpstan"         # Modern static analysis
    - "rector"
    - "phpunit"
    - "composer-validate"
    
  custom_checks:
    - name: "phpunuhi"
      command: "php ./vendor/bin/phpunuhi validate:all"
    - name: "security-check"
      command: "composer audit"
      
notifications:
  teams:
    webhook_secret: "CHAT_WEB_HOOK"  # GitHub secret name
    timezone: "Europe/Amsterdam"
  slack:
    webhook_secret: "SLACK_WEBHOOK"
    channel: "#deployments"
```

### Quality Tools

#### Standard Tools
These tools use their standard configuration files:

- **php-cs-fixer**: Uses `.php-cs-fixer.php`
- **psalm**: Uses `psalm.xml` (legacy support)
- **phpstan**: Uses `phpstan.neon` (recommended)
- **rector**: Uses `rector.php`
- **phpunit**: Uses `phpunit.xml` or `phpunit.xml.dist`

#### Custom Checks
Add custom quality checks:

```yaml
quality_checks:
  custom_checks:
    - name: "translation-validation"
      command: "php ./vendor/bin/phpunuhi validate:all"
    - name: "security-audit"
      command: "composer audit"
    - name: "dependency-check"
      command: "composer outdated --direct"
```

### Notifications

#### Teams Notifications
```yaml
notifications:
  teams:
    webhook_secret: "TEAMS_WEBHOOK"  # GitHub secret containing webhook URL
    timezone: "Europe/Amsterdam"
    mention_on_failure: "@channel"
```

#### Slack Notifications
```yaml
notifications:
  slack:
    webhook_secret: "SLACK_WEBHOOK"
    channel: "#deployments"
    username: "CI/CD Bot"
    icon_emoji: ":rocket:"
```

## Workflow Configuration

### Verify Release Next Workflow

The verify-release-next workflow provides scheduled validation of release branches to catch issues early. It runs comprehensive quality checks and sends notifications when validation fails.

#### Configuration

The workflow uses the same quality configuration as other workflows but runs with comprehensive settings:

```yaml
# .github/workflows/verify-release-next.yml
name: Verify Release Next

on:
  schedule:
    # Run every 30 minutes during working hours (8:00-18:00 Brussels time)
    - cron: '0,30 7-17 * * 1-5'  # Every 30 minutes, 7:00-17:00 UTC, Monday-Friday
  
  workflow_dispatch:
    inputs:
      branch_name:
        description: 'Branch to validate'
        required: false
        default: 'release/next'

jobs:
  verify-release-next:
    uses: meteor-digital/github-actions/.github/workflows/verify-release-next.yml@main
    with:
      branch_name: ${{ github.event.inputs.branch_name || 'release/next' }}
      config_path: ".github/quality-config.yml"
      schedule_timezone: "Europe/Brussels"
    secrets:
      composer_auth: ${{ secrets.COMPOSER_AUTH }}
      notification_webhook: ${{ secrets.TEAMS_WEBHOOK }}
```

#### Features

- **Commit Status Tracking**: Avoids redundant validation by checking GitHub commit status
- **Comprehensive Validation**: Runs all quality checks including slow test suites
- **Failure Notifications**: Sends detailed Teams/Slack notifications when validation fails
- **Scheduled Execution**: Configurable cron schedule for automated validation
- **Manual Triggering**: Supports manual workflow dispatch for testing

#### Notification Format

When validation fails, the workflow sends a detailed notification including:

- Project name and branch name
- Commit SHA, author, and message
- Direct link to the workflow run
- Formatted for immediate action by development teams

#### Required Secrets

- `COMPOSER_AUTH`: For dependency installation
- `TEAMS_WEBHOOK` or `SLACK_WEBHOOK`: For failure notifications (optional)

## Environment Variables and Secrets

### Required Secrets

Set these secrets in your GitHub repository:

#### For All Workflows
- `COMPOSER_AUTH`: Composer authentication token

#### For Deployment Workflows
- `SSH_PRIVATE_KEY`: SSH private key for deployment
- `TEST_HOST`, `ACC_HOST`, `PROD_HOST`: Deployment hostnames
- `TEST_PATH`, `ACC_PATH`, `PROD_PATH`: Deployment paths

#### For Notifications
- `TEAMS_WEBHOOK` or `SLACK_WEBHOOK`: Notification webhook URLs

### Environment Variables in Configuration

Use GitHub secrets in configuration files:

```yaml
environments:
  test:
    host: "${TEST_HOST}"
    path: "${TEST_PATH}"
    database_url: "${TEST_DATABASE_URL}"
```

## Framework-Specific Examples

### Shopware Project

```yaml
# .github/ci-config.yml
project:
  name: "my-shopware-shop"
  
runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache, redis"
  
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
    var/cache/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"
```

### Laravel Project

```yaml
# .github/ci-config.yml
project:
  name: "my-laravel-app"
  
runtime:
  php_version: "8.2"
  node_version: "20"
  
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
    storage/logs/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"
    - "php artisan config:cache"
    - "php artisan route:cache"
    - "php artisan view:cache"
```

### Symfony Project

```yaml
# .github/ci-config.yml
project:
  name: "my-symfony-app"
  
runtime:
  php_version: "8.1"
  node_version: "18"
  
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    .env*
    var/cache/*
    var/log/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"
    - "bin/console cache:warmup --env=prod"
```