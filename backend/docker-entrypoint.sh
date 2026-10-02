#!/bin/sh
set -e

# Ensure SQLite file exists if using sqlite
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# Ensure storage directories and permissions exist
mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs
chmod -R 777 storage bootstrap/cache database 2>/dev/null || true

# Ensure APP_KEY exists
if [ -z "$APP_KEY" ]; then
    export APP_KEY="base64:3O7xYjK4vJ8hN2qA6wZ1mC9pL5tE8rU0yD2fX4bV7hQ="
    echo "Using default application key."
fi

# Clear old config cache to load new routes/settings
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true

# Run database migrations safely
php artisan migrate --force || true

PORT="${PORT:-8000}"
echo "Starting Sankalp API Server on port $PORT..."
exec php -S 0.0.0.0:$PORT -t public
