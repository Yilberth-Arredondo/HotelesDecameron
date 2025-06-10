#!/bin/bash
set -e

echo "🔍 Debug Mode"
echo "PORT: $PORT"
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_PASSWORD: ${DB_PASSWORD:0:3}***" # Mostrar solo primeros 3 chars

cd /app

# Test de conexión a DB
php -r "
try {
    \$pdo = new PDO('pgsql:host=${DB_HOST};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');
    echo '✅ DB connection OK\n';
} catch (Exception \$e) {
    echo '❌ DB Error: ' . \$e->getMessage() . '\n';
    exit(1);
}
"

# Si llegamos aquí, la DB funciona
php artisan config:clear
php artisan migrate --force

echo '<?php echo "OK";' > public/health.php

echo "🚀 Starting server..."
exec php -S 0.0.0.0:$PORT -t public/ public/index.php