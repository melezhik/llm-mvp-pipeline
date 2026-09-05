#!/bin/bash
set -e

echo "=== Starting PostgreSQL Database Setup ==="

# Run database setup tasks
run_task "start_postgres"
run_task "init_schema"

echo "=== PostgreSQL Setup Complete ==="
