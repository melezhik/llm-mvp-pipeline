#!/usr/bin/env python3

print("=== Starting PostgreSQL Database Setup ===")

# Get configuration from jobs.yaml via config() function
cfg = config()
print(f"Full config: {cfg}")

# Access database configuration from jobs.yaml
db_config = cfg.get('database', {})
db_user = db_config.get('user', 'postgres')
db_password = db_config.get('password', 'postgres123')
db_name = db_config.get('name', 'mvp_db')
db_port = db_config.get('port', 5432)

print(f"Database Configuration:")
print(f"  User: {db_user}")
print(f"  Name: {db_name}")
print(f"  Port: {db_port}")

# Pass database credentials to tasks
run_task('start_postgres', {
    'db_user': db_user,
    'db_password': db_password,
    'db_name': db_name,
    'db_port': str(db_port)
})

run_task('init_schema', {
    'db_user': db_user,
    'db_password': db_password,
    'db_name': db_name
})

print("=== PostgreSQL Setup Complete ===")
