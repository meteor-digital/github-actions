# Notify Teams Action

Simple action to send messages to Teams channels.

## Usage

```yaml
- name: Send notification
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: "✅ Build for **my-project** completed successfully"
    color: "00FF00"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `webhook_url` | Teams/Slack webhook URL | ✅ | |
| `message` | Message content to send (supports Markdown) | ✅ | |
| `color` | Message color (hex code without #) | | `808080` (gray) |
| `timezone` | Timezone for timestamps | | `Europe/Amsterdam` |

## Examples

### Success Notification
```yaml
- name: Notify success
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: "✅ Deploy **my-project** to **production** SUCCESS"
    color: "00FF00"
```

### Failure Notification
```yaml
- name: Notify failure
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: "❌ Build for **my-project** failed"
    color: "FF0000"
```

### Rich Notification with Links
```yaml
- name: Notify with details
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: |
      🚨 **my-project** release branch validation failed!
      
      **Branch:** release/next
      **Commit:** [`abc12345`](${{ github.server_url }}/${{ github.repository }}/commit/abc12345) by John Doe
      **Message:** Fix critical bug in checkout process
      
      [View workflow run](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
    color: "FF0000"
```

### In-Progress Notification
```yaml
- name: Notify deployment started
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: "🚀 Deploy **my-project** to **production** started"
    color: "FFFF00"
```

## Common Colors

- 🟢 **Success**: `00FF00` (green)
- 🔴 **Failure**: `FF0000` (red)  
- 🟡 **In Progress**: `FFFF00` (yellow)
- 🟠 **Warning**: `FFA500` (orange)
- ⚪ **Info**: `808080` (gray)

## Message Composition

Since this action just sends whatever message you provide, you compose the message in your workflow. This gives you complete control.

### Helper for Project Name
```yaml
- name: Get project name
  id: project
  run: |
    if [ -f ".github/pipeline-config.yml" ]; then
      PROJECT_NAME=$(yq eval '.project.name' .github/pipeline-config.yml 2>/dev/null || echo "${{ github.event.repository.name }}")
    else
      PROJECT_NAME="${{ github.event.repository.name }}"
    fi
    echo "name=$PROJECT_NAME" >> $GITHUB_OUTPUT

- name: Send notification
  uses: meteor-digital/github-actions/.github/actions/notify-teams@main
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK }}
    message: "✅ Build for **${{ steps.project.outputs.name }}** completed"
    color: "00FF00"
```