# Run Commands on Host Action

Executes commands on a remote host via SSH with configurable error handling.

## Usage

```yaml
- name: Run database migrations
  uses: meteor-digital/github-actions/.github/actions/run-commands-on-host@main
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: |
      bin/console database:migrate --all
      bin/console cache:clear
    description: 'database migrations'
    fail_on_error: 'true'  # Optional, defaults to true
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
| `fail_on_error` | Stop on first error | No | `true` |

## Examples

```yaml
# Single command
- name: Enable maintenance mode
  uses: meteor-digital/github-actions/.github/actions/run-commands-on-host@main
  with:
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: 'bin/console sales-channel:maintenance:enable --all'
    description: 'maintenance mode (enable)'

# Multiple commands with error tolerance
- name: Run post-deployment commands
  uses: meteor-digital/github-actions/.github/actions/run-commands-on-host@main
  with:
    host: ${{ vars.HOST }}
    ssh_port: '22'
    ssh_user: 'deploy'
    working_directory: '/var/www/app/current'
    commands: |
      bin/console theme:compile
      bin/console scheduled-task:register
    description: 'post-deployment commands'
    fail_on_error: 'false'
```

## Related Actions

- **`deploy-to-host`**: Uses this action for migrations and deployment commands
- **`run-command-on-azure-container`**: Azure equivalent for container commands