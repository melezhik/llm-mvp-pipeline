#!/bin/bash
set -e

echo "=== Starting Ollama LLM Setup ==="

# Get infrastructure state
dict=$(get_state)
echo "Infrastructure state: $dict"

# Run Ollama setup tasks
run_task "start_ollama"
run_task "pull_model"

echo "=== Ollama Setup Complete ==="
