# Deployment Guide

## Quick Start

### Option 1: Using DSCI (Recommended for Infrastructure)

1. **Configure DSCI**
   ```bash
   # Edit ~/.dsci.toml
   cat >> ~/.dsci.toml << 'EOF'
   DsciAllowLocalhostModeRepos = [
     "melezhik/llm-mvp-pipeline"
   ]
   EOF
   ```

2. **Restart DSCI Runner**
   ```bash
   # In your DSCI runner directory
   ./dsci-runner
   ```

3. **Push Pipeline**
   ```bash
   cd llm-mvp-pipeline
   git add -A
   git commit -m "Deploy LLM MVP infrastructure"
   git push
   ```

The pipeline will execute automatically and set up all services.

### Option 2: Using Docker Compose (Quick Testing)

```bash
# Clone repository
git clone <repo-url> llm-mvp-pipeline
cd llm-mvp-pipeline

# Start all services
docker-compose up -d

# Wait for services to initialize
sleep 30

# Verify
docker-compose ps
curl http://localhost/health
```

## Environment Variables

Customize deployment via environment variables:

```bash
# LLM Configuration
export LLM_MODEL=mistral          # Model: mistral, llama2, neural-chat, orca, etc.
export OLLAMA_PORT=11434          # Ollama API port

# Database Configuration
export DB_USER=postgres            # PostgreSQL user
export DB_PASSWORD=postgres123     # PostgreSQL password
export DB_NAME=mvp_db              # Database name
export DB_PORT=5432                # Database port

# API Configuration
export MVP_PORT=8000               # MVP backend port
export WEBUI_PORT=3000             # Web UI port
export NGINX_PORT=80                # Reverse proxy port
```

## Service Endpoints

Once deployed, access services at:

| Service | URL | Purpose |
|---------|-----|----------|
| WebUI | http://localhost:3000 | LLM chat interface |
| MVP API | http://localhost:8000 | Backend API & Swagger docs |
| Ollama | http://localhost:11434 | Direct LLM API |
| Health | http://localhost/health | Health check |
| Nginx | http://localhost | Main reverse proxy |

## Verifying Deployment

### Check Running Containers
```bash
docker ps
```

Expected output:
- ollama
- postgres
- open-webui
- mvp-backend
- nginx

### Check Service Logs
```bash
# Ollama logs
docker logs -f ollama

# WebUI logs
docker logs -f open-webui

# MVP API logs
docker logs -f mvp-backend

# Database logs
docker logs -f postgres

# Nginx logs
docker logs -f nginx
```

### Health Checks
```bash
# General health
curl http://localhost/health

# API health
curl http://localhost:8000/health

# Available models
curl http://localhost:8000/models

# WebUI
curl http://localhost:3000

# Ollama status
curl http://localhost:11434/api/tags
```

## Testing the Pipeline

### Test MVP API

```bash
# List available models
curl -X GET http://localhost:8000/models

# Send chat message
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, what are you?",
    "model": "mistral",
    "stream": false
  }'
```

### Test Database

```bash
# Connect to PostgreSQL
docker exec -it postgres psql -U postgres -d mvp_db

# List tables
\dt

# Query users table
SELECT * FROM users;

# Exit
\q
```

## Scaling & Customization

### Add More LLM Models

```bash
# Pull additional models
docker exec ollama ollama pull llama2
docker exec ollama ollama pull neural-chat
docker exec ollama ollama pull orca

# Verify
curl http://localhost:8000/models
```

### Increase Resources

For large models (70B+), increase VM resources:

```bash
# Edit docker-compose or DSCI tasks to add resource limits
environment:
  OLLAMA_MEMORY: 32G  # Allocate more RAM
```

### Enable HTTPS

Add SSL certificate to Nginx:

```bash
# Place certificates in a volume
# Update nginx.conf with SSL directives
# Restart nginx container
```

## Troubleshooting

### Ollama Model Not Downloaded

```bash
# Check Ollama logs
docker logs -f ollama

# Models take time to download (10-70GB depending on model size)
# Monitor disk space
df -h
```

### WebUI Can't Connect to Ollama

```bash
# Verify network connectivity
docker exec open-webui curl http://ollama:11434/api/tags

# Check OLLAMA_BASE_URL environment variable
docker inspect open-webui | grep OLLAMA_BASE_URL
```

### MVP API Connection Errors

```bash
# Check API logs
docker logs -f mvp-backend

# Verify database connection
docker exec mvp-backend curl http://postgres:5432

# Check environment variables
docker inspect mvp-backend | grep DATABASE_URL
```

### High Memory Usage

```bash
# Monitor container resources
docker stats

# Reduce LLM model size
export LLM_MODEL=orca  # Smaller model
# Re-run pipeline
```

## Cleanup

### Stop All Services

```bash
# Using docker-compose
docker-compose down

# OR using docker commands
docker stop ollama postgres open-webui mvp-backend nginx
docker rm ollama postgres open-webui mvp-backend nginx
```

### Remove Data Volumes (WARNING: Data Loss)

```bash
docker volume rm ollama-models webui-data postgres-data nginx-config
```

### Full Cleanup

```bash
# Remove all containers, volumes, and networks
docker system prune -a --volumes
```

## Performance Tuning

### Optimize Ollama

```bash
# Use GPU acceleration (if available)
docker run -d \
  --name ollama \
  --gpus all \
  ollama/ollama:latest
```

### Optimize PostgreSQL

Update docker-compose.yml with:

```yaml
environment:
  POSTGRES_INITDB_ARGS: "-c shared_buffers=256MB -c effective_cache_size=1GB"
```

### Nginx Caching

Add to nginx.conf upstream blocks:

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m;
proxy_cache api_cache;
proxy_cache_valid 200 1m;
```

## Monitoring

Monitor services with:

```bash
# Real-time resource usage
docker stats

# Detailed logs
docker logs -f --tail=100 <container>

# Network connectivity
docker network inspect llm-mvp

# Volume usage
docker volume ls
```

## Further Customization

Modify DSCI tasks to:
- Add authentication to services
- Configure backup strategies
- Set up monitoring/alerting
- Add cron jobs for maintenance
- Implement auto-scaling logic

Refer to DSCI documentation: https://github.com/melezhik/DSCI
