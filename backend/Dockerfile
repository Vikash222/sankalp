# ==============================================================================
# Sankalp - Production Docker Image for 100% Free Cloud Hosting (Render / Koyeb / Railway)
# ==============================================================================
FROM php:8.4-cli-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies and required PHP extensions (including zip & mbstring)
RUN apk add --no-cache \
    curl \
    git \
    unzip \
    libzip-dev \
    sqlite-dev \
    libpq-dev \
    oniguruma-dev \
    && docker-php-ext-install pdo pdo_sqlite pdo_mysql pdo_pgsql bcmath opcache pcntl zip mbstring

# Install Composer 2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy full application code first so autoloader targets (app/, database/) exist
COPY . .

# Install dependencies (production-optimized with platform requirements ignored)
RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts \
    --ignore-platform-reqs

# Ensure storage, cache, and database permissions
RUN mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
    && touch database/database.sqlite \
    && chmod -R 777 storage bootstrap/cache database

# Entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
