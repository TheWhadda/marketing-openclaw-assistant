FROM node:22-bookworm-slim

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Working directory for seed files
WORKDIR /app

# Copy workspace seed (agent context — copied to /data/workspace on first boot)
COPY workspace/ ./workspace-seed/

# Copy openclaw.json seed (config — copied to /data/.openclaw/ on first boot)
COPY openclaw.json ./openclaw.json

# Copy startup entrypoint
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Port exposed by the OpenClaw gateway
EXPOSE 8080

# Required Railway env vars (set in Railway dashboard, not here):
#   SETUP_PASSWORD          — protects /setup wizard
#   PORT=8080               — must match the exposed port
#   OPENCLAW_STATE_DIR      — /data/.openclaw
#   OPENCLAW_WORKSPACE_DIR  — /data/workspace
#   OPENCLAW_GATEWAY_TOKEN  — admin secret for Control UI
#   TELEGRAM_BOT_TOKEN      — from @BotFather
#   ANTHROPIC_API_KEY       — from console.anthropic.com

ENTRYPOINT ["/app/entrypoint.sh"]
