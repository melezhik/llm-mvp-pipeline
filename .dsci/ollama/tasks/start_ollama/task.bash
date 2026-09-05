#!/bin/bash
set -e

echo "Starting Ollama container..."

# Set Ollama image
OLLAMA_IMAGE="ollama/ollama:latest"

# Pull image
docker pull $OLLAMA_IMAGE

# Start Ollama container
docker run -d \
  --name ollama \
  --restart always \
  --network llm-mvp \
  -v ollama-models:/root/.ollama \
  -p 11434:11434 \
  $OLLAMA_IMAGE

echo "Ollama container started"

# Wait for Ollama to be ready
echo "Waiting for Ollama to be ready..."
sleep 10

for i in {1..30}; do
  if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "Ollama is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 5
done

update_state({
  'ollama_running': True,
  'ollama_port': 11434
})
