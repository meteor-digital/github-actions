# Generic CI/CD Workflows

A collection of reusable GitHub Actions workflows and composite actions for consistent CI/CD practices across multiple projects.

## Overview

This repository provides generic, configurable CI/CD workflows that can be easily adopted by different projects without duplicating workflow code. The system supports multiple project types (Shopware, Laravel, Symfony) and hosting providers through configuration files.

## Architecture

This repository contains **reusable workflows** that are consumed by individual projects via GitHub's `uses` syntax. Projects don't copy these workflows - they reference them:

- **This repository**: Contains the reusable workflow templates and composite actions
- **Project repositories**: Contain small workflow files that reference the reusable workflows + configuration files
- **Configuration**: Project-specific settings are externalized to YAML configuration files

This approach ensures:
- ✅ Single source of truth for CI/CD logic
- ✅ Easy updates across all projects
- ✅ Consistent behavior without code duplication
- ✅ Project-specific customization through configuration

## Features

- **Reusable Workflows**: Generic workflow templates for build, deploy, and quality checks
- **Configuration-Driven**: Project-specific settings externalized to configuration files
- **Multi-Framework Support**: Built-in support for Shopware, Laravel, Symfony, and generic projects
- **Multiple Hosting Providers**: Support for Level27, Byte, Hipex, HostedPower, and custom providers
- **Quality Checks**: Integrated code quality tools (PHP-CS-Fixer, Psalm, PHPStan, Rector, PHPUnit)
- **Notifications**: Teams/Slack notifications for build and deployment status

## Quick Start

### 1. Create Configuration Files in Your Project

Create the following configuration files in your project's `.github/` directory:

- `.github/ci-config.yml` - Build and runtime configuration
- `.github/deployment-config.yml` - Deployment and hosting configuration  
- `.github/quality-config.yml` - Code quality and notification settings

### 2. Use Reusable Workflows

Create workflow files in your project's `.github/workflows/` directory that **reference** these reusable workflows (don't copy them):

```yaml
# .github/workflows/build.yml
name: Build Artifact
on:
   push:
    branches:
      # Build artifacts automatically for test & release branches
      # Exclude release/next from automatic builds on every push
      - 'test/*'
      - 'release/[0-9]+.[0-9]+.[0-9]+'
    tags:
      # Build PROD artifacts when tags are pushed
      - '[0-9]+.[0-9]+.[0-9]'

jobs:
  build:
    uses: meteor-digital/github-actions/.github/workflows/build-artifact.yml@main
    with:
      config_path: ".github/ci-config.yml"
    secrets:
      composer_auth: ${{ secrets.COMPOSER_AUTH }}
```

### 3. Use the Setup Script (Recommended)

For easier setup, use the provided setup script. You need to clone this repository first to access the templates:

```bash
# Clone the github-actions repository
git clone https://github.com/meteor-digital/github-actions.git

# Run the setup script from your project directory
cd /path/to/your/project
/path/to/github-actions/scripts/setup-project.sh shopware level27
```

This will:
- Create all necessary configuration files in your project's `.github/` directory
- Copy workflow template files with correct repository references
- Set up the proper directory structure in your project

## Configuration

### Configuration Files

The system uses three main configuration files in your project's `.github/` directory:

- **CI Configuration** (`.github/ci-config.yml`) - Build and runtime settings
  - See example: [templates/shopware/ci-config.yml](templates/shopware/ci-config.yml)
  
- **Deployment Configuration** (`.github/deployment-config.yml`) - Environment and hosting settings  
  - See example: [templates/shopware/deployment-config.yml](templates/shopware/deployment-config.yml)
  
- **Quality Configuration** (`.github/quality-config.yml`) - Code quality tools and notifications
  - See example: [templates/shopware/quality-config.yml](templates/shopware/quality-config.yml)

For detailed configuration options and examples for different frameworks, see the [Configuration Guide](docs/configuration.md).

## Available Workflows

### PR Checks Workflow
- **File**: `.github/workflows/pr-checks.yml`
- **Purpose**: Fast feedback for pull request validation
- **Triggers**: Pull request creation and updates

### Quality Checks Workflow
- **File**: `.github/workflows/quality-checks.yml`
- **Purpose**: Runs code quality tools and tests
- **Triggers**: Pull requests, pushes to main branches

### Build Artifact Workflow
- **File**: `.github/workflows/build-artifact.yml`
- **Purpose**: Builds project artifacts with configurable build steps
- **Triggers**: Push to branches, pull requests, tags

### Deploy Workflow  
- **File**: `.github/workflows/deploy.yml`
- **Purpose**: Deploys built artifacts to configured environments
- **Triggers**: Successful builds on configured branches/tags

## Available Actions

### setup-environment
Sets up PHP, Node.js, and installs dependencies with caching.

### build-project
Builds the project using framework-specific commands and configurations.

### deploy-to-host
Deploys the built project to target environments with atomic deployment.

### notify-teams
Sends notifications to Teams/Slack channels with deployment status.

## Project Type Detection

The system automatically detects project types based on files present:

- **Shopware**: `shopware-project.yml` exists
- **Laravel**: `artisan` file exists  
- **Symfony**: `symfony.lock` exists
- **Generic**: Default fallback

## Hosting Provider Support

### Level27
- Service management via systemctl
- PHP-FPM service restart
- Standard shared folder structure

### Byte, Hipex, HostedPower
- Provider-specific service management
- Custom deployment commands
- Configurable shared folders

### Generic
- Customizable deployment commands
- Flexible service management
- Extensible configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with example projects
5. Submit a pull request

## License

MIT License - see LICENSE file for details.