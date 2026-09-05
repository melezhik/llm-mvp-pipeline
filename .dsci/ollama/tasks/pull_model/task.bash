#!/bin/bash
set -e

echo "Pulling LLM model..."

# Get model from task variable
llm_model="$llm_model"

echo "Pulling model: $llm_model"
echo "This may take several minutes depending on model size..."

docker exec ollama ollama pull $llm_model

echo "Model pulled successfully"
