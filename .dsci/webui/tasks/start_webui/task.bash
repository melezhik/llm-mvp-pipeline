#!/bin/bash
set -e

echo "Starting Open WebUI container..."

# Get variables from task
webui_port="${webui_port:-3000}"
ollama_base_url="${ollama_base_url:-http://ollama:11434}"

echo "WebUI Port: $webui_port"
echo "Ollama Base URL: $ollama_base_url"

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
  -e OLLAMA_BASE_URL="$ollama_base_url" \
  -v webui-data:/app/backend/data \
  -p $webui_port:8080 \
  ghcr.io/open-webui/open-webui:main

echo "Open WebUI container started on port $webui_port"

update_state({
  'webui_running': 'true',
  'webui_port': "$webui_port",
  'ollama_base_url': "$ollama_base_url"
})
