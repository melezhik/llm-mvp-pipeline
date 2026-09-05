#!/bin/bash
set -e

echo "Starting Nginx reverse proxy..."

NGINX_PORT="${NGINX_PORT:-80}"

# Pull Nginx image
docker pull nginx:alpine

# Stop and remove existing container if running
docker stop nginx || true
docker rm nginx || true

# Start Nginx container
docker run -d \
  --name nginx \
  --restart always \
  --network llm-mvp \
  -v /tmp/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -p $NGINX_PORT:80 \
  nginx:alpine

echo "Nginx reverse proxy started on port $NGINX_PORT"

# Wait for Nginx to be ready
echo "Waiting for Nginx to be ready..."
sleep 3

for i in {1..10}; do
  if docker exec nginx nginx -t > /dev/null 2>&1; then
    echo "Nginx is ready"
    break
  fi
  echo "Waiting for Nginx... ($i/10)"
  sleep 1
done

echo ""
echo "================================"
echo "LLM MVP Infrastructure Complete!"
echo "================================"
echo ""
echo "Services are now running:"
echo "  - WebUI: http://localhost:3000 (or http://localhost if port 80)"
echo "  - MVP API: http://localhost:8000/docs (Swagger UI)"
echo "  - Ollama API: http://localhost:11434"
echo ""
echo "Verify with:"
echo "  docker ps"
echo "  curl http://localhost/health"
echo ""

update_state({
  'nginx_running': True,
  'deployment_complete': True,
  'services': {
    'webui': 'http://localhost:3000',
    'api': 'http://localhost:8000',
    'ollama': 'http://localhost:11434'
  }
})
