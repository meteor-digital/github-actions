# Activate Release Action

Activates a new release with atomic symlink switching and Sentry integration following proven patterns.

## Features

- **Atomic Deployment**: Zero-downtime release activation
- **Proven Pattern**: Follows battle-tested symlink switching pattern
- **Sentry Integration**: Updates Sentry release environment variable
- **Safe Operations**: Handles missing current symlink gracefully

## Usage

```yaml
- name: Activate new release
  uses: ./actions/activate-release
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    deploy_date: '20231215.1430'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `deploy_path` | Deployment path | Yes | - |
| `deploy_date` | Deployment date identifier | Yes | - |

## What It Does

### 1. Atomic Symlink Switch
Following the proven pattern:

```bash
# Remove existing current symlink (if exists)
[ -d /var/www/app/current ] && unlink /var/www/app/current || exit 0

# Create new symlink to release
ln -s /var/www/app/releases/20231215.1430/ /var/www/app/current
```

### 2. Sentry Release Integration
Updates the Sentry release environment variable:

```bash
sed -i --in-place --follow-symlinks \
  "s/SENTRY_RELEASE=.*/SENTRY_RELEASE='release-20231215.1430'/g" \
  /var/www/app/current/.env.local
```

## Directory Structure

Before activation:
```
/var/www/app/
├── releases/
│   ├── 20231214.1200/  (old release)
│   └── 20231215.1430/  (new release)
└── current -> releases/20231214.1200
```

After activation:
```
/var/www/app/
├── releases/
│   ├── 20231214.1200/  (old release)
│   └── 20231215.1430/  (new release)
└── current -> releases/20231215.1430  (updated)
```

## Sentry Integration

The Sentry release format follows the pattern:
- Format: `release-{deploy_date}`
- Example: `release-20231215.1430`
- Updated in `.env.local` file

## Error Handling

- **Missing Current**: Gracefully handles missing current symlink
- **Atomic Operation**: Symlink switch is atomic (no downtime)
- **Sentry Failure**: Continues deployment even if Sentry update fails

## Security

- Requires SSH agent to be configured
- Uses in-place sed editing with symlink following
- Safe symlink operations with error handling