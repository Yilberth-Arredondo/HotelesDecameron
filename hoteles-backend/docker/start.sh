#!/bin/bash
set -e

echo "🚀 Iniciando Laravel en Railway..."
PORT=${PORT:-8080}

cd /app
php artisan config:clear
php artisan migrate --force || true
php artisan config:cache

echo '<?php echo json_encode(["status" => "ok", "port" => "'$PORT'", "time" => date("c")]);' > /app/public/health.php

echo "✅ Usando servidor PHP en puerto $PORT"
echo "📍 URL: ${APP_URL}"

# Esta línea funciona GARANTIZADO
exec php -S 0.0.0.0:$PORT -t public/ public/index.php