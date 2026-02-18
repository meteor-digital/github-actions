# Build and Push Docker Image

Builds a Docker image from the project and pushes it to one or more container registries.

## Usage

```yaml
- name: Build and push Docker image
  uses: meteor-digital/github-actions/.github/actions/build-and-push-docker-image@main
  with:
    image_name: 'shopware/shopware'
    registries: >-
      [
        {
          "registry": "ghcr.io/my-org",
          "username": "${{ github.actor }}",
          "password": "${{ secrets.GITHUB_TOKEN }}"
        },
        {
          "registry": "myregistry.azurecr.io",
          "username": "${{ secrets.ACR_USERNAME }}",
          "password": "${{ secrets.ACR_PASSWORD }}"
        }
      ]
    build_args: |
      SHOPWARE_PACKAGES_TOKEN=${{ secrets.SHOPWARE_PACKAGES_TOKEN }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config_file` | Path to pipeline configuration file | No | `.github/pipeline-config.yml` |
| `image_name` | Docker image name (without registry prefix) | Yes | - |
| `image_tag` | Docker image tag | No | `${{ github.sha }}` |
| `registries` | JSON array of registry credentials | Yes | - |
| `build_args` | Docker build args (KEY=VALUE per line) | No | `''` |
| `dockerfile` | Path to Dockerfile | No | `./Dockerfile` |
| `context` | Docker build context path | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `image_tags` | Comma-separated list of all pushed image tags |

## Registry Format

The `registries` input expects a JSON array of objects:

```json
[
  {
    "registry": "ghcr.io/my-org",
    "username": "github-actor",
    "password": "github-token"
  }
]
```

Each image is tagged with both `:latest` and `:<git-sha>` (or custom tag) for every registry.
