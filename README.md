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

---

## Deploy on Railway

The recommended way to run this in production.

### 1. Create a Telegram bot

1. Open Telegram → search for **@BotFather**
2. Send `/newbot`, follow the prompts
3. Copy the **bot token** (looks like `123456789:AA...`)

### 2. Deploy to Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/github)

Or manually:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### 3. Add a Volume

In Railway dashboard → your service → **Volumes** → Add Volume:
- Mount path: `/data`

This is where OpenClaw stores its config, sessions, and workspace state across deploys.

### 4. Set Environment Variables

In Railway → your service → **Variables**, add:

| Variable | Value | Notes |
|----------|-------|-------|
| `SETUP_PASSWORD` | (strong random string) | Protects the /setup wizard |
| `PORT` | `8080` | Must match Public Networking port |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` | Config persistence |
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` | Agent memory persistence |
| `OPENCLAW_GATEWAY_TOKEN` | (strong random string) | Control UI admin secret |
| `ANTHROPIC_API_KEY` | `sk-ant-...` | From [console.anthropic.com](https://console.anthropic.com) |
| `TELEGRAM_BOT_TOKEN` | `123:abc...` | From @BotFather |

See [.env.example](.env.example) for the full list.

### 5. Enable Public Networking

Railway → your service → **Settings** → **Networking** → Generate Domain:
- Port: `8080`

### 6. Finish setup via the wizard

Open `https://<your-railway-domain>/setup` and enter your `SETUP_PASSWORD`.

The wizard lets you:
- Verify auth is working
- Approve the first Telegram pairing (or change dmPolicy to `open`)
- Configure additional channels

### 7. Approve the first Telegram DM

By default, the bot uses `dmPolicy: "pairing"` — unknown senders get a one-time code.

Option A — approve via CLI (if you have Railway shell access):
```bash
railway run openclaw pairing list telegram
railway run openclaw pairing approve telegram <code>
```

Option B — change to open in Railway variables:
```
# Add to Railway Variables:
TELEGRAM_DM_POLICY=open
```
> Or update `channels.telegram.dmPolicy` to `"open"` in the Config tab of the Control UI.

---

## Local Development

### Prerequisites

- Node.js 22+
- OpenClaw: `npm install -g openclaw@latest`
- Claude Pro/Max or Anthropic API key

### Setup

```bash
# 1. Configure workspace path
openclaw config set agents.defaults.workspace "$(pwd)/workspace"

# 2. (Optional) Seed full config from template
cp openclaw.json ~/.openclaw/openclaw.json
# Then edit ~/.openclaw/openclaw.json and update the workspace path

# 3. Start the gateway
openclaw gateway

# 4. Open Control UI
openclaw dashboard
```

Or use the Claude Code skill: `/setup`

---

## Project Structure

```
marketing-openclaw-assistant/
├── workspace/              # OpenClaw workspace (agent lives here)
│   ├── CLAUDE.md           # Agent context: persona, pipeline, quality gates
│   └── skills/             # Agent skills (future — one per agent)
├── docs/
│   └── ARCHITECTURE.md     # Full 6-phase pipeline + QG1–QG6 details
├── .claude/                # Claude Code dev skills
│   └── skills/setup/
│       └── SKILL.md        # /setup command for local dev
├── Dockerfile              # Builds image for Railway / Docker
├── entrypoint.sh           # Seeds workspace + starts gateway
├── railway.toml            # Railway deployment config
├── openclaw.json           # OpenClaw config template (Telegram + model)
├── .env.example            # Required Railway variables reference
├── CLAUDE.md               # Claude Code context for this repo
└── README.md
```

---

## How It Works on Railway

```
Telegram user
     │
     ▼
@YourBot (Telegram Bot API)
     │
     ▼
OpenClaw Gateway (Railway container)
  - Reads TELEGRAM_BOT_TOKEN from env
  - Routes messages to the marketing agent
  - Agent context loaded from /data/workspace/CLAUDE.md
     │
     ▼
Claude API (claude-opus-4-6)
     │
     ▼
Response streamed back to Telegram
```

On first boot, `entrypoint.sh`:
1. Seeds `/data/workspace/` with `workspace/CLAUDE.md` from the image
2. Seeds `/data/.openclaw/openclaw.json` with the config template
3. Starts the OpenClaw gateway

On redeploys, existing `/data` content is preserved via the Railway Volume.

---

## Links

- [OpenClaw docs](https://docs.openclaw.ai)
- [Railway deployment guide](https://docs.openclaw.ai/install/railway)
- [Telegram channel config](https://docs.openclaw.ai/channels/telegram)
- [Skills reference](https://docs.openclaw.ai/tools/skills)
- [Configuration reference](https://docs.openclaw.ai/gateway/configuration-reference)
