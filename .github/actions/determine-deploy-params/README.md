# Determine Deploy Parameters Action

Resolves deployment parameters (environment, version, artifact run ID) from either manual or automated deployment triggers.

## Usage

```yaml
- name: Determine deployment parameters
  id: params
  uses: meteor-digital/github-actions/.github/actions/determine-deploy-params@main
  with:
    event_name: ${{ github.event_name }}
    environment: ${{ inputs.environment }}  # For workflow_dispatch
    version: ${{ inputs.version }}  # Optional, defaults to latest release
    workflow_run_id: ${{ github.event.workflow_run.id }}  # For workflow_run
    workflow_run_branch: ${{ github.event.workflow_run.head_branch }}
    workflow_run_conclusion: ${{ github.event.workflow_run.conclusion }}
    artifact_name: ${{ steps.artifact_name.outputs.name }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `event_name` | GitHub event name (`workflow_dispatch` or `workflow_run`) | Yes | - |
| `environment` | Target environment (test, acc, prod) | No* | - |
| `version` | Branch/tag to deploy (manual only, defaults to latest release) | No | - |
| `artifact_workflow` | Artifact build workflow filename | No | `build-artifact.yml` |
| `workflow_run_id` | Run ID from workflow_run event | No* | - |
| `workflow_run_branch` | Branch from workflow_run event | No* | - |
| `workflow_run_conclusion` | Conclusion from workflow_run event | No* | - |
| `artifact_name` | Pre-resolved artifact name (automated only) | No* | - |

*Required depending on event type

## Outputs

| Output | Description |
|--------|-------------|
| `environment` | Resolved target environment |
| `version` | Resolved version/branch |
| `artifact_name` | Artifact name to download (automated only) |
| `artifact_run_id` | Run ID of the artifact build |
| `should_deploy` | Whether deployment should proceed (`true`/`false`) |

## How It Works

### Manual Deployment (`workflow_dispatch`)
1. Uses provided `environment` and `version` inputs
2. If no version specified, finds latest release
3. Searches for successful artifact build for that version
4. Returns artifact run ID to download from

### Automated Deployment (`workflow_run`)
1. Validates build was successful
2. Uses pre-resolved environment (from branch mapping)
3. Uses workflow_run metadata (branch, run ID, artifact name)
4. Returns parameters for deployment

## Use Cases

- Unified parameter resolution for manual and automated deployments
- Finding correct artifact build for a given version
- Validating deployment prerequisites before proceeding
- Used internally by deploy workflows

## Related Actions

- **`determine-artifact-name`**: Determines artifact name from branch/tag
- **`deploy-to-host`**: Uses resolved parameters for deployment
- **`deploy-to-azure`**: Uses resolved parameters for deployment
