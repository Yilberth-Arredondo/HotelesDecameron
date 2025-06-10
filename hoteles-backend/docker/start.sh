#!/bin/bash
set -e

echo "🚀 Starting Laravel..."
PORT=${PORT:-8080}

cd /app

php artisan config:clear
php artisan migrate --force || true

# Crear un router simple para health check
cat > public/router.php << 'EOF'
<?php
if (PHP_SAPI == 'cli-server') {
    $uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
    
    // Health check para Railway
    if ($uri === '/' || $uri === '/health') {
        header('Content-Type: application/json');
        echo json_encode(['status' => 'ok', 'time' => date('c')]);
        return true;
    }
    
    // Si no es health check, dejar que Laravel maneje
    if ($uri !== '/' && file_exists(__DIR__.$uri)) {
        return false;
    }
    
    require_once __DIR__.'/index.php';
}
EOF

echo "✅ Server starting on port $PORT"
exec php -S 0.0.0.0:$PORT -t public/ public/router.php