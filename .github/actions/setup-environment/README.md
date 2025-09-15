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

## Usage

```yaml
- name: Setup Environment
  uses: ./actions/setup-environment
  with:
    config_file: '.github/ci-config.yml'           # Optional, defaults to .github/ci-config.yml
    composer_with_dev: 'yes'                       # Optional, defaults to 'yes'
    composer_auth: '${{ secrets.COMPOSER_AUTH }}'  # Optional, for private repositories
    node_skip_setup: 'false'                       # Optional, defaults to 'false'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to CI configuration file | No | `.github/ci-config.yml` |
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

The action reads configuration from a YAML file with the following structure:

```yaml
project:
  name: "my-project"
  
runtime:
  php_version: "8.1"
  node_version: "18"
  php_extensions: "mbstring, intl, gd, xml, zip, curl, opcache, redis, mysql"
  
build:
  exclude_patterns: |
    *.git*
    node_modules/*
    tests/*
  build_commands:
    - "npm run build"
    - "composer install --no-dev"
  
artifacts:
  retention_days: 7
  naming_pattern: "{environment}-build-{version}"
```

## Project Type Auto-Detection

The action automatically detects project types based on file presence:

1. **Shopware**: `shopware-project.yml` exists
2. **Laravel**: `artisan` file exists  
3. **Symfony**: `symfony.lock` exists
4. **Default**: Shopware (for backward compatibility)

## Configuration Requirements

### Required Configuration
All projects must specify:
- `runtime.php_version`: PHP version (e.g., "8.1", "8.2")
- `runtime.node_version`: Node.js version (e.g., "18", "20")
- `runtime.php_extensions`: PHP extensions (e.g., "mbstring, intl, gd, xml, zip, curl, opcache")

## Caching Strategy

The action implements intelligent caching for optimal performance:

### Early Cache Strategy
- **Combined Cache**: Single cache for vendor, node_modules, ~/.composer/cache, ~/.npm
- **Early Restore**: Uses `actions/cache/restore@v4` to make cache available immediately
- **Early Save**: Uses `actions/cache/save@v4` after installation
- **Benefit**: Dependencies available to subsequent tools (like Shopware CLI) in the same job

### NPM Cache
- **Built-in**: Uses `actions/setup-node@v4` built-in caching
- **Lock Files**: Supports `package-lock.json` and `npm-shrinkwrap.json`
- **Strategy**: Prefers `npm ci` for reproducible builds when lock files exist

## Error Handling

The action includes comprehensive error handling:

- **Configuration Validation**: Fails fast if required configuration is missing
- **Clear Error Messages**: Provides helpful guidance when configuration is invalid
- **Dependency Validation**: Validates `composer.json` before installation
- **Clear Logging**: Provides detailed output for debugging
- **Graceful Skipping**: Skips installation if dependency files don't exist

## YAML Parsing

The action supports two parsing methods:

1. **yq** (preferred): If `yq` is available, uses it for robust YAML parsing
2. **grep/sed** (fallback): Uses shell tools for basic YAML parsing when `yq` is unavailable

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
    config_file: 'custom/ci-config.yml'
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
  uses: ./actions/setup-environment

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

## Requirements

- GitHub Actions runner with bash support
- Internet access for downloading PHP, Node.js, and dependencies
- Valid `composer.json` (if using Composer)
- Valid `package.json` (if using NPM)

## Compatibility

- ✅ **Operating Systems**: Linux, macOS, Windows
- ✅ **PHP Versions**: 7.4+ (configurable)
- ✅ **Node.js Versions**: 14+ (configurable)
- ✅ **Project Types**: Shopware, Laravel, Symfony, Generic