# Cleanup Azure Revisions Action

Cleans up old inactive Azure Container App revisions while keeping a configurable number for rollback.

## Usage

```yaml
- name: Cleanup old revisions
  uses: meteor-digital/github-actions/.github/actions/cleanup-azure-revisions@main
  with:
    app_name: 'my-container-app'
    resource_group: 'my-resource-group'
    keep_revisions: '3'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `app_name` | Azure Container App name | Yes | - |
| `resource_group` | Azure resource group | Yes | - |
| `keep_revisions` | Number of inactive revisions to keep | No | `3` |

## Features

- **Automatic Cleanup**: Removes old inactive revisions to prevent accumulation
- **Rollback Safety**: Keeps last N revisions for quick rollback
- **Cost Optimization**: Deactivated revisions don't consume compute, but cleanup prevents storage bloat
- **Safe Deletion**: Only deletes inactive revisions (never touches active revision)

## How It Works

1. Lists all inactive revisions sorted by creation time (oldest first)
2. Counts total inactive revisions
3. If count > `keep_revisions`:
   - Calculates how many to delete
   - Deletes oldest revisions
   - Keeps the most recent N revisions

## Retention Strategy

**Default**: Keep last 3 inactive revisions

This provides:
- ✅ Quick rollback to recent deployments
- ✅ Multiple rollback points for safety
- ✅ Prevents unlimited revision accumulation
- ✅ Balances safety with resource management

## Example

```yaml
- name: Cleanup old revisions
  uses: meteor-digital/github-actions/.github/actions/cleanup-azure-revisions@main
  with:
    app_name: ${{ env.APP_NAME }}
    resource_group: ${{ env.RESOURCE_GROUP }}
    keep_revisions: '3'  # Optional, defaults to 3
```

## Cleanup Behavior

**Before cleanup** (7 inactive revisions):
```
my-app--rev1  (inactive, oldest)
my-app--rev2  (inactive)
my-app--rev3  (inactive)
my-app--rev4  (inactive)
my-app--rev5  (inactive)
my-app--rev6  (inactive)
my-app--rev7  (inactive, newest)
my-app--rev8  (active) ← never deleted
```

**After cleanup** (keep_revisions: 3):
```
my-app--rev5  (inactive)
my-app--rev6  (inactive)
my-app--rev7  (inactive, newest)
my-app--rev8  (active) ← never deleted
```

## Use Cases

- Preventing unlimited revision accumulation
- Maintaining rollback capability while managing resources
- Automated cleanup in CI/CD pipelines
- Cost optimization for Azure Container Apps

## Related Actions

- **`deploy-to-azure`**: Uses this action after successful deployment
- **`switch-azure-traffic`**: Deactivates old revisions that will be cleaned up later
