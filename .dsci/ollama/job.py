#!/usr/bin/env python3

print("=== Starting Ollama LLM Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access Ollama configuration from jobs.yaml
ollama_config = cfg.get('ollama', {})
llm_model = ollama_config.get('model', 'mistral')
ollama_port = ollama_config.get('port', 11434)

print(f"Ollama Configuration:")
print(f"  Model: {llm_model}")
print(f"  Port: {ollama_port}")

# Run Ollama setup tasks
run_task('start_ollama', {
    'ollama_port': str(ollama_port)
})

run_task('pull_model', {
    'llm_model': llm_model
})

print("=== Ollama Setup Complete ===")
