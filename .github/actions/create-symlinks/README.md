# Create Symlinks Action

Creates symlinks for shared folders (files, media, logs, etc.) and environment configuration.

## Usage

```yaml
- name: Create shared folder symlinks
  uses: meteor-digital/github-actions/.github/actions/create-symlinks@main
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    release_dir: 'releases/20231215.1430'
    shared_folders: |
      files
      public/media
      var/log
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `host` | Target host | Yes |
| `ssh_port` | SSH port | Yes |
| `ssh_user` | SSH username | Yes |
| `deploy_path` | Deployment path | Yes |
| `release_dir` | Release directory (relative to deploy_path) | Yes |
| `shared_folders` | Shared folders list (newline separated) | Yes |

## How It Works

1. Creates `.env.local` symlink from `shared/.env.local`
2. For each shared folder: removes directory in release, creates symlink to `shared/{folder}`

## Related Actions

- **`deploy-to-host`**: Uses this action to set up shared folders