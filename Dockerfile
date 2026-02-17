FROM node:22-bookworm-slim

# git is required by some openclaw transitive dependencies during install
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# pnpm is built into Node 22 via corepack — no extra install needed.
# It uses a content-addressable store with hard links so memory usage
# during install is much lower than npm's flat copy approach.
RUN corepack enable pnpm

WORKDIR /app

# Install dependencies first (Railway caches this layer until package.json changes)
COPY package.json ./
RUN pnpm install --prod --no-lockfile

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
