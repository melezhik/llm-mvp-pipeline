#!/bin/bash
set -e

echo "Waiting for Open WebUI to be ready..."

WEBUI_PORT="${WEBUI_PORT:-3000}"

for i in {1..60}; do
  if curl -s http://localhost:$WEBUI_PORT > /dev/null 2>&1; then
    echo "Open WebUI is ready at http://localhost:$WEBUI_PORT"
    break
  fi
  echo "Waiting for WebUI... ($i/60)"
  sleep 2
done

echo "Open WebUI initialization complete"
