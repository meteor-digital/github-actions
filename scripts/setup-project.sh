#!/bin/bash

# Setup script for integrating generic CI/CD workflows into a new project
# Usage: Run this script from your project root directory
# ./path/to/github-actions/scripts/setup-project.sh <project-type> <hosting-provider>

set -e

# Function to display help message
display_help() {
    echo "Usage: $0 <project-type> <hosting-provider>"
    echo
    echo "Sets up generic CI/CD workflows for a new project by copying template"
    echo "workflow and configuration files into the current directory."
    echo
    echo "Arguments:"
    echo "  project-type      The type of the project (e.g., shopware, laravel, symfony)."
    echo "                    This determines which template files are used."
    echo "  hosting-provider  The hosting provider (e.g., level27, byte, hipex, hostedpower, forge)."
    echo "                    This sets the 'provider' in the pipeline-config.yml."
    echo
    echo "Options:"
    echo "  -h, --help        Display this help message and exit."
    exit 0
}

# Check for help flag
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    display_help
fi

# Validate required arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required arguments." >&2
    echo "Please provide both a project type and a hosting provider." >&2
    echo >&2
    display_help
fi

PROJECT_TYPE=$1
HOSTING_PROVIDER=$2

# Get the directory where this script is located (the github-actions repo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTIONS_REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up generic CI/CD workflows for $PROJECT_TYPE project with $HOSTING_PROVIDER hosting..."
echo "Using templates from: $ACTIONS_REPO_DIR"

# Verify we're in a project directory (not the actions repo)
if  [ -f "actions/setup-environment/action.yml" ]; then
    echo "❌ Error: This script should be run from your project directory, not from the github-actions repository" >&2
    echo "" >&2
    echo "Usage:" >&2
    echo " cd /path/to/your/project" >&2
    echo " ./path/to/github-actions/scripts/setup-project.sh <project-type> <hosting-provider>" >&2
    exit 1
fi

# Create .github directory if it doesn't exist
mkdir -p .github/workflows

# Copy template configuration files based on project type
TEMPLATE_DIR="$ACTIONS_REPO_DIR/templates/$PROJECT_TYPE"
if [ -d "$TEMPLATE_DIR" ]; then
    echo "Copying $PROJECT_TYPE configuration files..."
    cp "$TEMPLATE_DIR/pipeline-config.yml" ".github/"
    
    # Copy workflow template files
    echo "Creating workflow files from templates..."
    
    if [ -d "$TEMPLATE_DIR/.github/workflows" ]; then
        cp "$TEMPLATE_DIR/.github/workflows"/* .github/workflows/
    else
        echo "Warning: No workflow templates found for project type '$PROJECT_TYPE'"
    fi

else
    echo "Warning: No templates found for project type '$PROJECT_TYPE'" >&2
    echo "Available project types:" >&2
    ls "$ACTIONS_REPO_DIR/templates/" 2>/dev/null || echo "No templates directory found"
    exit 1
fi

# Update hosting provider in pipeline config
echo "Setting hosting provider to $HOSTING_PROVIDER..."
sed "s/{{HOSTING_PROVIDER}}/$HOSTING_PROVIDER/g" .github/pipeline-config.yml > .github/pipeline-config.yml.tmp && mv .github/pipeline-config.yml.tmp .github/pipeline-config.yml

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "Configuration file (pipeline-config.yml) created in .github/ directory"
echo ""
echo "Workflow files created in .github/workflows/ directory:"
ls -1A .github/workflows/
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
echo "3. Commit and push the changes"
echo "4. Test the workflows with a pull request or push to a test branch"
echo ""