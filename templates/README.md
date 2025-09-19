# Configuration Templates

This directory contains example configuration files for different project types. These templates provide a starting point for configuring the generic CI/CD workflows.

## Available Templates

### Shopware Projects (`shopware/`)
Complete configuration for Shopware 6 projects, including:
- **pipeline-config.yml**: Unified CI/CD config with PHP 8.1, Node 18, Shopware-specific quality checks (PHPUnuhi validation), deployment settings for Level27 hosting, and framework-specific defaults for shared folders and console commands
- **Workflow templates**: Example GitHub Actions workflows for build, deploy, PR checks, and release validation

### Laravel Projects (`laravel/`)
Configuration optimized for Laravel applications:
- **pipeline-config.yml**: Unified CI/CD config with PHP 8.2, Node 20, Laravel-specific build commands (Artisan optimization), shared folders (storage, bootstrap/cache), and quality checks

### Symfony Projects (`symfony/`)
Configuration for Symfony applications:
- **pipeline-config.yml**: Unified CI/CD config with PHP 8.1, Node 18, Symfony console commands, Doctrine migrations, and framework-specific deployment settings

### Generic Projects (`generic/`)
Minimal configuration for projects that don't fit specific frameworks:
- **pipeline-config.yml**: Unified CI/CD config with basic PHP/Node setup, generic build commands, simple deployment, and standard PHP quality tools

## Using Templates

### 1. Copy Template Files

#### Option A: Use the Setup Script (Recommended)
Use the automated setup script to copy templates and configure your project:

```bash
# Run the setup script
./scripts/setup-project.sh [project-type] [hosting-provider]

# Examples:
./scripts/setup-project.sh shopware level27
./scripts/setup-project.sh laravel byte
./scripts/setup-project.sh symfony hipex
./scripts/setup-project.sh generic hostedpower
```

The setup script will:
- Copy the appropriate template files to `.github/`
- Configure hosting provider settings
- Create example workflow files
- Set up basic project structure

#### Option B: Manual Copy
Copy the appropriate template files to your project's `.github/` directory:

```bash
# For Shopware projects
cp templates/shopware/*.yml .github/

# For Laravel projects
cp templates/laravel/*.yml .github/

# For Symfony projects
cp templates/symfony/*.yml .github/

# For generic projects
cp templates/generic/*.yml .github/
```

### 2. Customize Configuration
Edit the `pipeline-config.yml` file to match your project:

- Update `project.name` with your actual project name
- Configure environment hosts and paths (use placeholder values that reference GitHub secrets)
- Adjust PHP/Node versions as needed
- Add or remove quality tools based on your setup
- Customize build commands and shared folders
- Override tool binary paths if your project has custom tool locations:
  ```yaml
  quality_checks:
    tool_binaries:
      php-cs-fixer: "./bin/php-cs-fixer"  # Custom binary location
  ```

### 3. Set Up GitHub Secrets
Configure the required secrets in your GitHub repository:

#### Required for All Projects
- `COMPOSER_AUTH`: Composer authentication JSON

#### Required for Deployment
- `SSH_PRIVATE_KEY`: SSH private key for deployment

#### Required Repository Variables (Settings > Secrets and variables > Actions > Variables)
- `PROJECT_HOST`: Deployment hostname (e.g., "prod.example.com")
- `RELEASE_ROOT`: Base deployment path (e.g., "/var/www")
- `SSH_USER`: SSH username for deployment
- `DATABASE`: Database name
- `MESSENGER_WORKER_ID`: Messenger worker ID (for Shopware/Symfony projects)

### 4. Create Workflow Files
Create workflow files in `.github/workflows/` that reference the reusable workflows:

```yaml
# .github/workflows/build.yml
name: Build
on:
  push:
    branches: ['test/*', 'release/*']
    tags: ['[0-9]+.[0-9]+.[0-9]+']

jobs:
  build:
    uses: meteor-digital/github-actions/.github/workflows/build-artifact.yml@main
    with:
      config_path: ".github/pipeline-config.yml"
    secrets:
      composer_auth: ${{ secrets.COMPOSER_AUTH }}
      notification_webhook: ${{ secrets.TEAMS_WEBHOOK }}
```

## Framework-Specific Features

### Shopware
- **Auto-detection**: Presence of `shopware-project.yml`
- **Build**: Uses Shopware CLI for production builds
- **Deployment**: Shared folders for files, media, themes
- **Quality**: PHPUnuhi translation validation
- **Services**: Messenger worker management

### Laravel
- **Auto-detection**: Presence of `artisan` file
- **Build**: Artisan optimization commands (config, route, view cache)
- **Deployment**: Shared storage and bootstrap/cache folders
- **Quality**: Laravel Pint code style, Feature/Unit test separation
- **Services**: Queue worker restart

### Symfony
- **Auto-detection**: Presence of `symfony.lock`
- **Build**: Console cache warmup and asset installation
- **Deployment**: Shared var folder, Doctrine migrations
- **Quality**: Symfony-specific linting (YAML, Twig, container)
- **Services**: Messenger transport setup

### Generic
- **Fallback**: Used when no specific framework is detected
- **Build**: Basic Composer and NPM commands
- **Deployment**: Minimal shared folders and commands
- **Quality**: Standard PHP quality tools only

## Validation

All template files are validated against the unified pipeline configuration JSON schema. You can validate your customized files using:

```bash
# Using the validation script
./scripts/validate-config.sh .github

# Using ajv-cli (if installed)
ajv validate -s schemas/pipeline-config.schema.json -d .github/pipeline-config.yml
```

The schema validates:
- Required fields (project.name, runtime.php_version)
- Valid hosting provider values
- Proper environment configuration structure
- Quality tool names and binary path formats
- Notification webhook URL formats