# LLM MVP Infrastructure Pipeline

DSCI pipeline for installing a self-hosted LLM and MVP server on a single VM.

## Overview

This pipeline automates the deployment of:
- **Ollama** - Self-hosted LLM (Large Language Model) runtime
- **Open WebUI** - Web interface for LLM interaction
- **FastAPI** - MVP backend server
- **PostgreSQL** - Database service
- **Nginx** - Reverse proxy and load balancer

## Architecture

All services run as Docker containers on a single VM with:
- Persistent storage for models and data
- Network isolation via Docker networks
- Health checks and monitoring
- Automated startup and recovery

## Prerequisites

- VM with Docker/Podman installed
- Passwordless sudo configured for DSCI user
- SSH access enabled
- At least 8GB RAM recommended
- 50GB+ disk space for LLM models

## Pipeline Structure

```
.dsci/
├── jobs.yaml                 # Main pipeline definition
├── infra/                    # Infrastructure setup job
│   ├── job.bash
│   └── tasks/
│       ├── install_docker/
│       │   └── task.bash
│       ├── setup_volumes/
│       │   └── task.bash
│       └── create_networks/
│           └── task.bash
├── ollama/                   # Ollama LLM setup job
│   ├── job.bash
│   └── tasks/
│       ├── start_ollama/
│       │   └── task.bash
│       └── pull_model/
│           └── task.bash
├── webui/                    # Open WebUI setup job
│   ├── job.bash
│   └── tasks/
│       ├── start_webui/
│       │   └── task.bash
│       └── wait_ready/
│           └── task.bash
├── database/                 # PostgreSQL setup job
│   ├── job.bash
│   └── tasks/
│       ├── start_postgres/
│       │   └── task.bash
│       └── init_schema/
│           └── task.bash
├── mvp/                      # MVP backend setup job
│   ├── job.bash
│   └── tasks/
│       ├── build_app/
│       │   └── task.bash
│       └── start_app/
│           └── task.bash
└── proxy/                    # Nginx reverse proxy setup job
    ├── job.bash
    └── tasks/
        ├── configure_nginx/
        │   └── task.bash
        └── start_nginx/
            └── task.bash
```

## Running the Pipeline

### 1. Initial Setup

Enable infrastructure mode in DSCI configuration:

```toml
# ~/.dsci.toml
DsciAllowLocalhostModeRepos = [
  "melezhik/llm-mvp-pipeline"
]
```

Restart DSCI runner.

### 2. Push and Execute

```bash
git clone http://dsci-server/llm-mvp-pipeline.git
cd llm-mvp-pipeline
# Make changes if needed
git push
```

The pipeline will execute automatically and:
- Install Docker (if needed)
- Create Docker networks and volumes
- Start Ollama container with LLM support
- Deploy Open WebUI for LLM interaction
- Start PostgreSQL database
- Build and run MVP backend
- Configure Nginx reverse proxy

### 3. Access Services

After successful execution:

- **Open WebUI**: http://vm-ip:3000
- **MVP API**: http://vm-ip:8000
- **Direct Ollama API**: http://vm-ip:11434

## Configuration

Customize deployment via environment variables or configuration files:

- `LLM_MODEL`: Model to pull (default: `mistral`)
- `MVP_PORT`: Backend API port (default: `8000`)
- `WEBUI_PORT`: Web interface port (default: `3000`)
- `DB_PASSWORD`: PostgreSQL password

## Monitoring

Check service status:

```bash
docker ps
docker logs -f <container-id>
```

## Troubleshooting

### LLM Model Download Takes Long

Models are large (7B-70B parameters). Monitor progress with:

```bash
docker logs -f ollama
```

### Port Already in Use

Change port mappings in `mvp/tasks/start_app/task.bash` and `proxy/tasks/configure_nginx/task.bash`

### Disk Space Issues

LLM models consume significant space. Check:

```bash
df -h
docker system df
```

## Further Documentation

See DSCI documentation: https://github.com/melezhik/DSCI
