#!/bin/bash
set -e

echo "Starting Ollama container..."

# Get port from task variable
ollama_port="${ollama_port:-11434}"

echo "Ollama Port: $ollama_port"

# Set Ollama image
OLLAMA_IMAGE="ollama/ollama:latest"

# Pull image
docker pull $OLLAMA_IMAGE

# Stop and remove existing container if running
docker stop ollama || true
docker rm ollama || true

# Start Ollama container
docker run -d \
  --name ollama \
  --restart always \
  --network llm-mvp \
  -v ollama-models:/root/.ollama \
  -p $ollama_port:11434 \
  $OLLAMA_IMAGE

echo "Ollama container started on port $ollama_port"

# Wait for Ollama to be ready
echo "Waiting for Ollama to be ready..."
sleep 10

for i in {1..30}; do
  if curl -s http://localhost:$ollama_port/api/tags > /dev/null 2>&1; then
    echo "Ollama is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 5
done

update_state({
  'ollama_running': 'true',
  'ollama_port': "$ollama_port"
})
