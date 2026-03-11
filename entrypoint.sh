#!/bin/sh
set -e

STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
PORT="${PORT:-8080}"

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
# CLAUDE.md and skills are code, not user data — they must reflect the image.
# User-generated content (memories, sessions) is preserved because it lives
# in subdirectories not listed here.
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

# Apply config using `openclaw config set` (idempotent, writes proper metadata).
# This runs on every boot to ensure settings survive platform-triggered config rewrites.
# Seeding a raw openclaw.json is avoided — openclaw overwrites files lacking internal metadata.
echo "[entrypoint] Applying openclaw config..."
openclaw config set gateway.mode local
openclaw config set gateway.bind lan
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
  echo "[entrypoint] ERROR: OPENCLAW_GATEWAY_TOKEN is not set."
  exit 1
fi
# Clear stale device pairing state on every boot.
# In headless deployments paired.json accumulates ghost records that block all
# internal WebSocket connections (exec Session Send, etc.) with "pairing required".
# dangerouslyDisableDeviceAuth lets OpenClaw operate without completing pairing.
rm -f "$STATE_DIR/devices/paired.json" "$STATE_DIR/devices/pending.json"
openclaw config set gateway.trustedProxies '["10.0.0.0/8","127.0.0.1/32","::1/128"]'
openclaw config set gateway.controlUi.allowInsecureAuth true
openclaw config set gateway.controlUi.dangerouslyDisableDeviceAuth true
openclaw config set agents.defaults.workspace "$WORKSPACE_DIR"
openclaw config set agents.defaults.model.primary "${OPENCLAW_MODEL:-anthropic/claude-sonnet-4-5}"
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.streamMode partial
# Access control: TELEGRAM_ALLOWLIST=@user1,@user2,123456789 → allowlist mode.
# Leave unset to allow anyone to DM the bot (open mode).
if [ -n "$TELEGRAM_ALLOWLIST" ]; then
  ALLOW_JSON=$(printf '%s' "$TELEGRAM_ALLOWLIST" | sed 's/,/","/g; s/^/["/; s/$/"]/')
  echo "[entrypoint] Telegram allowlist: $ALLOW_JSON"
  openclaw config set channels.telegram.dmPolicy allowlist
  openclaw config set channels.telegram.allowFrom "$ALLOW_JSON"
else
  openclaw config set channels.telegram.dmPolicy open
  openclaw config set channels.telegram.allowFrom '["*"]'
fi
openclaw config set session.reset.mode daily
openclaw config set session.reset.atHour 4
openclaw config set session.reset.idleMinutes 240
# Voice: disable TTS output and enable voice message transcription via OpenAI.
# OPENAI_API_KEY must be set in the platform dashboard for transcription to work.
openclaw config set messages.tts.auto off
openclaw config set tools.media.audio.enabled true
openclaw config set tools.media.audio.models '[{"provider":"openai","model":"gpt-4o-mini-transcribe"}]'
echo "[entrypoint] Config applied."

echo "[entrypoint] Launching OpenClaw gateway on 0.0.0.0:$PORT"
exec openclaw gateway run --port "$PORT" --bind lan --auth token --allow-unconfigured
