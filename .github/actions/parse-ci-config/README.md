# Read Configuration Action

This shared composite action reads and parses CI configuration from YAML files. It's used by multiple other actions to avoid code duplication.

## Features

- **YAML Parsing**: Supports both `yq` and fallback grep/sed parsing
- **Default Values**: Provides sensible defaults when configuration is missing
- **Multiple Outputs**: Extracts project, runtime, and build configuration
- **Error Handling**: Graceful handling of missing or malformed configuration

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to CI configuration file | No | `.github/ci-config.yml` |

## Outputs

| Output | Description |
|--------|-------------|
| `project_name` | Project name from configuration (defaults to repository name) |
| `php_version` | PHP version from runtime configuration |
| `node_version` | Node.js version from runtime configuration |
| `php_extensions` | PHP extensions from runtime configuration |
| `build_commands` | Build commands from build configuration |
| `exclude_patterns` | File exclusion patterns from build configuration |

## Configuration Format

The action reads configuration from a YAML file with the following structure:

```yaml
project:
  name: "my-project"

runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache"

build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev"
```

## Usage Example

```yaml
- name: Read configuration
  id: config
  uses: ./actions/parse-ci-config
  with:
    config_file: '.github/ci-config.yml'

- name: Use configuration
  run: |
    echo "Project: ${{ steps.config.outputs.project_name }}"
    echo "PHP: ${{ steps.config.outputs.php_version }}"
    echo "Node: ${{ steps.config.outputs.node_version }}"
```

## Used By

This action is used by:
- `setup-environment` - For runtime configuration
- `build-project` - For build and project configuration
- Other actions that need configuration data

## Error Handling

- Missing configuration files are handled gracefully with defaults
- Invalid YAML syntax falls back to grep/sed parsing
- Empty or null values use sensible defaults
- Comprehensive logging for debugging configuration issues