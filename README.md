# Marketing OpenClaw Assistant

Multi-agent marketing automation system built on [OpenClaw](https://openclaw.ai) — a personal AI gateway with extensible messaging integrations.

## What This Is

This project provides a **workspace** for an OpenClaw assistant configured for marketing automation. It is the foundation for a multi-agent pipeline that covers the full marketing lifecycle: discovery → planning → production → execution → monitoring → learning.

The agents are not implemented yet — this repo establishes the architecture, conventions, and project structure.

## Agent Pipeline (planned)

```
DISCOVERY
  Агент-аналитик → Агент-дипресерчер → Агент-гипотезатор
  ↓ [QG1: Valid Hypothesis]

PLANNING
  Агент-гипотезатор → Агент-распределятор-планировщик → (апрув человека)
  ↓ [QG2: Executable Plan]

PRODUCTION
  Агент-семантолог + Агент-копирайтер + Агент-иллюстратор + Агент-настройщик
  → Агент-запускатор
  ↓ [QG3: Pre-Launch Validation]

EXECUTION
  Агент-запускатор → Проверка → Публикация
  ↓ [QG4: Launch Verification]

MONITORING
  Агент-контролер ↔ Агент-аналитик
  ↓ [QG5: Safety]

LEARNING
  Агент-оценщик → Агент-масштабировщик → Обновление базы знаний
  ↓ [QG6: Knowledge Update]
  ↺ → DISCOVERY
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full pipeline details.

## Prerequisites

- Node.js 22+
- OpenClaw installed globally: `npm install -g openclaw@latest`
- Claude Pro/Max or Anthropic API key

## Setup

1. **Install OpenClaw** (if not already):
   ```bash
   npm install -g openclaw@latest
   openclaw onboard --install-daemon
   ```

2. **Configure the workspace path** in OpenClaw:
   ```bash
   openclaw config set agents.defaults.workspace "$(pwd)/workspace"
   ```
   Or copy [openclaw.json](openclaw.json) to `~/.openclaw/openclaw.json` and update paths.

3. **Start the gateway**:
   ```bash
   openclaw gateway
   ```

4. **Open the Control UI**:
   ```bash
   openclaw dashboard
   ```

## Project Structure

```
marketing-openclaw-assistant/
├── workspace/              # OpenClaw workspace (agent lives here)
│   ├── CLAUDE.md           # Agent context and persona
│   └── skills/             # Agent skills (future)
├── docs/
│   └── ARCHITECTURE.md     # Full pipeline architecture
├── .claude/                # Claude Code dev skills
│   └── skills/
│       └── setup/
├── openclaw.json           # OpenClaw config template
├── CLAUDE.md               # Claude Code context for this repo
└── README.md
```

## Development

This project uses Claude Code for development. Key skills:

| Skill | Command | Purpose |
|-------|---------|---------|
| Setup | `/setup` | Configure OpenClaw for this workspace |

## Links

- [OpenClaw docs](https://docs.openclaw.ai)
- [Getting started](https://docs.openclaw.ai/start/getting-started)
- [Skills reference](https://docs.openclaw.ai/tools/skills)
- [Configuration reference](https://docs.openclaw.ai/gateway/configuration-reference)
