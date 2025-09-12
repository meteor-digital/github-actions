#!/bin/bash

# Setup script for integrating generic CI/CD workflows into a new project
# Usage: Run this script from your project root directory
# ./path/to/github-actions/scripts/setup-project.sh [project-type] [hosting-provider]

set -e

PROJECT_TYPE=${1:-"shopware"}
HOSTING_PROVIDER=${2:-"level27"}

# Get the directory where this script is located (the github-actions repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTIONS_REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up generic CI/CD workflows for $PROJECT_TYPE project with $HOSTING_PROVIDER hosting..."
echo "Using templates from: $ACTIONS_REPO_DIR"

# Verify we're in a project directory (not the actions repo)
if [ "$(basename "$(pwd)")" = "generic-ci-cd-workflows" ] || [ -f "actions/setup-environment/action.yml" ]; then
    echo "❌ Error: This script should be run from your project directory, not from the github-actions repository"
    echo ""
    echo "Usage:"
    echo "  cd /path/to/your/project"
    echo "  /path/to/github-actions/scripts/setup-project.sh $PROJECT_TYPE $HOSTING_PROVIDER"
    exit 1
fi

# Create .github directory if it doesn't exist
mkdir -p .github/workflows

# Copy template configuration files based on project type
TEMPLATE_DIR="$ACTIONS_REPO_DIR/templates/$PROJECT_TYPE"
if [ -d "$TEMPLATE_DIR" ]; then
    echo "Copying $PROJECT_TYPE configuration files..."
    cp "$TEMPLATE_DIR/ci-config.yml" ".github/"
    cp "$TEMPLATE_DIR/deployment-config.yml" ".github/"
    cp "$TEMPLATE_DIR/quality-config.yml" ".github/"
    
    # Copy workflow template files
    echo "Creating workflow files from templates..."
    
    if [ -d "$TEMPLATE_DIR/.github/workflows" ]; then
        cp "$TEMPLATE_DIR/.github/workflows"/* .github/workflows/
    else
        echo "Warning: No workflow templates found for project type '$PROJECT_TYPE'"
    fi

else
    echo "Warning: No templates found for project type '$PROJECT_TYPE'"
    echo "Available project types:"
    ls "$ACTIONS_REPO_DIR/templates/" 2>/dev/null || echo "No templates directory found"
    exit 1
fi

# Update hosting provider in deployment config if different from default
if [ "$HOSTING_PROVIDER" != "level27" ]; then
    echo "Updating hosting provider to $HOSTING_PROVIDER..."
    sed -i "s/provider: \"level27\"/provider: \"$HOSTING_PROVIDER\"/" .github/deployment-config.yml
fi

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "Configuration files created in .github/ directory:"
echo "  - ci-config.yml"
echo "  - deployment-config.yml" 
echo "  - quality-config.yml"
echo ""
echo "Workflow files created in .github/workflows/ directory:"
ls .github/workflows/
echo ""
echo "These workflows reference the reusable workflows from: meteor-digital/github-actions"
echo ""
echo "Next steps:"
echo "1. Review and customize the configuration files for your project"
echo "2. Set up required GitHub secrets:"
echo "   - METEOR_SATIS_USERNAME"
echo "   - METEOR_SATIS_PASSWORD"
echo "   - SHOPWARE_STORE_BEARER_TOKEN"
echo "   - SSH_PRIVATE_KEY"
echo "   - TEST_HOST, ACC_HOST, PROD_HOST (deployment hostnames)"
echo "   - TEST_PATH, ACC_PATH, PROD_PATH (deployment paths)"
echo "   - TEAMS_WEBHOOK (optional)"
echo "3. Commit and push the changes"
echo "4. Test the workflows with a pull request or push to a test branch"
echo ""
echo "For detailed configuration options, see: docs/configuration.md"