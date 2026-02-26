# Run Command on Azure Container Action

Executes commands on a specific Azure Container App revision using `az containerapp exec`.

## Usage

```yaml
- name: Run database migrations
  uses: meteor-digital/github-actions/.github/actions/run-command-on-azure-container@main
  with:
    app_name: 'my-container-app'
    resource_group: 'my-resource-group'
    revision: 'my-app--abc123'
    commands: 'bin/console database:migrate --all'
    description: 'database migrations'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `app_name` | Azure Container App name | Yes | - |
| `resource_group` | Azure resource group | Yes | - |
| `revision` | Specific revision name to execute commands on | Yes | - |
| `commands` | Commands to execute (newline separated for multiple) | Yes | - |
| `description` | Description of the commands for logging | No | `commands` |
| `fail_on_error` | Whether to fail the step if command fails | No | `true` |

## Features

- **Multi-line Commands**: Supports multiple commands separated by newlines
- **Error Handling**: Configurable failure behavior
- **Detailed Logging**: Shows command execution progress and output
- **Revision-Specific**: Targets specific revision for blue-green deployments

## Examples

```yaml
# Single command
- name: Enable maintenance mode
  uses: meteor-digital/github-actions/.github/actions/run-command-on-azure-container@main
  with:
    app_name: ${{ env.APP_NAME }}
    resource_group: ${{ env.RESOURCE_GROUP }}
    revision: ${{ steps.revisions.outputs.new_revision }}
    commands: 'bin/console sales-channel:maintenance:enable --all'
    description: 'maintenance mode (enable)'

# Multiple commands
- name: Run post-deployment commands
  uses: meteor-digital/github-actions/.github/actions/run-command-on-azure-container@main
  with:
    app_name: ${{ env.APP_NAME }}
    resource_group: ${{ env.RESOURCE_GROUP }}
    revision: ${{ steps.revisions.outputs.new_revision }}
    commands: |
      bin/console theme:dump
      bin/console theme:compile
    description: 'post-deployment commands'
    fail_on_error: 'false'  # Optional
```

## Use Cases

- Running database migrations on new revision before traffic switch
- Enabling/disabling maintenance mode
- Executing framework-specific commands (cache warmup, theme compilation)
- Running health checks or smoke tests
- Clearing caches or temporary files

## Related Actions

- **`deploy-to-azure`**: Uses this action for maintenance, migrations, and post-deploy commands
- **`discover-azure-revisions`**: Provides revision names for targeting
