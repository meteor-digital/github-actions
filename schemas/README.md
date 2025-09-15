# Configuration Schemas

This directory contains JSON Schema files that define the structure and validation rules for the CI/CD configuration files.

## Schema Files

### ci-config.schema.json
Defines the schema for `.github/ci-config.yml` files, including:
- Project configuration (name, type)
- Runtime settings (PHP/Node versions, extensions)
- Build configuration (exclude patterns, build commands)
- Artifact settings (retention, naming patterns)

### deployment-config.schema.json
Defines the schema for `.github/deployment-config.yml` files, including:
- Environment definitions (test, staging, prod)
- Hosting provider configuration
- Deployment settings (shared folders, commands, cleanup)

### quality-config.schema.json
Defines the schema for `.github/quality-config.yml` files, including:
- Quality tool configuration
- Custom check definitions
- Test suite settings
- Notification configuration

## Using the Schemas

### IDE Integration
Most modern IDEs support JSON Schema validation for YAML files. Add this to your YAML file header:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/meteor-digital/github-actions/main/schemas/ci-config.schema.json
```

### Manual Validation
You can validate configuration files using tools like `ajv-cli`:

```bash
# Install ajv-cli
npm install -g ajv-cli

# Validate a configuration file
ajv validate -s ci-config.schema.json -d .github/ci-config.yml
```

### GitHub Actions Validation
The workflows automatically validate configuration files when they change in pull requests.



## Contributing

When updating schemas:
1. Ensure backward compatibility for minor/patch versions
2. Update the `$id` field with the new version
3. Test with existing configuration files
4. Update documentation and examples