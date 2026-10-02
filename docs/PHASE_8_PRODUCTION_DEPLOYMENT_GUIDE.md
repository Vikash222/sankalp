# Phase 8: Production Deployment & VPS Infrastructure Guide

This guide provides the complete, tested instructions to provision, secure, and deploy the **Sankalp** backend on a clean **Ubuntu 24.04 or 22.04 LTS VPS** (e.g., Hetzner, DigitalOcean, AWS EC2, Linode).

---

## 1. Architecture Overview

```
                          ┌─────────────────────────────┐
                          │   Mobile Clients (Flutter)  │
                          └──────────────┬──────────────┘
                                         │ HTTPS (TLS 1.3)
                                         ▼
                          ┌─────────────────────────────┐
                          │      Nginx (Reverse Proxy)  │
                          │   Port 443 / HTTP2 / HSTS   │
                          │   Rate Limiting & Gzip      │
                          └──────────────┬──────────────┘
                                         │ UNIX Domain Socket
                                         ▼
                          ┌─────────────────────────────┐
                          │         PHP 8.3-FPM         │
                          │    OPcache + JIT Enabled    │
                          └──────┬───────────────┬──────┘
                                 │               │
                 MySQL Queries   ▼               ▼   Redis Operations
                   ┌───────────────────┐   ┌───────────────────┐
                   │      MySQL 8      │   │    Redis Server   │
                   │  utf8mb4_unicode  │   │  Cache, Sessions  │
                   │  Persistent Data  │   │   Queue Messages  │
                   └───────────────────┘   └─────────▲─────────┘
                                                     │
                                           Pops Jobs │
                                                     │
                                           ┌─────────┴─────────┐
                                           │ Supervisor Worker │
                                           │  3x Queue Workers │
                                           └───────────────────┘
```

---

## 2. Server Provisioning & Security Hardening

### Step 2.1: Update Server Packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip zip software-properties-common fail2ban ufw htop
```

### Step 2.2: Configure UFW Firewall
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (for Let's Encrypt validation)
sudo ufw allow 443/tcp   # HTTPS
sudo ufw --force enable
sudo ufw status verbose
```

---

## 3. Install PHP 8.3 & Dependencies

```bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

sudo apt install -y php8.3-fpm php8.3-cli php8.3-mysql php8.3-mbstring \
    php8.3-xml php8.3-bcmath php8.3-curl php8.3-zip php8.3-intl \
    php8.3-redis php8.3-opcache

# Verify PHP installation
php -v
php -m | grep -E 'pdo_mysql|redis|mbstring|bcmath'
```

### Install Composer 2
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

---

## 4. Install & Configure MySQL 8

```bash
sudo apt install -y mysql-server
sudo systemctl enable --now mysql
```

### Create Production Database and Dedicated User
Log in to MySQL as root:
```bash
sudo mysql
```

Execute the following SQL commands:
```sql
CREATE DATABASE IF NOT EXISTS sankalp_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'sankalp_user'@'127.0.0.1' IDENTIFIED BY 'SECURE_PASSWORD_32_CHARACTERS_LONG';

GRANT ALL PRIVILEGES ON sankalp_production.* TO 'sankalp_user'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT;
```

---

## 5. Install & Configure Redis

```bash
sudo apt install -y redis-server
sudo systemctl enable --now redis-server

# Test connection
redis-cli ping
# Expected output: PONG
```

---

## 6. Install & Configure Nginx Web Server

```bash
sudo apt install -y nginx
sudo systemctl enable --now nginx
```

### Install Sankalp Nginx Configuration
```bash
# Copy configuration from deploy directory
sudo cp /var/www/sankalp/backend/deploy/nginx/sankalp.conf /etc/nginx/sites-available/sankalp.conf

# Enable site
sudo ln -sf /etc/nginx/sites-available/sankalp.conf /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test syntax
sudo nginx -t
```

---

## 7. Install Let's Encrypt SSL via Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx

# Obtain and configure automated certificate
sudo certbot --nginx -d api.sankalp.app --non-interactive --agree-tos --email admin@sankalp.app

# Test automatic renewal
sudo certbot renew --dry-run
```

---

## 8. Deploy Application Codebase

### Step 8.1: Clone and Set File Permissions
```bash
sudo mkdir -p /var/www/sankalp
sudo git clone https://github.com/your-org/sankalp.git /var/www/sankalp
cd /var/www/sankalp/backend

# Ensure web server ownership
sudo chown -R www-data:www-data /var/www/sankalp
sudo chmod -R 775 storage bootstrap/cache
```

### Step 8.2: Configure Environment
```bash
cd /var/www/sankalp/backend
sudo -u www-data cp deploy/../.env.production.example .env
sudo -u www-data nano .env   # Update APP_URL, DB_PASSWORD, AI_PROVIDER, and API keys
sudo -u www-data php artisan key:generate
```

### Step 8.3: Install Composer Dependencies & Run Migrations
```bash
cd /var/www/sankalp/backend
sudo -u www-data composer install --no-dev --optimize-autoloader --no-interaction
sudo -u www-data php artisan migrate --force
sudo -u www-data php artisan db:seed --force
```

### Step 8.4: Cache Configurations
```bash
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache
sudo -u www-data php artisan event:cache
```

---

## 9. Background Queue Worker Setup (Supervisor)

```bash
sudo apt install -y supervisor

# Copy configuration
sudo cp /var/www/sankalp/backend/deploy/supervisor/sankalp-worker.conf /etc/supervisor/conf.d/sankalp-worker.conf

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start sankalp-worker:*

# Check worker health
sudo supervisorctl status
```

---

## 10. Automated Task Scheduler (Cron or Systemd)

### Option A: Using Crontab
```bash
sudo cp /var/www/sankalp/backend/deploy/cron/sankalp-scheduler /etc/cron.d/sankalp-scheduler
sudo chmod 0644 /etc/cron.d/sankalp-scheduler
```

### Option B: Using Systemd Timer (Recommended for Modern Linux)
```bash
sudo cp /var/www/sankalp/backend/deploy/systemd/sankalp-scheduler.service /etc/systemd/system/
sudo cp /var/www/sankalp/backend/deploy/systemd/sankalp-scheduler.timer /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now sankalp-scheduler.timer

# Verify timer execution status
sudo systemctl list-timers --all | grep sankalp
```

---

## 11. Automated Daily Backups

Set up automated daily database dumps with 14-day retention:
```bash
sudo mkdir -p /var/backups/sankalp
sudo chmod 700 /var/backups/sankalp

# Add nightly cron at 02:00 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /var/www/sankalp/backend/deploy/scripts/backup.sh >> /var/log/sankalp_backup.log 2>&1") | crontab -
```

---

## 12. Ongoing Deployments (Zero-Downtime)

To deploy new releases from Git:
```bash
sudo /var/www/sankalp/backend/deploy/scripts/deploy.sh main
```

---

## 13. Health Check & Verification Checklist

Run these commands to verify every layer of your production stack:

| Component | Verification Command | Expected Result |
| :--- | :--- | :--- |
| **Nginx** | `systemctl status nginx` | `Active: active (running)` |
| **PHP-FPM** | `systemctl status php8.3-fpm` | `Active: active (running)` |
| **MySQL** | `mysqladmin ping -u sankalp_user -p` | `mysqld is alive` |
| **Redis** | `redis-cli ping` | `PONG` |
| **Supervisor** | `supervisorctl status` | 3x `sankalp-worker` status `RUNNING` |
| **API Health** | `curl -k https://api.sankalp.app/api/v1/challenges` | HTTP 200 JSON array |
| **Scheduler** | `tail -f /var/log/syslog \| grep CRON` | Ran every 1 min |
