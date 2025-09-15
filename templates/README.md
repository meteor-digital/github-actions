# Configuration Templates

This directory contains example configuration files for different project types. These templates provide a starting point for configuring the generic CI/CD workflows.

## Available Templates

### Shopware Projects (`shopware/`)
Complete configuration for Shopware 6 projects, including:
- **ci-config.yml**: PHP 8.1, Node 18, Shopware-specific build commands
- **deployment-config.yml**: Shopware shared folders, console commands
- **quality-config.yml**: PHPUnuhi validation, Shopware-specific checks

### Laravel Projects (`laravel/`)
Configuration optimized for Laravel applications:
- **ci-config.yml**: PHP 8.2, Node 20, Laravel optimization commands
- **deployment-config.yml**: Laravel shared folders, Artisan commands
- **quality-config.yml**: Laravel Pint, Feature/Unit test suites

### Symfony Projects (`symfony/`)
Configuration for Symfony applications:
- **ci-config.yml**: PHP 8.1, Node 18, Symfony console commands
- **deployment-config.yml**: Symfony shared folders, Doctrine migrations
- **quality-config.yml**: Symfony linting, Messenger setup

### Generic Projects (`generic/`)
Minimal configuration for projects that don't fit specific frameworks:
- **ci-config.yml**: Basic PHP/Node setup, generic build commands
- **deployment-config.yml**: Simple deployment with custom commands
- **quality-config.yml**: Standard PHP quality tools

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
Edit the copied files to match your project:

- Update `project.name` with your actual project name
- Configure environment hosts and paths using GitHub secrets
- Adjust PHP/Node versions as needed
- Add or remove quality tools based on your setup
- Customize build commands and shared folders

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

#### Optional for Notifications
- `TEAMS_WEBHOOK`: Microsoft Teams webhook URL
- `SLACK_WEBHOOK`: Slack webhook URL

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
      config_path: ".github/ci-config.yml"
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

## Customization Examples

### Adding Custom Build Commands
```yaml
# ci-config.yml
build:
  build_commands:
    - "npm run build"
    - "composer install --no-dev --optimize-autoloader"
    - "php bin/custom-build-script.php"  # Custom command
```

### Custom Shared Folders
```yaml
# deployment-config.yml
deployment:
  shared_folders:
    - "custom/uploads"      # Add to framework defaults
    - "public/generated"    # Custom shared folder
```

### Additional Quality Checks
```yaml
# quality-config.yml
quality_checks:
  custom_checks:
    - name: "custom-linter"
      command: "vendor/bin/custom-linter src/"
      continue_on_error: false
```

### Multiple Environments
```yaml
# deployment-config.yml
environments:
  dev:
    auto_deploy: true
    branches: ["develop"]
    host: "${DEV_HOST}"
    path: "${DEV_PATH}"
  test:
    auto_deploy: true
    branches: ["test/*"]
    host: "${TEST_HOST}"
    path: "${TEST_PATH}"
  staging:
    auto_deploy: true
    branches: ["staging"]
    host: "${STAGING_HOST}"
    path: "${STAGING_PATH}"
  prod:
    auto_deploy: false
    triggers: ["tag"]
    host: "${PROD_HOST}"
    path: "${PROD_PATH}"
```

## Validation

All template files are validated against their respective JSON schemas. You can validate your customized files using:

```bash
# Using the validation script
./scripts/validate-config.sh .github

# Using ajv-cli (if installed)
ajv validate -s schemas/ci-config.schema.json -d .github/ci-config.yml
```

## Getting Help

- Check the [Configuration Guide](../docs/configuration.md) for detailed explanations
- Review the [JSON Schemas](../schemas/) for validation rules
- See the [Project Structure Guide](../docs/project-structure.md) for workflow setup
- Open an issue for questions or problems