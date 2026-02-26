# Cleanup Old Releases Action

Cleans up old releases to manage disk space while keeping a configurable number for rollback.

## Usage

```yaml
- name: Cleanup old releases
  uses: meteor-digital/github-actions/.github/actions/cleanup-releases@main
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    keep_releases: '3'
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `host` | Target host | Yes |
| `ssh_port` | SSH port | Yes |
| `ssh_user` | SSH username | Yes |
| `deploy_path` | Deployment path | Yes |
| `keep_releases` | Number of releases to keep | Yes |

## How It Works

1. Counts releases in `{deploy_path}/releases/`
2. If count > `keep_releases`: removes oldest releases
3. Keeps most recent N releases for rollback capability

## Related Actions

- **`deploy-to-host`**: Uses this action after successful deployment
- **`cleanup-azure-revisions`**: Azure equivalent for container revisions