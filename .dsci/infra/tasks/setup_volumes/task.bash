#!/bin/bash
set -e

echo "Setting up Docker volumes..."

# Get volumes from task variable (comma-separated)
IFS=',' read -ra VOLUMES <<< "$volumes"

for volume in "${VOLUMES[@]}"; do
    volume=$(echo $volume | xargs)  # Trim whitespace
    echo "Creating volume: $volume"
    docker volume create $volume || echo "Volume $volume already exists"
done

echo "Volume setup complete"

# Save state for other jobs
update_state({
  'volumes_created': 'true',
  'volumes': "$volumes"
})
