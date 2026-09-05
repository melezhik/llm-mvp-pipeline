#!/bin/bash
set -e

echo "Setting up Docker networks..."

# Get network name from task variable
network_name="$network_name"

echo "Creating network: $network_name"
docker network create $network_name || echo "Network $network_name already exists"

echo "Network setup complete"

# Save state for other jobs
update_state({
  'network_created': 'true',
  'network_name': "$network_name"
})
