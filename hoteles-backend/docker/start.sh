#!/bin/bash
trap '' TERM INT

cd /app
php artisan migrate --force || true

echo "Starting on port ${PORT:-8080}"
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080} --tries=0