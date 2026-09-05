#!/bin/bash
set -e

echo "Starting PostgreSQL container..."

# Set PostgreSQL password
DB_PASSWORD="${DB_PASSWORD:-postgres123}"
DB_USER="${DB_USER:-postgres}"
DB_NAME="${DB_NAME:-mvp_db}"

# Pull PostgreSQL image
docker pull postgres:15-alpine

# Stop and remove existing container if running
docker stop postgres || true
docker rm postgres || true

# Start PostgreSQL container
docker run -d \
  --name postgres \
  --restart always \
  --network llm-mvp \
  -e POSTGRES_PASSWORD="$DB_PASSWORD" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_DB="$DB_NAME" \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

echo "PostgreSQL container started"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 15

for i in {1..30}; do
  if docker exec postgres pg_isready -U $DB_USER > /dev/null 2>&1; then
    echo "PostgreSQL is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

update_state({
  'postgres_running': True,
  'db_user': "$DB_USER",
  'db_name': "$DB_NAME",
  'db_port': 5432,
  'db_password': "$DB_PASSWORD"
})
