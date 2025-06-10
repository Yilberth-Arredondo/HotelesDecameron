#!/bin/bash
set -e

echo "🚀 Starting Laravel..."
PORT=${PORT:-8080}

cd /app

php artisan config:clear
php artisan migrate --force || true

# Crear health check que Railway espera
cat > public/index.php << 'EOF'
<?php
if ($_SERVER['REQUEST_URI'] === '/') {
    echo json_encode(['status' => 'ok', 'time' => date('c')]);
    exit;
}
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);
$response->send();
$kernel->terminate($request, $response);
EOF

echo "✅ Server starting on port $PORT"
exec php -S 0.0.0.0:$PORT -t public/