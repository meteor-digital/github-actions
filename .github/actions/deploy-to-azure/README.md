# Deploy to Azure Container App Action

A production-ready GitHub Action for deploying applications to Azure Container Apps using blue-green revision strategy.

## Features

- **Multi-Framework Support**: Shopware, Laravel, Symfony with auto-detection
- **Blue-Green Deployments**: Zero-downtime deployments using Azure revision traffic switching
- **Maintenance Mode**: Framework-specific maintenance mode commands
- **Database Migrations**: Framework-specific migration commands
- **Pre/Post-Deployment Commands**: Configurable command execution
- **Automatic Cleanup**: Keeps last N inactive revisions for rollback
- **Failure Recovery**: Automatic cleanup on deployment failure

## Usage

```yaml
- name: Deploy to Azure Container App
  uses: meteor-digital/github-actions/.github/actions/deploy-to-azure@main
  with:
    app_name: ${{ needs.deploy-infra.outputs.shopwareAppName }}
    resource_group: ${{ needs.deploy-infra.outputs.shopwareAppResourceGroup }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `app_name` | Azure Container App name | Yes | - |
| `resource_group` | Azure resource group | Yes | - |

## Outputs

| Output | Description |
|--------|-------------|
| `deployment_status` | Status of the deployment (success, failed) |
| `new_revision` | Name of the newly deployed revision |
| `old_revision` | Name of the previously active revision |

## Prerequisites

- **Azure Container App** must be already deployed (via Bicep/Terraform)
- **Multi-revision mode** must be enabled in your Azure Container App configuration
- **Azure CLI** must be authenticated (`azure/login@v2`)
- **Repository** must be checked out (for config file access)

### Multi-Revision Configuration

For blue-green deployments to work, your Azure Container App must be configured with **multiple active revisions**. In your Bicep template:

```bicep
configuration: {
  activeRevisionsMode: 'Multiple'  // Required for blue-green
  ingress: {
    external: true
    targetPort: 8000
    traffic: [
      {
        latestRevision: true  // Initial deployment only
        weight: 100
      }
    ]
  }
}
```

**Important**: 
- ❌ **Single revision mode** (`latestRevision: true` only) will NOT work with this action
- ✅ **Multiple revision mode** allows traffic splitting and blue-green deployments
- The action will manage traffic switching between revisions automatically

## Deployment Process

The action follows this blue-green deployment process:

1. **Project Detection**: Auto-detect project type and load framework defaults
2. **Configuration Parsing**: Read deployment configuration for framework commands
3. **Revision Discovery**: Identify new (just deployed) and old (active) revisions
4. **Pre-deployment Commands**: Execute configured pre-deployment commands on new revision
5. **Maintenance Mode**: Enable maintenance mode on new revision
6. **Database Migration**: Run framework-specific migrations on new revision
7. **Post-deployment Commands**: Execute configured post-deployment commands on new revision
8. **Traffic Switch**: Switch 100% traffic from old to new revision
9. **Deactivate Old Revision**: Stop old revision containers
10. **Maintenance Mode**: Disable maintenance mode on new revision
11. **Cleanup**: Remove old inactive revisions (keeps last 3)
12. **Failure Handling**: On failure, disable maintenance and clear cache

## Framework Support

### Shopware
- **Migration Command**: `bin/console database:migrate --all && bin/console database:migrate --all {ProjectName}`
- **Maintenance Enable**: `bin/console sales-channel:maintenance:enable --all`
- **Maintenance Disable**: `bin/console sales-channel:maintenance:disable --all`
- **Pre-deploy**: `bin/console cache:warmup --no-optional-warmers`
- **Post-deploy**: Theme compilation, asset installation

### Laravel
- **Migration Command**: `php artisan migrate --force`
- **Maintenance Enable**: `php artisan down`
- **Maintenance Disable**: `php artisan up`
- **Post-deploy**: Config cache, route cache, view cache

### Symfony
- **Migration Command**: `bin/console doctrine:migrations:migrate --no-interaction`
- **Maintenance Enable**: Custom maintenance mode command
- **Maintenance Disable**: Custom maintenance mode command
- **Post-deploy**: Cache warmup

## Configuration

The action uses the same configuration system as `deploy-to-host`:

```yaml
# .github/pipeline-config.yml
# Framework-specific commands are automatically loaded
# No environment-specific configuration needed for Azure
```

Commands are determined by project type detection. No Azure-specific configuration is required in the config file.

## Revision Management

- **New Revision**: Created by Bicep deployment with new Docker image
- **Old Revision**: Currently active revision receiving traffic
- **Traffic Switch**: Atomic switch from old (100%) to new (100%)
- **Cleanup**: Keeps last 3 inactive revisions for rollback capability

## Rollback

To rollback to a previous revision:

```bash
# List revisions
az containerapp revision list \
  --name <app-name> \
  --resource-group <resource-group>

# Activate old revision
az containerapp revision activate \
  --name <app-name> \
  --resource-group <resource-group> \
  --revision <old-revision-name>

# Switch traffic
az containerapp ingress traffic set \
  --name <app-name> \
  --resource-group <resource-group> \
  --revision-weight <old-revision-name>=100
```

## Error Handling

The action includes comprehensive error handling:

- **Revision Discovery Failures**: Validates revisions exist before proceeding
- **Command Execution Failures**: Reports failures with detailed output
- **Traffic Switch Failures**: Maintains old revision if switch fails
- **Cleanup Failures**: Continues deployment even if cleanup fails

## Failure Recovery

On deployment failure, the action automatically:

1. Disables maintenance mode on new revision
2. Clears cache for Shopware/Symfony projects
3. Reports failure status
4. Does NOT rollback traffic (manual rollback required)

## Example

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

- name: Checkout repository
  uses: actions/checkout@v4

- name: Deploy to Azure
  uses: meteor-digital/github-actions/.github/actions/deploy-to-azure@main
  with:
    app_name: ${{ needs.deploy-infra.outputs.shopwareAppName }}
    resource_group: ${{ needs.deploy-infra.outputs.shopwareAppResourceGroup }}
```

## Related Actions

- **`discover-azure-revisions`**: Discovers new and old revisions
- **`run-command-on-azure-container`**: Executes commands on specific revision
- **`switch-azure-traffic`**: Switches traffic between revisions
- **`cleanup-azure-revisions`**: Cleans up old inactive revisions
