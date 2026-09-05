#!/bin/bash
set -e

echo "Starting MVP backend container..."

# Get variables from task
db_user="$db_user"
db_password="$db_password"
db_name="$db_name"
db_host="$db_host"
db_port="$db_port"
ollama_base_url="$ollama_base_url"
mvp_port="$mvp_port"

echo "Configuration:"
echo "  Database: $db_user@$db_host:$db_port/$db_name"
echo "  Ollama URL: $ollama_base_url"
echo "  MVP Port: $mvp_port"

# Stop and remove existing container if running
docker stop mvp-backend || true
docker rm mvp-backend || true

# Start MVP backend container
docker run -d \
  --name mvp-backend \
  --restart always \
  --network llm-mvp \
  -e OLLAMA_BASE_URL="$ollama_base_url" \
  -e DATABASE_URL="postgresql://$db_user:$db_password@$db_host:$db_port/$db_name" \
  -p $mvp_port:8000 \
  mvp-backend:latest

echo "MVP backend container started on port $mvp_port"

# Wait for MVP to be ready
echo "Waiting for MVP backend to be ready..."
sleep 5

for i in {1..30}; do
  if curl -s http://localhost:$mvp_port/health > /dev/null 2>&1; then
    echo "MVP backend is ready at http://localhost:$mvp_port"
    break
  fi
  echo "Waiting for MVP backend... ($i/30)"
  sleep 2
done
