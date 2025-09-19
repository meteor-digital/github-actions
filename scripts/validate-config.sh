#!/bin/bash

# Configuration validation script for local development
# Usage: ./validate-config.sh [config-directory]
#
# Note: This is a simplified version for local use.
# The GitHub workflows use the validate-config action for comprehensive validation.

set -e

CONFIG_DIR=${1:-".github"}

echo "🔍 Validating CI/CD configuration in $CONFIG_DIR..."

# Check if configuration files exist
REQUIRED_FILES=(
    "$CONFIG_DIR/pipeline-config.yml"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "❌ Missing required configuration files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "💡 Run the setup script to create these files:"
    echo "  ./scripts/setup-project.sh [project-type] [hosting-provider]"
    exit 1
fi

echo "✅ All required configuration files found"

# Basic YAML syntax validation (if yq is available)
if command -v yq &> /dev/null; then
    echo "📝 Validating YAML syntax..."

    for file in "${REQUIRED_FILES[@]}"; do
        # Try different yq syntax variants
        if cat "$file" | yq . >/dev/null 2>&1; then
            echo "  ✅ $file - Valid YAML"
        elif yq eval '.' "$file" >/dev/null 2>&1; then
            echo "  ✅ $file - Valid YAML"
        else
            echo "  ❌ $file - Invalid YAML syntax"
            exit 1
        fi
    done
    
    # Enhanced quality checks validation in pipeline-config.yml
    if [ -f "$CONFIG_DIR/pipeline-config.yml" ]; then
        echo "📋 Validating quality configuration in pipeline config..."
        
        # Check if quality_checks section exists
        if cat "$CONFIG_DIR/pipeline-config.yml" | yq '.quality_checks' >/dev/null 2>&1; then
            # Check if enabled_tools is defined
            tools_count=$(cat "$CONFIG_DIR/pipeline-config.yml" | yq '.quality_checks.enabled_tools | length' 2>/dev/null || echo "0")
            if [ "$tools_count" = "0" ] || [ "$tools_count" = "null" ]; then
                echo "  ⚠️  No quality tools enabled in quality_checks section"
            else
                echo "  ✅ Found $tools_count enabled quality tools"
            fi
            
            # Check if tool_binaries section exists and validate structure
            if cat "$CONFIG_DIR/pipeline-config.yml" | yq '.quality_checks.tool_binaries' >/dev/null 2>&1; then
                binaries_count=$(cat "$CONFIG_DIR/pipeline-config.yml" | yq '.quality_checks.tool_binaries | keys | length' 2>/dev/null || echo "0")
                if [ "$binaries_count" != "0" ] && [ "$binaries_count" != "null" ]; then
                    echo "  ✅ Found $binaries_count tool binary overrides"
                fi
            fi
        else
            echo "  ⚠️  No quality_checks section found in pipeline-config.yml"
        fi
    fi
else
    echo "⚠️  yq not found - skipping YAML syntax validation"
    echo "   Install yq: https://github.com/mikefarah/yq"
fi

# JSON Schema validation (if ajv-cli is available)
if command -v npx >/dev/null 2>&1 && [ -f "schemas/quality-config.schema.json" ]; then
    echo "🔍 Validating against JSON schema..."
            echo "  ✅ Schema validation passed"
        else
            echo "  ❌ Schema validation failed"
            echo "  Run with details: npx ajv validate -s schemas/quality-config.schema.json -d <json-file>"
        fi
        
        rm -f "$TEMP_JSON"
    fi
elif [ ! -f "schemas/quality-config.schema.json" ]; then
    echo "⚠️  Schema file not found - skipping JSON schema validation"
else
    echo "⚠️  ajv-cli not found - skipping JSON schema validation"
    echo "   Install with: npm install ajv-cli"
fi

echo ""
echo "✅ Configuration validation completed"
echo ""
echo "💡 For comprehensive validation (schema, content, etc.):"
echo "   Use the validate-config GitHub Action in your workflows"
echo ""
echo "📋 Next steps:"
echo "1. Review and customize configuration files for your project"
echo "2. Set up required GitHub secrets and variables"
echo "3. Test workflows with a pull request or push"
