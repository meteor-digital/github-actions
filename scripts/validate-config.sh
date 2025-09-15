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
    "$CONFIG_DIR/ci-config.yml"
    "$CONFIG_DIR/deployment-config.yml"
    "$CONFIG_DIR/quality-config.yml"
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
        if yq eval '.' "$file" > /dev/null 2>&1; then
            echo "  ✅ $file - Valid YAML"
        else
            echo "  ❌ $file - Invalid YAML syntax"
            exit 1
        fi
    done
else
    echo "⚠️  yq not found - skipping YAML syntax validation"
    echo "   Install yq: https://github.com/mikefarah/yq"
fi

echo ""
echo "✅ Basic configuration validation completed"
echo ""
echo "💡 For comprehensive validation (schema, content, etc.):"
echo "   Use the validate-config GitHub Action in your workflows"
echo ""
echo "📋 Next steps:"
echo "1. Review and customize configuration files for your project"
echo "2. Set up required GitHub secrets and variables"
echo "3. Test workflows with a pull request or push"