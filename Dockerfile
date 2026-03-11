FROM node:22-bookworm-slim

# git is required by some openclaw transitive dependencies during install
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates curl python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies — package-lock.json is committed so Docker layer is cached
# between deploys as long as dependencies don't change.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Add local bin to PATH so entrypoint.sh can call `openclaw` directly
ENV PATH="/app/node_modules/.bin:$PATH"

# Default state/workspace dirs — Railway picks these up automatically.
# Override in Railway dashboard only if you need custom paths.
ENV OPENCLAW_STATE_DIR=/data/.openclaw
ENV OPENCLAW_WORKSPACE_DIR=/data/workspace

# Cap Node.js heap at 384 MB so V8 GC kicks in before hitting the
# Railway container memory limit (512 MB hobby / 8 GB pro).
# Increase this value if you're on a higher-memory Railway plan.
ENV NODE_OPTIONS="--max-old-space-size=384"

# Copy workspace seed (agent context — written to /data/workspace on first boot)
COPY workspace/ ./workspace-seed/

# Copy and make startup script executable
COPY entrypoint.sh ./entrypoint.sh
COPY yd-proxy.js ./yd-proxy.js
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
#   TELEGRAM_ALLOWLIST      — comma-separated @usernames or IDs (unset = open to everyone)
#   ANTHROPIC_API_KEY       — from console.anthropic.com

ENTRYPOINT ["/app/entrypoint.sh"]
