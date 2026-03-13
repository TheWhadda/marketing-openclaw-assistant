#!/bin/sh
set -e

STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
PORT="${PORT:-8080}"
GATEWAY_INTERNAL_PORT="${GATEWAY_INTERNAL_PORT:-8081}"

echo "[entrypoint] Starting marketing-openclaw-assistant"
echo "[entrypoint] State dir:     $STATE_DIR"
echo "[entrypoint] Workspace dir: $WORKSPACE_DIR"
echo "[entrypoint] Port:          $PORT"

# Create persistent directories if they don't exist
mkdir -p "$STATE_DIR" "$WORKSPACE_DIR"

# First boot: seed the full workspace (memories, session data, etc.)
if [ ! -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
  echo "[entrypoint] First boot — seeding workspace from image..."
  cp -r /app/workspace-seed/. "$WORKSPACE_DIR/"
  echo "[entrypoint] Workspace seeded."
fi

# Always sync agent config files from the image on every deploy.
cp /app/workspace-seed/CLAUDE.md "$WORKSPACE_DIR/CLAUDE.md"
echo "[entrypoint] CLAUDE.md synced."

if [ -d "/app/workspace-seed/skills" ]; then
  mkdir -p "$WORKSPACE_DIR/skills"
  cp -r /app/workspace-seed/skills/. "$WORKSPACE_DIR/skills/"
  echo "[entrypoint] Skills synced."
fi

if [ -d "/app/workspace-seed/scripts" ]; then
  mkdir -p "$WORKSPACE_DIR/scripts"
  cp -r /app/workspace-seed/scripts/. "$WORKSPACE_DIR/scripts/"
  echo "[entrypoint] Scripts synced."
fi

# OPENCLAW_GATEWAY_TOKEN is required for gateway auth.
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
  echo "[entrypoint] ERROR: OPENCLAW_GATEWAY_TOKEN is not set."
  exit 1
fi

echo "[entrypoint] Applying openclaw config..."
# Remove session.scope if present — written by a bad deploy, causes gateway crash
node -e "
  const fs = require('fs');
  const p = '$STATE_DIR/openclaw.json';
  if (!fs.existsSync(p)) process.exit(0);
  const c = JSON.parse(fs.readFileSync(p, 'utf8'));
  if (c.session && 'scope' in c.session) {
    delete c.session.scope;
    fs.writeFileSync(p, JSON.stringify(c, null, 2));
    console.log('[entrypoint] Removed unsupported session.scope from config.');
  }
"
openclaw config set gateway.mode local
# Bind to loopback so internal tool calls (sessions_list, exec, etc.) connect via
# 127.0.0.1 — no pairing required. External traffic reaches the gateway through
# the proxy process started below.
openclaw config set gateway.bind loopback
openclaw config set agents.defaults.workspace "$WORKSPACE_DIR"
openclaw config set agents.defaults.model.primary "${OPENCLAW_MODEL:-anthropic/claude-haiku-4-5-20251001}"
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.streamMode partial
if [ -n "$TELEGRAM_ALLOWLIST" ]; then
  ALLOW_JSON=$(printf '%s' "$TELEGRAM_ALLOWLIST" | sed 's/,/","/g; s/^/["/; s/$/"]/')
  echo "[entrypoint] Telegram allowlist: $ALLOW_JSON"
  openclaw config set channels.telegram.dmPolicy allowlist
  openclaw config set channels.telegram.allowFrom "$ALLOW_JSON"
else
  openclaw config set channels.telegram.dmPolicy open
  openclaw config set channels.telegram.allowFrom '["*"]'
fi
openclaw config set session.dmScope per-channel-peer
openclaw config set session.reset.mode daily
openclaw config set session.reset.atHour 4
openclaw config set session.reset.idleMinutes 240
openclaw config set messages.tts.auto off
openclaw config set tools.media.audio.enabled true
openclaw config set tools.media.audio.models '[{"provider":"openai","model":"gpt-4o-mini-transcribe"}]'
echo "[entrypoint] Config applied."

echo "[entrypoint] Starting proxy on 0.0.0.0:$PORT → 127.0.0.1:$GATEWAY_INTERNAL_PORT"
GATEWAY_INTERNAL_PORT="$GATEWAY_INTERNAL_PORT" PORT="$PORT" node /app/proxy.js &

echo "[entrypoint] Launching OpenClaw gateway on 127.0.0.1:$GATEWAY_INTERNAL_PORT"
exec openclaw gateway run --port "$GATEWAY_INTERNAL_PORT" --bind loopback --auth token --allow-unconfigured
