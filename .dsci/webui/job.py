#!/usr/bin/env python3

print("=== Starting Open WebUI Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access services configuration from jobs.yaml
services_config = cfg.get('services', {})
webui_port = services_config.get('webui_port', 3000)
ollama_base_url = "http://ollama:11434"

print(f"WebUI Configuration:")
print(f"  Port: {webui_port}")
print(f"  Ollama Base URL: {ollama_base_url}")

# Run WebUI setup tasks
run_task('start_webui', {
    'webui_port': str(webui_port),
    'ollama_base_url': ollama_base_url
})

run_task('wait_ready', {
    'webui_port': str(webui_port)
})

print("=== Open WebUI Setup Complete ===")
