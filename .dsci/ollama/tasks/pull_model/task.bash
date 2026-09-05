#!/bin/bash
set -e

echo "Pulling LLM model..."

# Model to pull (default: mistral, alternatives: llama2, neural-chat, orca, etc.)
LLM_MODEL="${LLM_MODEL:-mistral}"

echo "Pulling model: $LLM_MODEL"
echo "This may take several minutes depending on model size..."

docker exec ollama ollama pull $LLM_MODEL

echo "Model pulled successfully"

update_state({
  'llm_model': "$LLM_MODEL",
  'model_ready': True
})
