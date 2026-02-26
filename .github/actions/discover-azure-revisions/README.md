# Discover Azure Revisions Action

Discovers the new and old revisions of an Azure Container App for blue-green deployment workflows.

## Usage

```yaml
- name: Discover revisions
  id: revisions
  uses: meteor-digital/github-actions/.github/actions/discover-azure-revisions@main
  with:
    app_name: 'my-container-app'
    resource_group: 'my-resource-group'
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `app_name` | Azure Container App name | Yes |
| `resource_group` | Azure resource group | Yes |

## Outputs

| Output | Description |
|--------|-------------|
| `new_revision` | Name of the newly deployed revision (latest, not receiving traffic) |
| `old_revision` | Name of the currently active revision (receiving traffic) |

## How It Works

1. Lists all revisions for the container app
2. Identifies the **new revision**: Latest revision by creation time that is NOT active
3. Identifies the **old revision**: Currently active revision receiving traffic
4. Outputs both revision names for use in subsequent deployment steps

## Example Output

```
new_revision: my-app--abc123
old_revision: my-app--xyz789
```

## Use Cases

- Blue-green deployment workflows
- Running commands on specific revisions before traffic switch
- Traffic management between revisions
- Rollback operations

## Related Actions

- **`deploy-to-azure`**: Uses this action to discover revisions
- **`run-command-on-azure-container`**: Executes commands on discovered revisions
- **`switch-azure-traffic`**: Switches traffic between discovered revisions
