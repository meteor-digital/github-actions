# Determine Artifact Name Action

This action determines the appropriate artifact name and target environment based on the Git reference (branch or tag) and project configuration.

## Description

The action analyzes the Git reference to determine:
- **Artifact name**: A standardized name for build artifacts
- **Target environment**: The deployment environment (test, acc, prod)
- **Version**: Extracted version number (for release branches and tags)

This ensures consistent artifact naming across all builds and deployments.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `ref_name` | Git reference name (branch or tag) | Yes | - |
| `ref_type` | Git reference type (`branch` or `tag`) | No | `branch` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `artifact_name` | Generated artifact name | `my-project-prod-build-1.2.3` |
| `environment` | Target environment | `prod`, `acc`, `test`, or empty |
| `version` | Extracted version number | `1.2.3` or empty |

## Artifact Naming Logic

The action follows these rules for artifact naming:

### 1. Tag Builds (Production)
- **Pattern**: `{project-name}-prod-build-{tag}`
- **Environment**: `prod`
- **Version**: Tag name
- **Example**: `my-project-prod-build-1.2.3`

### 2. Release Branch Builds (Acceptance)
- **Pattern**: `release/{version}` → `{project-name}-acc-build-{version}`
- **Environment**: `acc`
- **Version**: Extracted from branch name
- **Example**: `release/1.2.3` → `my-project-acc-build-1.2.3`

### 3. Test Branch Builds
- **Pattern**: `test/*` → `{project-name}-test-build`
- **Environment**: `test`
- **Version**: Empty
- **Example**: `test/feature-xyz` → `my-project-test-build`

### 4. Other Branches
- **Pattern**: `{project-name}-build-{sanitized-branch-name}`
- **Environment**: Empty
- **Version**: Empty
- **Example**: `feature/new-ui` → `my-project-build-feature-new-ui`

## Usage

### Basic Usage

```yaml
- name: Determine artifact name
  id: artifact
  uses: meteor-digital/github-actions/.github/actions/determine-artifact-name@main
  with:
    ref_name: ${{ github.ref_name }}
    ref_type: ${{ github.ref_type }}

- name: Use artifact name
  run: |
    echo "Artifact: ${{ steps.artifact.outputs.artifact_name }}"
    echo "Environment: ${{ steps.artifact.outputs.environment }}"
    echo "Version: ${{ steps.artifact.outputs.version }}"
```

### With Custom Configuration

```yaml
- name: Determine artifact name
  id: artifact
  uses: meteor-digital/github-actions/.github/actions/determine-artifact-name@main
  with:
    config_file: 'custom/pipeline-config.yml'
    ref_name: ${{ github.ref_name }}
    ref_type: ${{ github.ref_type }}
```

### In Build Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Determine artifact name
        id: artifact
        uses: meteor-digital/github-actions/.github/actions/determine-artifact-name@main
        with:
          ref_name: ${{ github.ref_name }}
          ref_type: ${{ github.ref_type }}
      
      - name: Build project
        run: |
          # Build commands here
          
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ steps.artifact.outputs.artifact_name }}
          path: build/
```

### In Deployment Workflow

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Determine artifact name
        id: artifact
        uses: meteor-digital/github-actions/.github/actions/determine-artifact-name@main
        with:
          ref_name: ${{ github.event.workflow_run.head_branch }}
          ref_type: 'branch'
      
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ steps.artifact.outputs.artifact_name }}
          path: ./artifact
      
      - name: Deploy to environment
        if: steps.artifact.outputs.environment != ''
        run: |
          echo "Deploying to ${{ steps.artifact.outputs.environment }}"
          # Deployment commands here
```

## Examples

### Example Outputs for Different References

| Git Reference | Artifact Name | Environment | Version |
|---------------|---------------|-------------|---------|
| `1.2.3` (tag) | `my-project-prod-build-1.2.3` | `prod` | `1.2.3` |
| `release/1.2.3` | `my-project-acc-build-1.2.3` | `acc` | `1.2.3` |
| `test/feature-x` | `my-project-test-build` | `test` | `` |
| `feature/new-ui` | `my-project-build-feature-new-ui` | `` | `` |
| `main` | `my-project-build-main` | `` | `` |

### Project Configuration

The action reads the project name from your pipeline configuration:

```yaml
# .github/pipeline-config.yml
project:
  name: "my-awesome-project"  # Used in artifact naming
```

## Integration with Other Actions

This action is commonly used with:

- **Build workflows**: To name build artifacts consistently
- **Deployment workflows**: To identify which artifact to deploy
- **Release workflows**: To determine version numbers and environments

## Branch Naming Conventions

For optimal results, follow these branch naming conventions:

- **Production releases**: Use semantic version tags (`1.2.3`, `2.0.0`)
- **Acceptance testing**: Use release branches (`release/1.2.3`)
- **Test environments**: Use test branches (`test/feature-name`, `test/bugfix-123`)
- **Development**: Use descriptive branch names (`feature/new-login`, `bugfix/header-issue`)

## Dependencies

This action depends on:
- `parse-pipeline-config` action for reading project configuration
- Bash shell for string processing and pattern matching

## Security Considerations

- The action only reads configuration files and Git references
- No sensitive information is exposed in outputs
- Artifact names are safe for use in file systems and URLs