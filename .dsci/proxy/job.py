#!/usr/bin/env python3

print("=== Starting Nginx Reverse Proxy Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access services configuration from jobs.yaml
services_config = cfg.get('services', {})
ollama_config = cfg.get('ollama', {})

webui_port = services_config.get('webui_port', 3000)
mvp_port = services_config.get('mvp_port', 8000)
nginx_port = services_config.get('nginx_port', 80)
ollama_port = ollama_config.get('port', 11434)

print(f"Nginx Reverse Proxy Configuration:")
print(f"  Nginx Port: {nginx_port}")
print(f"  WebUI Port: {webui_port}")
print(f"  MVP Port: {mvp_port}")
print(f"  Ollama Port: {ollama_port}")

# Run proxy setup tasks
run_task('configure_nginx', {
    'webui_port': str(webui_port),
    'mvp_port': str(mvp_port),
    'ollama_port': str(ollama_port),
    'nginx_port': str(nginx_port)
})

run_task('start_nginx', {
    'nginx_port': str(nginx_port),
    'webui_port': str(webui_port),
    'mvp_port': str(mvp_port)
})

print("=== Nginx Reverse Proxy Setup Complete ===")
