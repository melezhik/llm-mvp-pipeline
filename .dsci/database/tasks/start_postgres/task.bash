#!/bin/bash
set -e

echo "Starting PostgreSQL container..."

# Get variables passed from job
db_user="$db_user"
db_password="$db_password"
db_name="$db_name"
DB_PORT="5432"

echo "Database User: $db_user"
echo "Database Name: $db_name"

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
  -e POSTGRES_PASSWORD="$db_password" \
  -e POSTGRES_USER="$db_user" \
  -e POSTGRES_DB="$db_name" \
  -v postgres-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

echo "PostgreSQL container started"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 15

for i in {1..30}; do
  if docker exec postgres pg_isready -U $db_user > /dev/null 2>&1; then
    echo "PostgreSQL is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done
