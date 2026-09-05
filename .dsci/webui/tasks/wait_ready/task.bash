#!/bin/bash
set -e

echo "Waiting for Open WebUI to be ready..."

# Get variables passed from job
webui_port="$webui_port"

echo "WebUI Port: $webui_port"

for i in {1..60}; do
  if curl -s http://localhost:$webui_port > /dev/null 2>&1; then
    echo "Open WebUI is ready at http://localhost:$webui_port"
    break
  fi
  echo "Waiting for WebUI... ($i/60)"
  sleep 2
done

echo "Open WebUI initialization complete"
