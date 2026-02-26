# Activate Release Action

Activates a new release with atomic symlink switching and Sentry integration.

## Usage

```yaml
- name: Activate new release
  uses: meteor-digital/github-actions/.github/actions/activate-release@main
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    deploy_date: '20231215.1430'
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `host` | Target host | Yes |
| `ssh_port` | SSH port | Yes |
| `ssh_user` | SSH username | Yes |
| `deploy_path` | Deployment path | Yes |
| `deploy_date` | Deployment date identifier (YYYYMMDD.HHMM) | Yes |

## How It Works

1. **Atomic symlink switch**: Updates `current` symlink to point to new release directory
2. **Sentry integration**: Updates `SENTRY_RELEASE` in `.env.local` to `release-{deploy_date}`
3. **Zero downtime**: Symlink switch is atomic, no service interruption

## Related Actions

- **`deploy-to-host`**: Uses this action to activate releases
- **`cleanup-releases`**: Cleans up old releases after activation