#!/bin/bash

# Configuration validation script
# Usage: ./validate-config.sh [config-directory]

set -e

CONFIG_DIR=${1:-".github"}

echo "Validating CI/CD configuration in $CONFIG_DIR..."

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
    echo "Run the setup script to create these files:"
    echo "  /path/to/github-actions/scripts/setup-project.sh [project-type] [hosting-provider]"
    exit 1
fi

echo "✅ All required configuration files found"

# Basic YAML syntax validation (if yq is available)
if command -v yq &> /dev/null; then
    echo "Validating YAML syntax..."
    
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
    echo "   Install yq for enhanced validation: https://github.com/mikefarah/yq"
fi

# Check workflow files
WORKFLOW_DIR="$CONFIG_DIR/workflows"
if [ -d "$WORKFLOW_DIR" ]; then
    echo "Checking workflow files..."
    
    WORKFLOW_FILES=("$WORKFLOW_DIR"/*.yml)
    if [ -f "${WORKFLOW_FILES[0]}" ]; then
        for workflow in "${WORKFLOW_FILES[@]}"; do
            if grep -q "uses:.*/.github/workflows/" "$workflow"; then
                REPO_REF=$(grep "uses:.*/.github/workflows/" "$workflow" | head -1 | sed 's/.*uses: *\([^/]*\/[^/]*\)\/.*/\1/')
                echo "  ✅ $(basename "$workflow") - References $REPO_REF"
            else
                echo "  ⚠️  $(basename "$workflow") - No reusable workflow reference found"
            fi
        done
    else
        echo "  ⚠️  No workflow files found in $WORKFLOW_DIR"
    fi
else
    echo "  ⚠️  No workflows directory found at $WORKFLOW_DIR"
fi

echo ""
echo "✅ Configuration validation completed"
echo ""
echo "Next steps:"
echo "1. Review configuration files and customize for your project"
echo "2. Set up required GitHub secrets"
echo "3. Test workflows with a pull request or push"