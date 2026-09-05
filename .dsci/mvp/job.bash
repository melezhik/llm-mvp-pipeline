#!/bin/bash
set -e

echo "=== Starting MVP Backend Setup ==="

# Run MVP backend tasks
run_task "build_app"
run_task "start_app"

echo "=== MVP Backend Setup Complete ==="
