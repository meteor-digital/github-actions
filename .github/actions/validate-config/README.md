# Validate Configuration Action

This action validates CI/CD configuration files against JSON schemas and checks for required fields and proper formatting.

## Description

The action performs comprehensive validation of your pipeline configuration files:
- **YAML syntax validation**: Ensures files are valid YAML
- **JSON schema validation**: Validates against predefined schemas
- **Required field validation**: Checks for mandatory configuration fields
- **Content validation**: Validates field values and formats
- **Change detection**: Optionally validates only changed files (for PR checks)

This helps catch configuration errors early and ensures consistent setup across projects.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_directory` | Directory containing configuration files | No | `.github` |
| `fail_on_missing` | Fail if required configuration files are missing | No | `true` |
| `validate_schemas` | Validate against JSON schemas (requires ajv-cli) | No | `true` |
| `check_changed_only` | Only validate if config files have changed (for PR checks) | No | `false` |

## Outputs

| Output | Description | Values |
|--------|-------------|--------|
| `validation_result` | Overall validation result | `success`, `warning`, `error`, `skipped` |

## Validation Checks

### 1. File Existence
Checks for required configuration files:
- `.github/pipeline-config.yml` (required)

### 2. YAML Syntax
Validates that all configuration files contain valid YAML syntax using `yq`.

### 3. JSON Schema Validation
Validates configuration files against their respective JSON schemas:
- `pipeline-config.yml` → `pipeline-config.schema.json`

### 4. Required Fields
Validates that required fields are present and properly formatted:

#### Pipeline Configuration
- `project.name`: Project name (string, 2-50 characters)
- `runtime.php_version`: PHP version (format: X.Y, e.g., "8.1")
- `deployment.environments`: At least one environment defined
- `deployment.hosting.provider`: Valid hosting provider

#### Hosting Provider Validation
Ensures hosting provider is one of:
- `level27`
- `byte`
- `hipex`
- `hostedpower`
- `generic`

### 5. Content Validation
Validates field values and formats:
- PHP version format (X.Y pattern)
- Project name format (alphanumeric with hyphens/underscores)
- Environment configuration completeness

## Usage

### Basic Validation

```yaml
- name: Validate configuration
  uses: meteor-digital/github-actions/.github/actions/validate-config@main
```

### Custom Configuration Directory

```yaml
- name: Validate configuration
  uses: meteor-digital/github-actions/.github/actions/validate-config@main
  with:
    config_directory: 'custom/config'
```

### PR Validation (Changed Files Only)

```yaml
- name: Validate changed configuration
  uses: meteor-digital/github-actions/.github/actions/validate-config@main
  with:
    check_changed_only: 'true'
```

### Lenient Validation (Warnings Only)

```yaml
- name: Validate configuration
  uses: meteor-digital/github-actions/.github/actions/validate-config@main
  with:
    fail_on_missing: 'false'
    validate_schemas: 'false'
```

## Complete Workflow Examples

### PR Validation Workflow

```yaml
name: Validate Configuration

on:
  pull_request:
    paths:
      - '.github/*.yml'
      - '.github/*.yaml'

jobs:
  validate:
    name: Validate Configuration Files
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Validate configuration files
        uses: meteor-digital/github-actions/.github/actions/validate-config@main
        with:
          check_changed_only: 'true'
          fail_on_missing: 'true'
          validate_schemas: 'true'
```

### Full Validation Workflow

```yaml
name: Configuration Audit

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  workflow_dispatch:

jobs:
  audit:
    name: Audit All Configuration
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Validate all configuration files
        uses: meteor-digital/github-actions/.github/actions/validate-config@main
        with:
          config_directory: '.github'
          fail_on_missing: 'true'
          validate_schemas: 'true'
          check_changed_only: 'false'
```

### Integration with Other Actions

```yaml
jobs:
  validate-and-build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Validate configuration
        id: validate
        uses: meteor-digital/github-actions/.github/actions/validate-config@main
        
      - name: Build project
        if: steps.validate.outputs.validation_result == 'success'
        run: |
          echo "Configuration is valid, proceeding with build..."
          # Build commands here
          
      - name: Handle validation warnings
        if: steps.validate.outputs.validation_result == 'warning'
        run: |
          echo "⚠️ Configuration has warnings but build can proceed"
          # Optional: Send notification about warnings
```

## Validation Results

### Success
- All required files exist
- All files have valid YAML syntax
- All files pass schema validation
- All required fields are present and valid

### Warning
- Some optional validations failed (e.g., schema validation disabled)
- Non-critical issues found
- Missing files when `fail_on_missing` is false

### Error
- Required files are missing (when `fail_on_missing` is true)
- Invalid YAML syntax
- Schema validation failures
- Missing required fields
- Invalid field values

### Skipped
- No configuration files changed (when `check_changed_only` is true)

## Dependencies

### Required Tools
The action automatically installs required tools if not available:

- **yq**: For YAML parsing and validation
- **ajv-cli**: For JSON schema validation (if `validate_schemas` is true)

### Installation Commands
If you need to install tools manually:

```bash
# Install yq
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# Install ajv-cli
npm install -g ajv-cli
```

## Troubleshooting

### Common Issues

#### Schema Validation Fails
**Problem**: Configuration fails schema validation.

**Solutions**:
1. Check the JSON schema file exists in `schemas/` directory
2. Validate your configuration manually:
   ```bash
   ajv validate -s schemas/pipeline-config.schema.json -d .github/pipeline-config.yml
   ```
3. Review schema requirements and fix configuration

#### Missing Required Fields
**Problem**: Validation fails due to missing required fields.

**Solutions**:
1. Add missing fields to your configuration:
   ```yaml
   project:
     name: "my-project"  # Required
   runtime:
     php_version: "8.1"  # Required
   ```
2. Check field names for typos
3. Ensure proper YAML indentation

#### Invalid YAML Syntax
**Problem**: YAML syntax validation fails.

**Solutions**:
1. Check YAML syntax using online validators
2. Verify proper indentation (use spaces, not tabs)
3. Ensure proper quoting of string values
4. Check for special characters that need escaping

#### Tool Installation Fails
**Problem**: Cannot install yq or ajv-cli.

**Solutions**:
1. Check internet connectivity in GitHub Actions
2. Use pre-installed tools if available
3. Disable schema validation if ajv-cli installation fails:
   ```yaml
   with:
     validate_schemas: 'false'
   ```

### Debugging

Enable debug output to see detailed validation steps:

```yaml
- name: Validate configuration
  uses: meteor-digital/github-actions/.github/actions/validate-config@main
  env:
    ACTIONS_STEP_DEBUG: true
```

## Integration with IDE

### VS Code Schema Validation

Add schema references to your configuration files for IDE validation:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/meteor-digital/github-actions/main/schemas/pipeline-config.schema.json

project:
  name: "my-project"
  # ... rest of configuration
```

### Pre-commit Hooks

Add validation to pre-commit hooks:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: validate-config
        name: Validate CI/CD Configuration
        entry: ./scripts/validate-config.sh
        language: script
        files: '^\.github/.*\.ya?ml$'
```

## Security Considerations

- The action only reads configuration files from the specified directory
- No sensitive information is exposed in validation output
- Schema validation helps prevent configuration injection attacks
- All tools are installed from official sources with integrity checks