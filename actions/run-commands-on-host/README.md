# Run Commands on Host Action

Executes a list of commands on a remote host via SSH with configurable error handling.

## Features

- **Multi-Command Support**: Runs multiple commands in sequence
- **Error Handling**: Configurable fail-on-error behavior
- **Working Directory**: Executes commands in specified directory
- **Logging**: Clear command execution logging

## Usage

```yaml
- name: Run database migrations
  uses: ./actions/run-commands-on-host
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: |
      bin/console database:migrate --all
      bin/console cache:clear
    description: 'database migrations'
    fail_on_error: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `working_directory` | Working directory for commands | Yes | - |
| `commands` | Commands to run (newline separated) | Yes | - |
| `description` | Description for logging | No | `commands` |
| `fail_on_error` | Whether to fail on command error | No | `true` |

## Command Format

Commands should be provided as a newline-separated string:

```yaml
commands: |
  bin/console cache:warmup
  bin/console theme:compile --active-only
  bin/console scheduled-task:register
```

## Error Handling

### Fail on Error (default)
```yaml
fail_on_error: 'true'  # Stops execution on first failed command
```

### Continue on Error
```yaml
fail_on_error: 'false'  # Logs errors but continues with remaining commands
```

## Examples

### Pre-deployment Commands
```yaml
- name: Run pre-deployment commands
  uses: ./actions/run-commands-on-host
  with:
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/releases/20231215.1430'
    commands: |
      bin/console cache:warmup --no-optional-warmers
      bin/console plugin:refresh
    description: 'pre-deployment commands'
```

### Maintenance Mode
```yaml
- name: Enable maintenance mode
  uses: ./actions/run-commands-on-host
  with:
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: 'bin/console sales-channel:maintenance:enable --all'
    description: 'maintenance mode (enable)'
```

### Post-deployment with Error Tolerance
```yaml
- name: Run post-deployment commands
  uses: ./actions/run-commands-on-host
  with:
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: |
      bin/console theme:compile --active-only
      bin/console scheduled-task:register
      bin/console dal:refresh:index
    description: 'post-deployment commands'
    fail_on_error: 'false'  # Continue even if some commands fail
```

## Security

- Requires SSH agent to be configured (use setup-deployment action first)
- Commands are executed in the specified working directory
- SSH connection uses strict host key checking