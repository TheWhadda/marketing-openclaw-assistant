---
name: setup
description: Set up OpenClaw for the marketing-openclaw-assistant workspace
user-invocable: true
---

# Setup — Marketing OpenClaw Assistant

Configure OpenClaw to use this project's workspace for the marketing assistant.

## Steps

### 1. Check OpenClaw is installed

```bash
openclaw --version
```

If not installed:
```bash
npm install -g openclaw@latest
```

### 2. Get the absolute path of this workspace

```bash
pwd
```

Note the path — you'll need it in the next step.

### 3. Configure the workspace path

```bash
openclaw config set agents.defaults.workspace "$(pwd)/workspace"
```

Verify it was set:
```bash
openclaw config get agents.defaults.workspace
```

### 4. Configure the model

```bash
openclaw config set agents.defaults.model.primary "anthropic/claude-opus-4-6"
```

### 5. Set session reset policy

```bash
openclaw config set session.reset.mode "daily"
openclaw config set session.reset.atHour 4
openclaw config set session.reset.idleMinutes 240
```

### 6. Authenticate with Anthropic

If not already authenticated, run the onboarding wizard:
```bash
openclaw onboard
```

Or set the API key directly:
```bash
openclaw config set auth.anthropic.apiKey "YOUR_API_KEY"
```

### 7. Start the gateway

```bash
openclaw gateway
```

### 8. Verify the workspace loads

```bash
openclaw dashboard
```

Open the Control UI and send a test message. The agent should respond with its marketing assistant persona (see `workspace/CLAUDE.md`).

## Verification Checklist

- [ ] `openclaw gateway status` returns "running"
- [ ] `openclaw config get agents.defaults.workspace` shows the correct path
- [ ] Agent responds to a test message in the Control UI
- [ ] Agent mentions its marketing assistant role in the first response

## Troubleshooting

**Gateway won't start:**
```bash
openclaw doctor
openclaw logs --tail 50
```

**Workspace not loading:**
- Check the path has no spaces or use quoted paths
- Verify `workspace/CLAUDE.md` exists
- Check file permissions

**Authentication errors:**
```bash
openclaw auth status
openclaw onboard  # re-run onboarding
```
