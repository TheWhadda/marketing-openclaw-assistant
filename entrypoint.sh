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
# On subsequent deploys the persisted workspace takes precedence.
if [ ! -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
  echo "[entrypoint] First boot — seeding workspace from image..."
  cp -r /app/workspace-seed/. "$WORKSPACE_DIR/"
  echo "[entrypoint] Workspace seeded."
else
  echo "[entrypoint] Workspace already initialized, skipping seed."
fi

# Seed openclaw.json config on first boot only.
# Includes Telegram channel config + model settings.
if [ ! -f "$STATE_DIR/openclaw.json" ]; then
  echo "[entrypoint] First boot — seeding openclaw.json..."
  cp /app/openclaw.json "$STATE_DIR/openclaw.json"
  echo "[entrypoint] openclaw.json seeded."
else
  echo "[entrypoint] openclaw.json already exists, skipping seed."
fi

echo "[entrypoint] Launching OpenClaw gateway on 0.0.0.0:$PORT"
exec openclaw gateway run --port "$PORT" --bind lan --allow-unconfigured
