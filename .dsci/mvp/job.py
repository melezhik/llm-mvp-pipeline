#!/usr/bin/env python3

print("=== Starting MVP Backend Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access database and services configuration from jobs.yaml
db_config = cfg.get('database', {})
services_config = cfg.get('services', {})

db_user = db_config.get('user', 'postgres')
db_password = db_config.get('password', 'postgres123')
db_name = db_config.get('name', 'mvp_db')
db_host = 'postgres'
db_port = db_config.get('port', 5432)

mvp_port = services_config.get('mvp_port', 8000)
ollama_base_url = "http://ollama:11434"

print(f"MVP Configuration:")
print(f"  Database: {db_user}@{db_host}:{db_port}/{db_name}")
print(f"  MVP Port: {mvp_port}")
print(f"  Ollama Base URL: {ollama_base_url}")

# Pass configuration to tasks
run_task('build_app', {
    'db_user': db_user,
    'db_password': db_password,
    'db_name': db_name,
    'db_host': db_host,
    'db_port': str(db_port),
    'ollama_base_url': ollama_base_url,
    'mvp_port': str(mvp_port)
})

run_task('start_app', {
    'db_user': db_user,
    'db_password': db_password,
    'db_name': db_name,
    'db_host': db_host,
    'db_port': str(db_port),
    'ollama_base_url': ollama_base_url,
    'mvp_port': str(mvp_port)
})

print("=== MVP Backend Setup Complete ===")
