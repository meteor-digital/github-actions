# Manage Services Action

Manages services (stop/restart) based on project type and hosting provider using proven patterns.

## Features

- **Project-Type Aware**: Different service management for Shopware/Symfony vs Laravel
- **Multi-Provider Support**: Level27, Byte, Hipex, HostedPower, and generic
- **Service Detection**: Handles messenger workers, queue workers, and PHP services
- **Provider-Specific Commands**: Uses the correct commands for each hosting provider

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

## Actions

### Stop Services
Stops framework-specific background services:

**Shopware/Symfony:**
- Stops messenger workers (`systemctl --user stop worker-{id}.service`)
- Falls back to `pkill -f 'messenger:consume'`

**Laravel:**
- Stops queue workers (`pkill -f 'queue:work'`)

### Restart Services
Restarts services based on hosting provider:

## Hosting Providers

### Level27
```bash
sudo /usr/sbin/service php8.1-fpm reload
# For Shopware/Symfony: restart messenger workers
systemctl --user start worker-{id}.service
```

### Byte
```bash
hypernode-servicectl restart php-fpm
```

### Hipex
```bash
hipex restart:phpfpm php-fpm
```

### HostedPower
```bash
tscli opcache clear
```

### Generic
```bash
sudo systemctl reload php-service
```

## Examples

### Stop Services Before Deployment
```yaml
- name: Stop services
  uses: ./actions/manage-services
  with:
    action: stop
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    project_type: 'shopware'
    provider: 'level27'
    php_service: 'php8.1-fpm'
    messenger_worker_id: '1'
```

### Restart Services After Deployment
```yaml
- name: Restart services
  uses: ./actions/manage-services
  with:
    action: restart
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    project_type: 'shopware'
    provider: 'level27'
    php_service: 'php8.1-fpm'
    messenger_worker_id: '1'
```

### Laravel with Generic Provider
```yaml
- name: Restart services
  uses: ./actions/manage-services
  with:
    action: restart
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    project_type: 'laravel'
    provider: 'generic'
    php_service: 'php8.1-fpm'
```

## Service Management Logic

### Stop Action
1. **Shopware/Symfony**: Stop messenger workers
2. **Laravel**: Stop queue workers
3. **All**: No PHP service stopping (handled by restart)

### Restart Action
1. **Provider-Specific**: Use provider-specific PHP service restart
2. **Shopware/Symfony**: Restart messenger workers (Level27 only)
3. **Error Handling**: Continue on service restart failures

## Error Handling

- Commands continue on failure with warning messages
- Service management failures don't stop deployment
- Clear error messages for troubleshooting