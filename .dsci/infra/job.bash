#!/bin/bash
set -e

echo "=== Starting Infrastructure Setup ==="

# Run infrastructure setup tasks
run_task "install_docker"
run_task "setup_volumes"
run_task "create_networks"

echo "=== Infrastructure Setup Complete ==="
