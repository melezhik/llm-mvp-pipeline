#!/bin/bash
set -e

echo "=== Starting Open WebUI Setup ==="

# Run WebUI setup tasks
run_task "start_webui"
run_task "wait_ready"

echo "=== Open WebUI Setup Complete ==="
