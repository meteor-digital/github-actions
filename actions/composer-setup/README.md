# Composer Setup Action

This composite action installs Composer dependencies with an optimized caching strategy. It follows the same pattern as the LensOnline composer-setup action and is designed to be called by the setup-environment action.

## Features

- 📦 **Two-tier Caching**: Caches both vendor directory and Composer cache directory
- 🚀 **Performance**: Skips installation when dependencies are cached
- 🔧 **Flexible**: Supports both dev and production dependency installation
- 🎯 **Simple**: Focused solely on Composer dependency installation

## Usage

```yaml
- name: Install Composer Dependencies
  uses: ./actions/composer-setup
  with:
    args: '--prefer-dist --no-scripts'
    with_dev: 'yes'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `args` | Arguments for the composer install command | No | `--prefer-dist --no-scripts` |
| `with_dev` | Install dev dependencies (yes/no) | No | `yes` |

## Caching Strategy

The action implements a two-tier caching strategy:

### Vendor Directory Cache
- **Cache Key**: `{os}-vendor-{hash(composer.lock)}-dev-{with_dev}`
- **Restore Keys**: Falls back to same lock file hash and OS
- **Path**: `vendor/` directory

### Composer Cache Directory
- **Cache Key**: `{os}-composer-{hash(composer.lock)}`
- **Restore Keys**: Falls back to same OS
- **Path**: `~/.composer/cache`
- **Condition**: Only used when vendor cache misses

## Examples

### Basic Usage
```yaml
- name: Install Dependencies
  uses: ./actions/composer-setup
```

### Production Build
```yaml
- name: Install Production Dependencies
  uses: ./actions/composer-setup
  with:
    with_dev: 'no'
    args: '--prefer-dist --no-scripts --optimize-autoloader'
```

## Requirements

- Valid `composer.json` file

## Compatibility

- ✅ **Operating Systems**: Linux, macOS, Windows
- ✅ **PHP Versions**: All versions supported by Composer
- ✅ **Composer Versions**: v2