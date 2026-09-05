#!/bin/bash
set -e

echo "Starting Open WebUI container..."

# Set WebUI port
WEBUI_PORT="${WEBUI_PORT:-3000}"

# Pull Open WebUI image
docker pull ghcr.io/open-webui/open-webui:main

# Stop and remove existing container if running
docker stop open-webui || true
docker rm open-webui || true

# Start Open WebUI container
docker run -d \
  --name open-webui \
  --restart always \
  --network llm-mvp \
  -e OLLAMA_BASE_URL="http://ollama:11434" \
  -v webui-data:/app/backend/data \
  -p $WEBUI_PORT:8080 \
  ghcr.io/open-webui/open-webui:main

echo "Open WebUI container started on port $WEBUI_PORT"

update_state({
  'webui_running': True,
  'webui_port': "$WEBUI_PORT",
  'ollama_base_url': 'http://ollama:11434'
})
