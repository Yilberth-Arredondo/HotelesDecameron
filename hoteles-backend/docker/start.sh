#!/bin/bash
set -e

cd /app

# Asegurar que existe la ruta /api/health
cat >> routes/api.php << 'EOF'

Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});
EOF

php artisan config:clear
php artisan route:cache
php artisan migrate --force || true

echo "✅ Starting on port ${PORT:-8080}"
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8080}