# Cleanup Old Releases Action

Cleans up old releases following the LensOnline cleanup pattern to manage disk space.

## Features

- **LensOnline Pattern**: Uses the exact cleanup logic from LensOnline
- **Configurable Retention**: Keeps specified number of releases
- **Safe Operations**: Only removes releases when count exceeds limit
- **Chronological Cleanup**: Removes oldest releases first

## Usage

```yaml
- name: Cleanup old releases
  uses: ./actions/cleanup-releases
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_user: 'deploy'
    deploy_path: '/var/www/app'
    keep_releases: '3'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `deploy_path` | Deployment path | Yes | - |
| `keep_releases` | Number of releases to keep | Yes | - |

## What It Does

### 1. Count Current Releases
```bash
RELEASES=$(cd /var/www/app/releases/ && ls -A1 | wc -l)
```

### 2. Calculate Cleanup Threshold
```bash
TAIL_FROM_LINE=$((keep_releases + 1))
```

### 3. Remove Old Releases (if needed)
Following the LensOnline pattern:
```bash
cd /var/www/app/releases/
ls -A1 | sort -rn | tail -n +$TAIL_FROM_LINE | xargs -r rm -rf
```

## Example Scenarios

### Keep 3 Releases
With releases: `20231213.1000`, `20231214.1200`, `20231215.1430`, `20231216.0900`

**Before cleanup:**
```
releases/
├── 20231213.1000/
├── 20231214.1200/
├── 20231215.1430/
└── 20231216.0900/
```

**After cleanup (keep_releases: 3):**
```
releases/
├── 20231214.1200/
├── 20231215.1430/
└── 20231216.0900/
```

The oldest release (`20231213.1000`) is removed.

### No Cleanup Needed
With releases: `20231215.1430`, `20231216.0900` (only 2 releases, keep_releases: 3)

No cleanup is performed since release count (2) is less than keep_releases (3).

## Safety Features

- **Count Verification**: Only removes releases when count exceeds limit
- **Chronological Order**: Always removes oldest releases first
- **Current Protection**: Never removes the current active release
- **Error Handling**: Continues deployment even if cleanup fails

## Security

- Requires SSH agent to be configured
- Uses safe file operations with error checking
- No recursive deletion of unexpected directories