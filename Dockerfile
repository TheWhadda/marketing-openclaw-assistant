FROM node:22-bookworm-slim

WORKDIR /app

# Install dependencies separately for better layer caching.
# Railway rebuilds from this layer only when package.json changes.
COPY package.json ./
RUN npm install --omit=dev

# Add local bin to PATH so entrypoint.sh can call `openclaw` directly
ENV PATH="/app/node_modules/.bin:$PATH"

# Copy workspace seed (agent context — written to /data/workspace on first boot)
COPY workspace/ ./workspace-seed/

# Copy openclaw.json seed (config — written to /data/.openclaw on first boot)
COPY openclaw.json ./openclaw.json

# Copy and make startup script executable
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Port exposed by the OpenClaw gateway
EXPOSE 8080

# Required Railway env vars (set in Railway dashboard):
#   SETUP_PASSWORD          — protects /setup wizard
#   PORT=8080               — must match the exposed port
#   OPENCLAW_STATE_DIR      — /data/.openclaw
#   OPENCLAW_WORKSPACE_DIR  — /data/workspace
#   OPENCLAW_GATEWAY_TOKEN  — admin secret for Control UI
#   TELEGRAM_BOT_TOKEN      — from @BotFather
#   ANTHROPIC_API_KEY       — from console.anthropic.com

ENTRYPOINT ["/app/entrypoint.sh"]
