#!/bin/bash
set -e

echo "Setting up Docker networks..."

# Create custom Docker network for inter-service communication
echo "Creating llm-mvp network..."
docker network create llm-mvp || echo "Network llm-mvp already exists"

echo "Network setup complete"

# Save state for other jobs
update_state({
  'network_created': True,
  'network_name': 'llm-mvp'
})
