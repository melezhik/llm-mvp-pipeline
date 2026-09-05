#!/bin/bash
set -e

echo "Setting up Docker volumes..."

# Create volumes for persistent storage
echo "Creating ollama-models volume..."
docker volume create ollama-models || echo "Volume ollama-models already exists"

echo "Creating webui-data volume..."
docker volume create webui-data || echo "Volume webui-data already exists"

echo "Creating postgres-data volume..."
docker volume create postgres-data || echo "Volume postgres-data already exists"

echo "Creating nginx-config volume..."
docker volume create nginx-config || echo "Volume nginx-config already exists"

echo "Volume setup complete"

# Save state for other jobs
update_state({
  'volumes_created': True,
  'ollama_volume': 'ollama-models',
  'webui_volume': 'webui-data',
  'postgres_volume': 'postgres-data',
  'nginx_volume': 'nginx-config'
})
