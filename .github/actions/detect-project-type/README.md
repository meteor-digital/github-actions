# Detect Project Type Action

This shared composite action auto-detects project types based on the presence of specific files. It's used by multiple other actions to avoid code duplication.

## Features

- **Priority-based Detection**: Uses a specific order to determine project type
- **Framework Support**: Detects Shopware, Laravel, and Symfony projects
- **Default Fallback**: Defaults to Shopware for backward compatibility
- **Fast Detection**: Simple file existence checks for quick execution

## Outputs

| Output | Description |
|--------|-------------|
| `type` | Detected project type (`shopware`, `laravel`, `symfony`) |

## Detection Logic

The action detects project types in the following priority order:

1. **Shopware**: `.shopware-project.yml` file exists
2. **Laravel**: `artisan` file exists
3. **Symfony**: `symfony.lock` file exists
4. **Default**: Shopware (for backward compatibility)

## Usage Example

```yaml
- name: Detect project type
  id: project-type
  uses: ./actions/detect-project-type

- name: Use project type
  run: |
    echo "Detected project type: ${{ steps.project-type.outputs.type }}"
    
- name: Shopware-specific step
  if: steps.project-type.outputs.type == 'shopware'
  run: echo "This is a Shopware project"
  
- name: Laravel-specific step
  if: steps.project-type.outputs.type == 'laravel'
  run: echo "This is a Laravel project"
  
- name: Symfony-specific step
  if: steps.project-type.outputs.type == 'symfony'
  run: echo "This is a Symfony project"
```

## Used By

This action is used by:
- `setup-environment` - For framework-specific environment setup
- `build-project` - For framework-specific build processes
- `deploy-to-host` - For framework-specific deployment logic
- Other actions that need project type information

## Detection Files

| Project Type | Detection File | Description |
|--------------|----------------|-------------|
| Shopware | `.shopware-project.yml` | Shopware project configuration file |
| Laravel | `artisan` | Laravel's command-line interface |
| Symfony | `symfony.lock` | Symfony's dependency lock file |

## Default Behavior

If no specific project files are found, the action defaults to `shopware` for backward compatibility with existing workflows. This ensures that the generic CI/CD system works with projects that don't have clear framework indicators.

## Performance

The detection is very fast as it only performs simple file existence checks using shell built-ins. No file parsing or complex logic is involved.