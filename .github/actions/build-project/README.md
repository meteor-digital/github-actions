# Build Project Action

This composite action builds projects using framework-specific commands and configurations. It supports auto-detection of project types and configurable build processes.

## Features

- **Auto-detection**: Automatically detects project type (Shopware, Laravel, Symfony)
- **Shopware Support**: Uses official Shopware CLI and build-project-action for optimal builds
- **Laravel Support**: Runs npm build and artisan optimize
- **Symfony Support**: Runs npm build and console cache:warmup
- **Custom Commands**: Supports additional build commands from configuration
- **File Exclusion**: Removes specified files/patterns from build output
- **Build Metadata**: Creates comprehensive build-info.json with metadata

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |

## Project Type Detection

The action detects project types in the following priority order:

1. **Shopware**: `.shopware-project.yml` exists
2. **Laravel**: `artisan` file exists  
3. **Symfony**: `symfony.lock` exists
4. **Default**: Shopware (for backward compatibility)

## Configuration

The action reads build configuration from a YAML file (default: `.github/pipeline-config.yml`):

```yaml
project:
  name: "my-project"  # Used for metadata and artifacts

build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
    custom-exclude/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev"
```

## Framework-Specific Build Logic

### Shopware Projects

1. Uses `shopware/shopware-cli-action@v2` to install Shopware CLI
2. Uses `shopwareLabs/build-project-action@v1` for optimal Shopware builds
3. Enables experimental asset caching for improved performance

### Laravel Projects

1. Runs `npm run build` (if package.json exists)
2. Runs `php artisan optimize`

### Symfony Projects

1. Runs `npm run build` (if package.json exists)
2. Runs `bin/console cache:warmup --env=prod`

## Build Metadata

The action creates a `build-info.json` file with comprehensive build metadata:

```json
{
  "project_name": "my-project",
  "project_type": "shopware",
  "commit_sha": "abc123def456",
  "commit_ref": "refs/heads/main",
  "ref_name": "main",
  "ref_type": "branch",
  "build_timestamp": "2025-09-12T19:13:12Z",
  "workflow_run_id": "12345",
  "workflow_run_number": "42",
  "actor": "github-user",
  "repository": "org/repo",
  "event_name": "push"
}
```

## Usage Example

```yaml
- name: Build project
  uses: ./actions/build-project
  with:
    config_file: '.github/pipeline-config.yml'
```

## File Exclusion

The action removes files matching the exclude patterns. Default exclusions:

- `*.git*` - Git files and directories
- `node_modules/*` - Node.js dependencies
- `tests/*` - Test files

Custom exclusions can be specified in the configuration file.

## Error Handling

- Validates configuration file existence and format
- Provides fallback build logic if Shopware CLI is unavailable
- Uses safe file removal with find commands
- Continues on non-critical errors (e.g., file exclusion failures)
