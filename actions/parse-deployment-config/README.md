# Parse Deployment Configuration Action

Parses deployment configuration files and merges them with framework-specific defaults.

## Features

- **Framework Detection**: Automatically loads defaults for Shopware, Laravel, and Symfony
- **Configuration Merging**: Project configuration overrides framework defaults
- **Validation**: Validates required configuration parameters
- **Fallback Parsing**: Uses yq if available, falls back to grep/sed

## Usage

```yaml
- name: Parse deployment configuration
  id: config
  uses: ./actions/parse-deployment-config
  with:
    config_file: '.github/deployment-config.yml'
    environment: 'test'
    project_type: 'shopware'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to deployment configuration file | No | `.github/deployment-config.yml` |
| `environment` | Target environment | Yes | - |
| `project_type` | Project type (shopware, laravel, symfony) | Yes | - |

## Outputs

| Output | Description |
|--------|-------------|
| `host` | Deployment host |
| `path` | Deployment path |
| `provider` | Hosting provider |
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

## Framework Defaults

### Shopware
- **Shared Folders**: files, public/media, public/sitemap, public/thumbnail, config/jwt, var/log
- **Pre-deploy**: Cache warmup, plugin refresh
- **Post-deploy**: Theme compilation, scheduled tasks, DAL refresh
- **Migration**: `bin/console database:migrate --all`
- **Maintenance**: `bin/console sales-channel:maintenance:enable/disable --all`

### Laravel
- **Shared Folders**: storage, bootstrap/cache
- **Pre-deploy**: (none)
- **Post-deploy**: Config cache, route cache, view cache, optimize
- **Migration**: `php artisan migrate --force`
- **Maintenance**: `php artisan down/up`

### Symfony
- **Shared Folders**: var, public/uploads
- **Pre-deploy**: Cache warmup
- **Post-deploy**: Doctrine migrations
- **Migration**: `bin/console doctrine:migrations:migrate --no-interaction`
- **Maintenance**: `touch/rm maintenance.html`

## Configuration Override

Project configuration completely overrides framework defaults for each section:

```yaml
# If you specify shared_folders, it replaces ALL default shared folders
deployment:
  shared_folders:
    - "custom/folder"  # This replaces the entire default list
```

## Error Handling

- Validates required configuration (host, path, provider)
- Fails fast with clear error messages
- Supports both yq and grep/sed parsing methods