# Switch Azure Traffic Action

Switches traffic to a new Azure Container App revision and optionally deactivates the old revision.

## Usage

```yaml
- name: Activate new revision
  uses: meteor-digital/github-actions/.github/actions/switch-azure-traffic@main
  with:
    app_name: 'my-container-app'
    resource_group: 'my-resource-group'
    new_revision: 'my-app--abc123'
    old_revision: 'my-app--xyz789'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `app_name` | Azure Container App name | Yes | - |
| `resource_group` | Azure resource group | Yes | - |
| `new_revision` | Revision to route 100% traffic to | Yes | - |
| `old_revision` | Previous revision to deactivate | No | `''` |

## Features

- **Atomic Traffic Switch**: Switches 100% traffic to new revision in one operation
- **Automatic Deactivation**: Optionally deactivates old revision to save resources
- **Rollback Support**: Deactivated revisions can be reactivated for rollback
- **Safe Defaults**: Skips deactivation if old revision is same as new or empty

## How It Works

1. **Traffic Switch**: Routes 100% traffic to the new revision
2. **Deactivation** (optional): Deactivates the old revision if:
   - `old_revision` is provided
   - `old_revision` is different from `new_revision`

## Deactivation Behavior

When a revision is deactivated:
- ✅ Containers are **stopped** (saves compute costs)
- ✅ Revision definition is **preserved** (can be reactivated)
- ✅ Can be **reactivated** anytime for rollback
- ❌ Not receiving any traffic

## Rollback Process

To rollback to a deactivated revision:

```bash
# 1. Reactivate the old revision
az containerapp revision activate \
  --name <app-name> \
  --resource-group <resource-group> \
  --revision <old-revision-name>

# 2. Switch traffic back
az containerapp ingress traffic set \
  --name <app-name> \
  --resource-group <resource-group> \
  --revision-weight <old-revision-name>=100
```

## Example

```yaml
- name: Switch to new revision
  uses: meteor-digital/github-actions/.github/actions/switch-azure-traffic@main
  with:
    app_name: ${{ env.APP_NAME }}
    resource_group: ${{ env.RESOURCE_GROUP }}
    new_revision: ${{ steps.revisions.outputs.new_revision }}
    old_revision: ${{ steps.revisions.outputs.old_revision }}  # Optional
```

## Use Cases

- Blue-green deployment traffic switching
- Canary deployments (manual traffic percentage control)
- A/B testing between revisions
- Rollback to previous revision

## Related Actions

- **`deploy-to-azure`**: Uses this action to switch traffic after migrations
- **`discover-azure-revisions`**: Provides revision names for traffic switching
- **`cleanup-azure-revisions`**: Cleans up old deactivated revisions
