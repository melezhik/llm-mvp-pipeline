#!/bin/bash
set -e

echo "Starting Nginx reverse proxy..."

# Get variables from task
nginx_port="$nginx_port"
webui_port="$webui_port"
mvp_port="$mvp_port"

echo "Nginx Port: $nginx_port"
echo "WebUI Port: $webui_port"
echo "MVP Port: $mvp_port"

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
  -p $nginx_port:80 \
  nginx:alpine

echo "Nginx reverse proxy started on port $nginx_port"

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
echo "  - WebUI: http://localhost:$webui_port"
echo "  - MVP API: http://localhost:$mvp_port/docs"
echo "  - Ollama API: http://localhost:11434"
echo "  - Reverse Proxy: http://localhost:$nginx_port"
echo ""
echo "Verify with:"
echo "  docker ps"
echo "  curl http://localhost:$nginx_port/health"
echo ""

update_state({
  'nginx_running': 'true',
  'deployment_complete': 'true',
  'webui_url': "http://localhost:$webui_port",
  'api_url': "http://localhost:$mvp_port",
  'proxy_url': "http://localhost:$nginx_port"
})
