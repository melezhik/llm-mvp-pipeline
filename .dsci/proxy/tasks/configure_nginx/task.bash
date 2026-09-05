#!/bin/bash
set -e

echo "Configuring Nginx reverse proxy..."

# Get variables from task
webui_port="$webui_port"
mvp_port="$mvp_port"
ollama_port="$ollama_port"
nginx_port="$nginx_port"

echo "Port Configuration:"
echo "  WebUI: $webui_port"
echo "  MVP: $mvp_port"
echo "  Ollama: $ollama_port"
echo "  Nginx: $nginx_port"

# Create nginx config directory
mkdir -p /tmp/nginx
cd /tmp/nginx

# Create nginx configuration file
cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Upstream services
    upstream webui {
        server open-webui:8080;
    }

    upstream mvp_api {
        server mvp-backend:8000;
    }

    upstream ollama_api {
        server ollama:11434;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=chat_limit:10m rate=5r/s;

    # Main server block
    server {
        listen 80;
        server_name _;

        client_max_body_size 50M;
        proxy_connect_timeout 600s;
        proxy_send_timeout 600s;
        proxy_read_timeout 600s;

        # Root endpoint
        location / {
            root /usr/share/nginx/html;
            try_files $uri @webui;
        }

        # WebUI proxy
        location @webui {
            proxy_pass http://webui;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # MVP API endpoints
        location /api/ {
            limit_req zone=api_limit burst=20 nodelay;
            proxy_pass http://mvp_api/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Chat endpoint with stricter rate limiting
        location /api/chat {
            limit_req zone=chat_limit burst=5 nodelay;
            proxy_pass http://mvp_api/chat;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # Direct Ollama API access (optional)
        location /ollama/ {
            proxy_pass http://ollama_api/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Deny access to sensitive locations
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }
}
EOF

echo "Nginx configuration created"
