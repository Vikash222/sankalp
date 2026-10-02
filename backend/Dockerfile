# ==============================================================================
# Sankalp - Production Docker Image for 100% Free Cloud Hosting (Render / Koyeb / Railway)
# ==============================================================================
FROM php:8.3-cli-alpine

# Install system dependencies and required PHP extensions
RUN apk add --no-cache \
    curl \
    git \
    unzip \
    libzip-dev \
    sqlite-dev \
    libpq-dev \
    oniguruma-dev \
    && docker-php-ext-install pdo pdo_sqlite pdo_mysql pdo_pgsql bcmath opcache pcntl

# Install Composer 2
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer specifications
COPY composer.json composer.lock ./

# Install dependencies (production-optimized)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copy full application code
COPY . .

# Run autoload optimization
RUN composer dump-autoload --optimize

# Ensure storage, cache, and database permissions
RUN mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
    && touch database/database.sqlite \
    && chmod -R 777 storage bootstrap/cache database

# Entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
