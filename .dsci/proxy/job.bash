#!/bin/bash
set -e

echo "=== Starting Nginx Reverse Proxy Setup ==="

# Run proxy setup tasks
run_task "configure_nginx"
run_task "start_nginx"

echo "=== Nginx Reverse Proxy Setup Complete ==="
