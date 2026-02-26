# Generic CI/CD Workflows

A collection of reusable GitHub Actions workflows and composite actions for consistent CI/CD practices across multiple projects.

## Overview

This repository provides generic, configurable CI/CD workflows that can be easily adopted by different projects without duplicating workflow code. The system supports multiple project types (Shopware, Laravel, Symfony) and hosting providers through configuration files.

## Quick Start

**Automated Setup (Recommended):**
```bash
# Clone this repository
git clone https://github.com/meteor-digital/github-actions.git

# Run setup script from your project root (creates config + workflow files)
/path/to/github-actions/scripts/setup-project.sh shopware level27
```

**Manual Setup:**
1. Copy configuration from [templates/](templates/) to `.github/pipeline-config.yml`
2. Create workflow files that reference these reusable workflows:

```yaml
# .github/workflows/build-artifact.yml
jobs:
  build:
    uses: meteor-digital/github-actions/.github/workflows/build-artifact.yml@main
    with:
      config_path: ".github/pipeline-config.yml"
```

## Features

- **🔄 Reusable Workflows**: Generic templates for build, deploy, and quality checks
- **⚙️ Configuration-Driven**: Single YAML file contains all CI/CD settings  
- **🏗️ Multi-Framework**: Shopware 6, Laravel, Symfony, and generic PHP projects
- **🌐 Multiple Hosting**: Level27, Byte, Hipex, HostedPower, Forge, and custom SSH
- **🔍 Quality Assurance**: PHP-CS-Fixer, Psalm, PHPStan, Rector, PHPUnit, security scanning
- **📢 Smart Notifications**: Teams/Slack integration with rich formatting

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

## Configuration

Projects use a single configuration file: `.github/pipeline-config.yml`

This file contains project settings, quality checks, build configuration, deployment settings, and notifications. 

**Templates available:**
- [Shopware](templates/shopware/pipeline-config.yml) | [Laravel](templates/laravel/pipeline-config.yml) | [Symfony](templates/symfony/pipeline-config.yml) | [Generic](templates/generic/pipeline-config.yml)

Configuration is validated against a [JSON Schema](schemas/pipeline-config.schema.json) for IDE autocompletion.

## Available Workflows

All reusable workflows are located in [`.github/workflows/`](.github/workflows/). These are the main entry points that projects consume:

- **[pr-checks.yml](.github/workflows/pr-checks.yml)** - Fast feedback for pull request validation
- **[verify-release-next.yml](.github/workflows/verify-release-next.yml)** - Scheduled validation of release branches
- **[quality-checks.yml](.github/workflows/quality-checks.yml)** - Comprehensive code quality checks and testing
- **[build-artifact.yml](.github/workflows/build-artifact.yml)** - Builds project artifacts with framework-specific logic
- **[deploy.yml](.github/workflows/deploy.yml)** - Deploys built artifacts to configured environments

## Available Actions

All composite actions are located in [`.github/actions/`](.github/actions/). These provide reusable functionality used by the workflows:

**Core Actions** (commonly used directly):
- **[setup-environment](.github/actions/setup-environment/)** - Sets up PHP, Node.js, and installs dependencies with caching
- **[build-project](.github/actions/build-project/)** - Builds projects using framework-specific commands and configurations
- **[notify-teams](.github/actions/notify-teams/)** - Sends notifications to Teams/Slack channels

**Host Deployment** (traditional server deployments):
- **[deploy-to-host](.github/actions/deploy-to-host/)** - Complete deployment orchestration with atomic symlink switching
- **[run-commands-on-host](.github/actions/run-commands-on-host/)** - Executes commands on remote host via SSH
- **[activate-release](.github/actions/activate-release/)** - Activates new release using symlink switching
- **[create-symlinks](.github/actions/create-symlinks/)** - Creates symlinks for shared folders
- **[manage-services](.github/actions/manage-services/)** - Manages PHP-FPM and worker services
- **[cleanup-releases](.github/actions/cleanup-releases/)** - Cleans up old releases on host

**Azure Deployment** (container-based deployments):
- **[deploy-to-azure](.github/actions/deploy-to-azure/)** - Complete deployment orchestration with blue-green revision strategy
- **[build-and-push-docker-image](.github/actions/build-and-push-docker-image/)** - Builds and pushes Docker images to registries
- **[discover-azure-revisions](.github/actions/discover-azure-revisions/)** - Discovers new and old Azure Container App revisions
- **[run-command-on-azure-container](.github/actions/run-command-on-azure-container/)** - Executes commands on specific Azure revision
- **[switch-azure-traffic](.github/actions/switch-azure-traffic/)** - Switches traffic between Azure revisions (blue-green)
- **[cleanup-azure-revisions](.github/actions/cleanup-azure-revisions/)** - Cleans up old inactive Azure revisions

**Supporting Actions** (used internally):
- **[parse-pipeline-config](.github/actions/parse-pipeline-config/)** - Parses unified pipeline configuration
- **[detect-project-type](.github/actions/detect-project-type/)** - Auto-detects project framework type
- **[determine-artifact-name](.github/actions/determine-artifact-name/)** - Determines artifact names based on Git references
- **[composer-setup](.github/actions/composer-setup/)** - Sets up Composer with authentication and caching

For a complete list of all actions, see the [`.github/actions/`](.github/actions/) directory. Each action includes its own README with detailed documentation.

## Migrating from Jenkins

This repository provides a script to automate the migration from a legacy Jenkins setup to the `pipeline-config.yml` used by these GitHub Actions. The `scripts/migrate-jenkins-config.sh` script extracts settings from `Jenkinsfile-project-*` files, auto-detects quality tools, and generates a new `.github/pipeline-config.yml`.

**Usage:**

Run the script from your checkout of the `generic-ci-cd-workflows` repository. The script can be pointed at your project in two ways:

1.  **Provide the project path as an argument:**
    ```bash
    /path/to/generic-ci-cd-workflows/scripts/migrate-jenkins-config.sh /path/to/your-project
    ```

2.  **Run the command from within your project's directory:**
    ```bash
    cd /path/to/your-project
    /path/to/generic-ci-cd-workflows/scripts/migrate-jenkins-config.sh
    ```

After running, review and adjust the generated `pipeline-config.yml` before committing.
