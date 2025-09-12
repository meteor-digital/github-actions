# Deploy to Host Action

A production-ready GitHub Action for deploying applications to remote hosts using proven deployment patterns from the LensOnline project.

## Features

- **Multi-Framework Support**: Shopware, Laravel, Symfony with auto-detection
- **Multiple Hosting Providers**: Level27, Byte, Hipex, HostedPower, and generic
- **Atomic Deployments**: Zero-downtime deployments using symlink switching
- **Shared Folder Management**: Configurable shared folders with automatic symlink creation
- **Service Management**: Framework and provider-specific service restart logic
- **Maintenance Mode**: Console command-based maintenance mode for Shopware/Symfony
- **Database Migrations**: Framework-specific migration commands
- **Proven Patterns**: Based on battle-tested LensOnline deployment workflows
- **Sentry Integration**: Automatic Sentry release tracking

## Usage

```yaml
- name: Deploy to environment
  uses: ./actions/deploy-to-host
  with:
    config_file: '.github/deployment-config.yml'
    environment: 'test'
    build_path: './build'
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    ssh_user: 'deploy'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to deployment configuration file | No | `.github/deployment-config.yml` |
| `environment` | Target environment (test, acc, prod, etc.) | Yes | - |
| `build_path` | Path to built project files | No | `.` |
| `ssh_private_key` | SSH private key for deployment | Yes | - |
| `ssh_user` | SSH username for deployment | Yes | - |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment_status` | Status of the deployment (success, failed) |
| `release_path` | Path to the deployed release |
| `deploy_date` | Deployment date/time identifier |

## Configuration

The action uses a two-layer configuration system:

1. **Framework Defaults**: Automatically loaded from the shared actions repo based on project type
2. **Project Configuration**: Your project-specific settings that override the defaults

### Framework Defaults

The action automatically applies framework-specific defaults based on project type detection:

- **Shopware**: Shared folders (files, public/media, etc.), Shopware console commands
- **Laravel**: Shared folders (storage, bootstrap/cache), Laravel artisan commands  
- **Symfony**: Shared folders (var, public/uploads), Symfony console commands

### Project Configuration

Create a `.github/deployment-config.yml` file with only the settings you need to customize:

```yaml
# Only specify what differs from framework defaults
environments:
  test:
    host: "test.example.com"
    path: "/var/www/test"
    maintenance_mode: true
    
  acc:
    host: "acc.example.com"
    path: "/var/www/acc"
    maintenance_mode: true
    
  prod:
    host: "prod.example.com"
    path: "/var/www/prod"
    maintenance_mode: true

hosting:
  provider: "level27"  # Required: level27, byte, hipex, hostedpower, generic
  ssh_port: 22
  php_service: "php8.1-fpm"
  messenger_worker_id: "1"  # For Shopware/Symfony projects

# Optional: Override framework defaults
# deployment:
#   shared_folders:
#     - "files"
#     - "public/media"
#     - "custom/shared/folder"  # Add to defaults
#   
#   commands:
#     post_deploy:
#       - "bin/console cache:warmup"
#       - "bin/console theme:compile --active-only"
#       - "custom-post-deploy-command"  # Add to defaults
#   
#   cleanup:
#     keep_releases: 5  # Override default of 3
```

### Configuration Override Behavior

- **Complete Override**: Project configuration completely replaces framework defaults for each section
- **Section-Level**: If you specify `shared_folders` in your config, it replaces ALL default shared folders
- **Command-Level**: If you specify `pre_deploy` commands, it replaces ALL default pre-deploy commands
- **Granular Control**: You can override individual sections while keeping others as defaults

### Benefits of This Approach

- **Minimal Configuration**: Only specify what's different from proven defaults
- **Automatic Updates**: Framework defaults are embedded in the action and updated with new releases
- **Proven Patterns**: Defaults are based on battle-tested LensOnline deployment patterns
- **Hard Validation**: Fails fast if unsupported project type is detected
- **No External Dependencies**: All defaults are embedded, no external file dependencies


## Deployment Process

The action follows this deployment process (based on proven LensOnline patterns):

1. **Project Detection**: Auto-detect project type and load framework defaults
2. **Configuration Parsing**: Read and validate deployment configuration, override defaults
3. **SSH Setup**: Setup SSH known_hosts for secure connections
4. **File Synchronization**: Sync files using rsync-deployments action
5. **Shared Folders**: Create symlinks to shared folders (LensOnline pattern)
6. **Cache Warmup**: Warm up cache for Shopware/Symfony projects (project-type specific)
7. **Pre-deployment Commands**: Execute configured pre-deployment commands
8. **Maintenance Mode**: Enable maintenance mode using framework-specific commands
9. **Service Management**: Stop framework-specific services (messenger/queue workers)
10. **Database Migration**: Run framework-specific database migrations
11. **Atomic Switch**: Switch to new release using direct symlink (no tmp)
12. **Sentry Release**: Set Sentry release environment variable
13. **Post-deployment Commands**: Execute configured post-deployment commands
14. **Service Restart**: Restart services based on hosting provider
15. **Maintenance Mode**: Disable maintenance mode using framework-specific commands
16. **Cleanup**: Remove old releases using LensOnline cleanup pattern
17. **Failure Handling**: On failure, disable maintenance and clear cache (no rollback)

## Framework Support

### Shopware (Default)
- **Detection**: `shopware-project.yml` file exists
- **Migration Command**: `bin/console database:migrate --all`
- **Default Shared Folders**: `files`, `public/media`, `public/sitemap`, `public/thumbnail`, `config/jwt`, `var/log`
- **Default Post-deploy**: Cache warmup, theme compilation

### Laravel
- **Detection**: `artisan` file exists
- **Migration Command**: `php artisan migrate --force`
- **Default Shared Folders**: `storage`, `bootstrap/cache`
- **Default Post-deploy**: Config cache, route cache, view cache

### Symfony
- **Detection**: `symfony.lock` file exists
- **Migration Command**: `bin/console doctrine:migrations:migrate --no-interaction`
- **Default Shared Folders**: `var`, `public/uploads`
- **Default Post-deploy**: Cache warmup, doctrine migrations

## Hosting Provider Support

### Level27 (Primary - LensOnline Provider)
- **PHP Service**: `sudo /usr/sbin/service php8.1-fpm reload`
- **Messenger Workers**: `systemctl --user start worker-{id}.service`

### Byte
- **PHP Service**: `hypernode-servicectl restart php-fpm`

### Hipex
- **PHP Service**: `hipex restart:phpfpm php-fpm`

### HostedPower
- **PHP Service**: `tscli opcache clear`

### Generic
- **PHP Service**: `sudo systemctl reload php-service`

## Security Considerations

- SSH private keys are handled securely and not logged
- SSH connections use strict host key checking
- All commands are executed with proper error handling
- Rollback functionality ensures system stability

## Error Handling

The action includes comprehensive error handling based on LensOnline patterns:

- **SSH Connection Failures**: Validates SSH setup before proceeding
- **Configuration Errors**: Validates required configuration and fails fast
- **Deployment Failures**: Disables maintenance mode and clears cache
- **Service Failures**: Attempts to restart services with provider-specific commands
- **Migration Failures**: Stops deployment process

## Failure Recovery

On deployment failure, the action automatically (following LensOnline pattern):

1. Disables maintenance mode using console commands
2. Clears cache for Shopware/Symfony projects
3. Does NOT rollback symlink (following LensOnline approach)
4. Reports failure status

**Note**: Unlike some deployment systems, this action follows the LensOnline pattern of not rolling back the symlink on failure, as migrations may have already been applied.

## Examples

### Basic Shopware Deployment
```yaml
- name: Deploy Shopware to test
  uses: ./actions/deploy-to-host
  with:
    environment: 'test'
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
```

### Laravel Deployment with Custom Config
```yaml
- name: Deploy Laravel to production
  uses: ./actions/deploy-to-host
  with:
    config_file: '.github/laravel-deploy.yml'
    environment: 'prod'
    build_path: './dist'
    ssh_private_key: ${{ secrets.PROD_SSH_KEY }}
    ssh_user: 'www-data'
```

### Multi-Environment Deployment
```yaml
- name: Deploy to test environment
  if: startsWith(github.ref, 'refs/heads/test/')
  uses: ./actions/deploy-to-host
  with:
    environment: 'test'
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}

- name: Deploy to production
  if: startsWith(github.ref, 'refs/tags/')
  uses: ./actions/deploy-to-host
  with:
    environment: 'prod'
    ssh_private_key: ${{ secrets.PROD_SSH_KEY }}
```
