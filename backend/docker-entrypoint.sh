#!/bin/sh
set -e

# Ensure SQLite file exists if using sqlite
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    mkdir -p database
    touch database/database.sqlite
fi

# Run database migrations safely
php artisan config:clear || true
php artisan migrate --force || true

# Cache configurations for speed in production
if [ "$APP_ENV" = "production" ]; then
    php artisan config:cache || true
    php artisan route:cache || true
fi

PORT="${PORT:-8000}"
echo "Starting Sankalp API Server on port $PORT..."
exec php -S 0.0.0.0:$PORT -t public
