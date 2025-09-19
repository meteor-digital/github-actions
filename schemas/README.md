# Configuration Schemas

This directory contains JSON Schema files that define the structure and validation rules for the CI/CD configuration files.

## Schema Files

### pipeline-config.schema.json
Defines the schema for `.github/pipeline-config.yml` files, including:
- Project configuration (name, type)
- Runtime settings (PHP/Node versions, extensions)
- Build configuration (exclude patterns, build commands)
- Artifact settings (retention, naming patterns)
- Notification configuration (webhooks)
- Deployment configuration:
  - Environment definitions (test, staging, prod)
  - Hosting provider configuration
  - Deployment settings (shared folders, commands, cleanup)

## Using the Schemas

### IDE Integration
Most modern IDEs support JSON Schema validation for YAML files. Add this to your YAML file header:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/meteor-digital/github-actions/main/schemas/pipeline-config.schema.json
```

### Manual Validation
You can validate configuration files using tools like `ajv-cli`:

```bash
# Install ajv-cli
npm install -g ajv-cli

# Validate a configuration file
ajv validate -s pipeline-config.schema.json -d .github/pipeline-config.yml
```

### GitHub Actions Validation
The workflows automatically validate configuration files when they change in pull requests.



## Contributing

When updating schemas:
1. Ensure backward compatibility for minor/patch versions
2. Update the `$id` field with the new version
3. Test with existing configuration files
4. Update documentation and examples