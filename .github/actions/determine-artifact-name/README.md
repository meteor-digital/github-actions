# Determine Artifact Name Action

Determines artifact name and target environment based on Git reference (branch/tag).

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

```mermaid
flowchart TD
    Start([Git Reference]) --> TagCheck{Tag?}
    TagCheck -->|Yes| Tag["{project}-prod-build-{tag}<br/>env: prod<br/>version: {tag}"]
    TagCheck -->|No| ReleaseCheck{release/* branch?}
    ReleaseCheck -->|Yes| Release["{project}-acc-build-{version}<br/>env: acc<br/>version: extracted"]
    ReleaseCheck -->|No| TestCheck{test/* branch?}
    TestCheck -->|Yes| Test["{project}-test-build<br/>env: test<br/>version: empty"]
    TestCheck -->|No| Other["{project}-build-{branch}<br/>env: empty<br/>version: empty"]
    
    Tag --> End([Artifact Name])
    Release --> End
    Test --> End
    Other --> End
    
    style Tag fill:#e1f5e1
    style Release fill:#fff4e1
    style Test fill:#e1e5ff
    style Other fill:#f0f0f0
```

**Examples:**

| Git Reference | Artifact Name | Environment | Version |
|---------------|---------------|-------------|---------|
| `1.2.3` (tag) | `my-project-prod-build-1.2.3` | `prod` | `1.2.3` |
| `release/1.2.3` | `my-project-acc-build-1.2.3` | `acc` | `1.2.3` |
| `test/feature-x` | `my-project-test-build` | `test` | `` |
| `feature/new-ui` | `my-project-build-feature-new-ui` | `` | `` |

## Usage

```yaml
- name: Determine artifact name
  id: artifact
  uses: meteor-digital/github-actions/.github/actions/determine-artifact-name@main
  with:
    ref_name: ${{ github.ref_name }}
    ref_type: ${{ github.ref_type }}

# Upload artifact
- uses: actions/upload-artifact@v4
  with:
    name: ${{ steps.artifact.outputs.artifact_name }}
    path: build/
```

## Configuration

Project name is read from `.github/pipeline-config.yml`:

```yaml
project:
  name: "my-awesome-project"  # Used in artifact naming
```

## Related Actions

- **`determine-deploy-params`**: Uses artifact names to resolve deployment parameters
- **`parse-pipeline-config`**: Reads project configuration