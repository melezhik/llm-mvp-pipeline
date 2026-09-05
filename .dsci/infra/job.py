#!/usr/bin/env python3

print("=== Starting Infrastructure Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access Docker configuration from jobs.yaml
docker_config = cfg.get('docker', {})
network_name = docker_config.get('network', 'llm-mvp')
volumes = docker_config.get('volumes', ['ollama-models', 'postgres-data', 'webui-data', 'nginx-config'])

print(f"Docker Configuration:")
print(f"  Network: {network_name}")
print(f"  Volumes: {volumes}")

# Pass configuration to tasks
run_task('install_docker')
run_task('setup_volumes', {
    'network_name': network_name,
    'volumes': ','.join(volumes)
})
run_task('create_networks', {
    'network_name': network_name
})

print("=== Infrastructure Setup Complete ===")
