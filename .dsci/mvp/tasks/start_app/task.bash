#!/bin/bash
set -e

echo "Starting MVP backend container..."

# Set MVP port
MVP_PORT="${MVP_PORT:-8000}"

# Get database and Ollama configuration from state
dict=$(get_state)

DB_USER="${DB_USER:-postgres}"
DB_PASSWORD="${DB_PASSWORD:-postgres123}"
DB_NAME="${DB_NAME:-mvp_db}"
OLLAMA_BASE_URL="http://ollama:11434"

# Stop and remove existing container if running
docker stop mvp-backend || true
docker rm mvp-backend || true

# Start MVP backend container
docker run -d \
  --name mvp-backend \
  --restart always \
  --network llm-mvp \
  -e OLLAMA_BASE_URL="$OLLAMA_BASE_URL" \
  -e DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@postgres:5432/$DB_NAME" \
  -p $MVP_PORT:8000 \
  mvp-backend:latest

echo "MVP backend container started on port $MVP_PORT"

# Wait for MVP to be ready
echo "Waiting for MVP backend to be ready..."
sleep 5

for i in {1..30}; do
  if curl -s http://localhost:$MVP_PORT/health > /dev/null 2>&1; then
    echo "MVP backend is ready at http://localhost:$MVP_PORT"
    break
  fi
  echo "Waiting for MVP backend... ($i/30)"
  sleep 2
done

update_state({
  'mvp_running': True,
  'mvp_port': "$MVP_PORT",
  'api_url': "http://localhost:$MVP_PORT"
})
