# marketing-openclaw-assistant

Marketing automation workspace built on [OpenClaw](https://openclaw.ai). See [README.md](README.md) for overview and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full multi-agent pipeline design.

## Quick Context

OpenClaw Gateway runs as a local service. This repo configures a **workspace** that defines the marketing agent's persona, memory, and skills. The agent pipeline (6 phases, 12+ agents) is planned but not yet implemented — the current focus is project foundation.

## Key Files

| File | Purpose |
|------|---------|
| `openclaw.json` | OpenClaw config template (copy to `~/.openclaw/openclaw.json`) |
| `workspace/CLAUDE.md` | Agent context and persona loaded by OpenClaw |
| `workspace/skills/` | Agent skills directory (future implementation) |
| `docs/ARCHITECTURE.md` | Full pipeline: phases, agents, quality gates |

## Skills

| Skill | Command | When to Use |
|-------|---------|-------------|
| Setup | `/setup` | Initial OpenClaw configuration for this workspace |

## Development Commands

```bash
# Check OpenClaw status
openclaw gateway status

# Open Control UI
openclaw dashboard

# Set workspace path (run from repo root)
openclaw config set agents.defaults.workspace "$(pwd)/workspace"

# Apply openclaw.json config
cp openclaw.json ~/.openclaw/openclaw.json
# then edit paths in ~/.openclaw/openclaw.json
```

## Pipeline Overview

6 phases with Quality Gates (QG1–QG6):
- **DISCOVERY** → QG1 (Valid Hypothesis)
- **PLANNING** → QG2 (Executable Plan) + human approval
- **PRODUCTION** → QG3 (Pre-Launch Validation)
- **EXECUTION** → QG4 (Launch Verification)
- **MONITORING** → QG5 (Safety)
- **LEARNING** → QG6 (Knowledge Update) → back to DISCOVERY

Full agent list and responsibilities: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## What NOT to Do

- Do not implement agents without first reviewing ARCHITECTURE.md
- Do not store API keys or secrets in this repo
- Do not modify `workspace/CLAUDE.md` for temporary session context — use OpenClaw's built-in memory tools instead
