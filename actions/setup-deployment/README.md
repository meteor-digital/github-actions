# Setup Deployment Action

Sets up SSH environment and prepares deployment variables following LensOnline patterns.

## Features

- **SSH Setup**: Configures SSH known_hosts and agent
- **Deployment Variables**: Generates deployment date and release directory
- **Security**: Proper SSH key handling and permissions

## Usage

```yaml
- name: Setup deployment environment
  id: setup
  uses: ./actions/setup-deployment
  with:
    host: 'example.com'
    ssh_port: '22'
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Target host | Yes | - |
| `ssh_port` | SSH port | Yes | - |
| `ssh_private_key` | SSH private key | Yes | - |

## Outputs

| Output | Description |
|--------|-------------|
| `deploy_date` | Deployment date/time identifier (YYYYMMDD.HHMM) |
| `release_dir` | Release directory name (releases/YYYYMMDD.HHMM) |

## What It Does

1. **Generates Deployment Variables**
   - Creates unique deployment date identifier
   - Sets release directory path using the Capistrano-style (Deployer) atomic deploy pattern.

2. **SSH Known Hosts Setup**
   - Adds target host to SSH known_hosts
   - Sets proper permissions (700 for ~/.ssh, 600 for known_hosts)

3. **SSH Agent Configuration**
   - Uses `webfactory/ssh-agent` for SSH key management
   - Enables SSH key authentication for subsequent steps

## LensOnline Pattern

The deployment date format matches the original LensOnline pattern:
- Format: `YYYYMMDD.HHMM` (e.g., `20231215.1430`)
- Used for release directory naming
- Ensures chronological ordering of releases