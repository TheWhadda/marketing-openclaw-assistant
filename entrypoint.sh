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

# Seed workspace with agent context (CLAUDE.md) on first boot only.
# User memories and session data in the workspace are preserved across deploys.
if [ ! -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
  echo "[entrypoint] First boot — seeding workspace from image..."
  cp -r /app/workspace-seed/. "$WORKSPACE_DIR/"
  echo "[entrypoint] Workspace seeded."
else
  echo "[entrypoint] Workspace already initialized, skipping full seed."
fi

# Always sync skills from the image so newly added skills are available
# without requiring a full first-boot reset.
if [ -d "/app/workspace-seed/skills" ]; then
  mkdir -p "$WORKSPACE_DIR/skills"
  cp -r /app/workspace-seed/skills/. "$WORKSPACE_DIR/skills/"
  echo "[entrypoint] Skills synced."
fi

# OPENCLAW_GATEWAY_TOKEN is required when binding to lan (all interfaces).
# Set it in the platform dashboard (Railway/Render): OPENCLAW_GATEWAY_TOKEN → any strong secret.
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
  echo "[entrypoint] ERROR: OPENCLAW_GATEWAY_TOKEN is not set."
  echo "[entrypoint] Add it in your platform dashboard: OPENCLAW_GATEWAY_TOKEN=<any secret>"
  exit 1
fi

# Apply config using `openclaw config set` (idempotent, writes proper metadata).
# This runs on every boot to ensure settings survive platform-triggered config rewrites.
# Seeding a raw openclaw.json is avoided — openclaw overwrites files lacking internal metadata.
echo "[entrypoint] Applying openclaw config..."
openclaw config set gateway.mode local
openclaw config set gateway.bind lan
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.dmPolicy open
openclaw config set channels.telegram.allowFrom '["*"]'
openclaw config set channels.telegram.streamMode partial
openclaw config set session.reset.mode daily
openclaw config set session.reset.atHour 4
openclaw config set session.reset.idleMinutes 240
# Disable browser relay tool — this deployment is headless (no Chrome extension possible).
openclaw config set tools.browser.enabled false || true
echo "[entrypoint] Config applied."

echo "[entrypoint] Launching OpenClaw gateway on 0.0.0.0:$PORT"
exec openclaw gateway run --port "$PORT" --bind lan --auth token --allow-unconfigured
