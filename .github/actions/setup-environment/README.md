# Setup Environment Action

This composite action sets up PHP, Node.js, and installs dependencies with caching for CI/CD workflows. It supports automatic project type detection and framework-specific configurations.

## Features

- 🐘 **PHP Setup**: Configurable PHP version and extensions
- 🟢 **Node.js Setup**: Configurable Node.js version with NPM caching
- 📦 **Dependency Management**: Composer and NPM installation with intelligent caching
- 🎯 **Auto-Detection**: Automatic project type detection (Shopware, Laravel, Symfony)
- ⚙️ **Configuration-Driven**: YAML-based configuration (no fallback defaults)
- 🔧 **Framework-Specific**: Tailored setup for different project types
- 🔐 **Authentication**: Supports Composer authentication for private repositories
- 💾 **Smart Caching**: Early cache restore/save strategy for optimal performance

## Usage

```yaml
- name: Setup Environment
  uses: ./actions/setup-environment
  with:
    config_file: '.github/pipeline-config.yml'     # Optional, defaults to .github/pipeline-config.yml
    composer_with_dev: 'yes'                       # Optional, defaults to 'yes'
    composer_auth: '${{ secrets.COMPOSER_AUTH }}'  # Optional, for private repositories
    node_skip_setup: 'false'                       # Optional, defaults to 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `composer_with_dev` | Install dev dependencies (yes/no) | No | `yes` |
| `composer_auth` | Composer authentication JSON | No | `{}` |
| `node_skip_setup` | Whether to skip Node.js setup | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `php_version` | PHP version that was configured |
| `node_version` | Node.js version that was configured |
| `project_type` | Detected project type (shopware, laravel, symfony) |
| `cache_hit` | Whether dependencies were restored from cache |

## Configuration File Format

The action reads configuration from the unified pipeline configuration file:

```yaml
# .github/pipeline-config.yml
project:
  name: "my-project"
  
runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache, redis, mysql"
  
# Other sections (build, quality_checks, deployment, etc.) are ignored by this action
```

### Required Configuration Fields

- `runtime.php_version`: PHP version (e.g., "8.1", "8.2", "8.3")
- `runtime.node_version`: Node.js version (e.g., "16", "18", "20")
- `runtime.php_extensions`: Comma-separated list of PHP extensions (optional, has sensible defaults)

## Project Type Auto-Detection

The action uses the `detect-project-type` action to automatically detect project types based on file presence:

1. **Shopware**: `.shopware-project.yml` exists
2. **Laravel**: `artisan` file exists  
3. **Symfony**: `symfony.lock` exists
4. **Generic**: Default fallback for other project types

The detected project type is used for framework-specific environment validation and setup.

## Implementation Details

### Dependency Installation Strategy

The action uses a sophisticated caching and installation strategy:

1. **Cache Key Generation**: Creates cache keys based on `composer.json`, `composer.lock`, `package.json`, and `package-lock.json` hashes
2. **Early Cache Restore**: Uses `actions/cache/restore@v4` to restore dependencies before installation
3. **Conditional Installation**: Only installs dependencies if cache miss occurs
4. **Composer Setup**: Uses the dedicated `composer-setup` action for Composer dependency installation
5. **Cache Save**: Saves cache after successful installation for future runs

### PHP Extensions

Default PHP extensions are provided by the `parse-pipeline-config` action. You can override them in your configuration:

```yaml
runtime:
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache, redis, mysql, pdo_mysql"
```

## Caching Strategy

The action implements a sophisticated caching strategy for optimal performance:

### Dependency Cache
- **Combined Cache**: Single cache for `vendor/`, `node_modules/`, `~/.composer/cache/`, `~/.npm/`
- **Smart Key Generation**: Cache keys based on dependency file hashes and dev/production mode
- **Early Restore**: Uses `actions/cache/restore@v4` to make dependencies available immediately
- **Conditional Save**: Only saves cache after successful installation on cache miss
- **Development Mode Support**: Separate cache keys for dev vs production dependencies

### Node.js Cache
- **Built-in Caching**: Uses `actions/setup-node@v4` built-in NPM caching
- **Lock File Support**: Automatically detects and uses `package-lock.json`
- **Global Cache**: Caches `~/.npm` directory for faster subsequent installs

### Cache Key Format
```
deps-{composer-hash}-{node-hash}[-nodev]
```
- `composer-hash`: Hash of `composer.json` and `composer.lock`
- `node-hash`: Hash of `package.json` and `package-lock.json`
- `-nodev`: Suffix added when `composer_with_dev` is "no"

## Framework-Specific Setup

After installing dependencies, the action performs framework-specific validation:

### Shopware Projects
- Verifies `.shopware-project.yml` exists
- Checks for required directories: `config/`, `public/`, `src/`
- Prepares environment for Shopware CLI usage (installed by build-project action)

### Laravel Projects  
- Verifies `artisan` file exists
- Checks for required directories: `app/`, `config/`, `resources/`
- Validates Laravel project structure

### Symfony Projects
- Verifies `symfony.lock` file exists
- Checks for required directories: `src/`, `config/`
- Validates `bin/console` exists

### Generic Projects
- Performs basic validation only
- No framework-specific requirements

## Error Handling

The action includes comprehensive error handling:

- **Configuration Validation**: Uses `parse-pipeline-config` action for robust configuration parsing
- **Dependency Validation**: Handled by the `composer-setup` action
- **Clear Logging**: Provides detailed output with emojis for easy scanning
- **Graceful Degradation**: Continues with warnings for non-critical issues
- **Framework Validation**: Warns about missing expected files/directories

## Examples

### Basic Usage
```yaml
- name: Setup Environment
  uses: ./actions/setup-environment
```

### Custom Configuration
```yaml
- name: Setup Environment
  uses: ./actions/setup-environment
  with:
    config_file: 'custom/pipeline-config.yml'
    composer_with_dev: 'no'
    composer_auth: '${{ secrets.COMPOSER_AUTH }}'
```

### PHP-Only Setup (Skip Node.js)
```yaml
- name: Setup PHP Environment Only
  uses: ./actions/setup-environment
  with:
    node_skip_setup: 'true'
```

### Using Outputs
```yaml
- name: Setup Environment
  id: setup
  uses: meteor-digital/github-actions/.github/actions/setup-environment@main

- name: Display Setup Info
  run: |
    echo "PHP Version: ${{ steps.setup.outputs.php_version }}"
    echo "Node Version: ${{ steps.setup.outputs.node_version }}"
    echo "Project Type: ${{ steps.setup.outputs.project_type }}"
    
    if [ "${{ steps.setup.outputs.cache_hit }}" = "true" ]; then
      echo "✅ Dependencies restored from cache"
    else
      echo "📦 Dependencies installed fresh"
    fi
```

### Complete Workflow Example
```yaml
name: Build Project

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Environment
        id: setup
        uses: meteor-digital/github-actions/.github/actions/setup-environment@main
        with:
          config_file: '.github/pipeline-config.yml'
          composer_with_dev: 'no'
          composer_auth: '${{ secrets.COMPOSER_AUTH }}'
          
      - name: Build project
        run: |
          echo "Building ${{ steps.setup.outputs.project_type }} project..."
          # Build commands here
```

## Dependencies

This action depends on several other actions:
- `meteor-digital/github-actions/.github/actions/detect-project-type@main`
- `meteor-digital/github-actions/.github/actions/parse-pipeline-config@main`
- `meteor-digital/github-actions/.github/actions/composer-setup@main`
- `shivammathur/setup-php@v2`
- `actions/setup-node@v4`
- `actions/cache/restore@v4` and `actions/cache/save@v4`

## Requirements

- GitHub Actions runner with bash support
- Internet access for downloading PHP, Node.js, and dependencies
- Valid `pipeline-config.yml` with required runtime configuration
- Valid `composer.json` (if project uses Composer)
- Valid `package.json` (if project uses NPM)
