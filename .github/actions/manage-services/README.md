# Manage Services Action

Manages services (stop/restart) based on project type and hosting provider.

## Usage

```yaml
- name: Stop services
  uses: ./actions/manage-services
  with:
    action: stop
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    project_type: 'shopware'
    provider: 'level27'
    php_service: 'php8.1-fpm'
    messenger_worker_id: '1'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `action` | Action to perform (stop, restart) | Yes | - |
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `project_type` | Project type (shopware, laravel, symfony) | Yes | - |
| `provider` | Hosting provider | Yes | - |
| `php_service` | PHP service name | Yes | - |
| `messenger_worker_id` | Messenger worker ID (for Shopware/Symfony) | No | - |

## How It Works

**Stop action:**
- **Shopware/Symfony**: Stops messenger workers (`systemctl --user stop worker-{id}.service`)
- **Laravel**: Stops queue workers (`pkill -f 'queue:work'`)

**Restart action:**
- Restarts PHP service using provider-specific command
- Restarts messenger workers (Shopware/Symfony on Level27 only)

## Hosting Providers

| Provider | PHP Service Restart | Messenger Workers |
|----------|---------------------|-------------------|
| **Level27** | `sudo service php8.1-fpm reload` | `systemctl --user start worker-{id}.service` |
| **Byte** | `hypernode-servicectl restart php-fpm` | _(not supported)_ |
| **Hipex** | `hipex restart:phpfpm php-fpm` | _(not supported)_ |
| **HostedPower** | `tscli opcache clear` | _(not supported)_ |
| **Forge** | `sudo service php8.4-fpm reload` | _(not supported)_ |
| **Generic** | `sudo systemctl reload php-service` | _(not supported)_ |

## Related Actions

- **`deploy-to-host`**: Uses this action to stop/restart services during deployment