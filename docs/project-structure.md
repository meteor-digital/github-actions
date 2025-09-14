# Project Structure

This document describes the organization of the generic CI/CD workflows repository.

## Repository Layout

```
generic-ci-cd-workflows/
├── .github/
│   └── workflows/                    # Reusable workflow templates
│       ├── build-artifact.yml       # Generic build workflow
│       ├── deploy.yml               # Generic deployment workflow
│       ├── quality-checks.yml       # Generic quality checks workflow
│       ├── pr-checks.yml            # Generic PR validation workflow
│       └── verify-release-next.yml  # Generic release branch validation workflow
├── actions/                         # Composite actions
│   ├── setup-environment/          # Environment setup action
│   │   └── action.yml
│   ├── build-project/              # Project build action
│   │   └── action.yml
│   ├── deploy-to-host/             # Deployment action
│   │   └── action.yml
│   └── notify-teams/               # Notification action
│       └── action.yml
├── docs/                           # Documentation
│   ├── configuration.md           # Configuration guide
│   ├── project-structure.md       # This file
│   ├── migration-guide.md          # Migration from project-specific workflows
│   └── troubleshooting.md          # Common issues and solutions
├── templates/                      # Project templates
│   ├── shopware/                  # Shopware project templates
│   │   ├── ci-config.yml
│   │   ├── deployment-config.yml
│   │   ├── quality-config.yml
│   │   └── .github/workflows/
│   ├── laravel/                   # Laravel project examples
│   └── symfony/                   # Symfony project examples
├── scripts/                       # Utility scripts
│   ├── validate-config.sh         # Configuration validation
│   └── setup-project.sh           # Project setup helper
├── README.md                      # Main documentation
└── LICENSE                        # License file
```

## Reusable Workflows

### `workflows/`

Contains the main reusable workflow templates that projects can consume:

- **build-artifact.yml**: Builds project artifacts with configurable build steps
- **deploy.yml**: Deploys built artifacts to configured environments
- **quality-checks.yml**: Runs code quality tools and tests
- **pr-checks.yml**: Fast feedback for pull request validation
- **verify-release-next.yml**: Scheduled validation of release branches with comprehensive quality checks

These workflows are consumed by projects using GitHub's `uses: org/repo/workflows/workflow.yml@ref` syntax.

## Composite Actions

### `actions/`

Contains reusable composite actions that encapsulate common functionality:

#### setup-environment
- Sets up PHP with configurable version and extensions
- Sets up Node.js with configurable version
- Installs Composer dependencies with caching
- Installs NPM dependencies with caching (if package.json exists)
- Auto-detects project type for framework-specific setup

#### build-project
- Auto-detects project type (Shopware, Laravel, Symfony)
- Runs framework-specific build commands
- Executes custom build commands from configuration
- Removes excluded files/folders based on configuration
- Creates build metadata (build-info.json)

#### deploy-to-host
- Reads deployment configuration for target environment
- Sets up SSH connection to target host
- Syncs files to new release directory using rsync
- Creates symlinks to shared folders
- Runs pre/post-deployment commands
- Enables/disables maintenance mode
- Manages service restarts based on hosting provider
- Implements atomic deployment with rollback capability

#### notify-teams
- Sends notifications to Teams/Slack channels
- Supports configurable webhook URLs and message formats
- Includes deployment status and environment information
- Provides actionable error information for failures

## Documentation

### `docs/`

Comprehensive documentation for users and contributors:

- **configuration.md**: Detailed configuration guide with examples
- **project-structure.md**: This file describing repository organization
- **migration-guide.md**: Step-by-step migration from project-specific workflows
- **troubleshooting.md**: Common issues and their solutions

## Templates

### `templates/`

Framework-specific template configurations:

#### Shopware Templates
- Complete configuration files for typical Shopware projects
- Example workflow files showing how to consume reusable workflows
- Level27 hosting provider configuration

#### Laravel Templates (Future)
- Laravel-specific configuration templates
- Artisan command integration
- Storage and cache management

#### Symfony Templates (Future)
- Symfony-specific configuration templates
- Console command integration
- Asset management

## Configuration Schema

The system uses three main configuration files:

### CI Configuration (`.github/ci-config.yml`)
```yaml
project:          # Project metadata
runtime:          # PHP/Node versions and extensions
build:            # Build commands and exclusion patterns
artifacts:        # Artifact naming and retention
```

### Deployment Configuration (`.github/deployment-config.yml`)
```yaml
environments:     # Environment-specific settings
hosting:          # Hosting provider configuration
deployment:       # Shared folders and commands
```

### Quality Configuration (`.github/quality-config.yml`)
```yaml
quality_checks:   # Enabled tools and custom checks
notifications:    # Teams/Slack notification settings
```

## Workflow Integration

### Project Integration

Projects integrate with these workflows by:

1. Creating configuration files in `.github/` directory
2. Creating workflow files that reference reusable workflows
3. Setting up required GitHub secrets
4. Configuring environment-specific variables

### Example Integration

```yaml
# Project's .github/workflows/build.yml
jobs:
  build:
    uses: org/generic-ci-cd-workflows/workflows/build-artifact.yml@main
    with:
      config_path: ".github/ci-config.yml"
    secrets:
      composer_auth: ${{ secrets.COMPOSER_AUTH }}
```

## Extensibility

### Adding New Framework Support

1. Update `setup-environment` action with framework detection
2. Add framework-specific build logic to `build-project` action
3. Create example configurations in `examples/` directory
4. Update documentation with framework-specific guidance

### Adding New Hosting Providers

1. Update `deploy-to-host` action with provider-specific logic
2. Add provider configuration options
3. Create example configurations
4. Document provider-specific requirements

### Adding New Quality Tools

1. Update `quality-checks` workflow with new tool integration
2. Add tool configuration options
3. Update example quality configurations
4. Document tool-specific setup requirements

## Security Considerations

### Secret Management
- All sensitive information stored in GitHub secrets
- Configuration files use environment variable references
- SSH keys and authentication tokens properly secured

### Access Control
- Deployment workflows use environment protection rules
- Sensitive operations require manual approval for production
- Audit trail maintained for all deployments

### Network Security
- SSH connections use key-based authentication
- Known hosts verification for deployment targets
- Secure file transfer using rsync over SSH