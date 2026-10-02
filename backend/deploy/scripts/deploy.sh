#!/usr/bin/env bash
# ==============================================================================
# Sankalp API - Zero-Downtime Production Deployment Script
# ==============================================================================
# Usage: ./deploy.sh [branch_name]
# Example: ./deploy.sh main
# ==============================================================================

set -euo pipefail

BRANCH="${1:-main}"
PROJECT_DIR="/var/www/sankalp/backend"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "=========================================================="
echo " Starting Sankalp Deployment at ${TIMESTAMP}"
echo " Target Branch: ${BRANCH}"
echo " Project Root: ${PROJECT_DIR}"
echo "=========================================================="

cd "${PROJECT_DIR}"

# 1. Activate Maintenance Mode with Secret Bypass
echo "==> [1/7] Activating maintenance mode..."
php artisan down --render="errors::503" --secret="sankalp-deploy-bypass" || true

# 2. Fetch Latest Source Code
echo "==> [2/7] Pulling latest changes from git origin/${BRANCH}..."
git fetch origin "${BRANCH}"
git reset --hard "origin/${BRANCH}"

# 3. Install Optimized PHP Dependencies
echo "==> [3/7] Installing production composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# 4. Run Database Migrations
echo "==> [4/7] Running database migrations..."
php artisan migrate --force

# 5. Clear and Rebuild Laravel Production Caches
echo "==> [5/7] Rebuilding production route, config, and view caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 6. Restart Background Queue Workers
echo "==> [6/7] Signaling queue workers to restart gracefully..."
php artisan queue:restart
if command -v supervisorctl &> /dev/null; then
    supervisorctl reread
    supervisorctl update
    supervisorctl restart sankalp-worker:* || true
fi

# 7. Bring Application Online
echo "==> [7/7] Bringing application back online..."
php artisan up

# Ensure Correct Permissions
echo "==> Ensuring correct file ownership & permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

COMMIT_HASH=$(git rev-parse --short HEAD)
echo "=========================================================="
echo " Sankalp Deployment Complete Successfully!"
echo " Commit Deployed: ${COMMIT_HASH}"
echo " Finished at: $(date +"%Y-%m-%d %H:%M:%S")"
echo "=========================================================="
