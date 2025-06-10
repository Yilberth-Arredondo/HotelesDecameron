#!/bin/bash
set -e

cd /app

php artisan config:clear
php artisan route:cache
php artisan migrate --force || true

echo "✅ Starting on port ${PORT:-8080}"
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080}