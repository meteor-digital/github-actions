# Create Symlinks Action

Creates symlinks for shared folders following proven LensOnline deployment patterns.

## Features

- **Shared Folder Management**: Creates symlinks to shared directories
- **LensOnline Pattern**: Follows the exact symlink creation pattern from LensOnline
- **Environment File**: Automatically creates .env.local symlink
- **Safe Operations**: Removes existing directories before creating symlinks

## Usage

```yaml
- name: Create shared folder symlinks
  uses: ./actions/create-symlinks
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    release_dir: 'releases/20231215.1430'
    shared_folders: |
      files
      public/media
      public/sitemap
      var/log
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `deploy_path` | Deployment path | Yes | - |
| `release_dir` | Release directory | Yes | - |
| `shared_folders` | Shared folders list (newline separated) | Yes | - |

## What It Does

1. **Environment File Symlink**
   ```bash
   ln -sf /var/www/app/shared/.env.local .env.local
   ```

2. **Shared Folder Symlinks**
   - Removes existing directories in release
   - Creates symlinks to shared directories

## Directory Structure

```
/var/www/app/
├── shared/
│   ├── .env.local
│   ├── files/
│   ├── public/media/
│   ├── public/sitemap/
│   └── var/log/
├── releases/
│   └── 20231215.1430/
│       ├── .env.local -> ../shared/.env.local
│       ├── files -> ../shared/files
│       ├── public/media -> ../shared/public/media
│       └── var/log -> ../shared/var/log
└── current -> releases/20231215.1430
```

## Framework-Specific Folders

### Shopware (Default)
```yaml
shared_folders: |
  files
  public/media
  public/sitemap
  public/thumbnail
  config/jwt
  var/log
```

### Laravel
```yaml
shared_folders: |
  storage
  bootstrap/cache
```

### Symfony
```yaml
shared_folders: |
  var
  public/uploads
```

## Security

- Requires SSH agent to be configured
- Uses relative symlinks for portability
- Safe directory removal before symlink creation