#!/bin/bash

echo "=== Información de Debugging ==="
echo "Puerto asignado: $PORT"
echo "URL de la aplicación: $APP_URL"
echo ""

echo "=== Estado de los servicios ==="
ps aux | grep -E "(nginx|php-fpm|supervisor)" | grep -v grep
echo ""

echo "=== Prueba de conectividad a PostgreSQL ==="
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_DATABASE" -c "SELECT version();" 2>&1
echo ""

echo "=== Verificación de PHP ==="
php -v
php -m | grep -E "(pdo|pgsql)"
echo ""

echo "=== Estado de Laravel ==="
cd /app
php artisan --version
php artisan config:show database.default
php artisan migrate:status 2>&1 | head -20
echo ""

echo "=== Prueba de rutas ==="
php artisan route:list --path=api 2>&1 | head -20
echo ""

echo "=== Permisos de directorios ==="
ls -la storage/
ls -la bootstrap/cache/
echo ""

echo "=== Logs recientes ==="
echo "--- Nginx Error Log ---"
tail -20 /var/log/nginx/error.log 2>/dev/null || echo "No hay logs de nginx error"
echo ""

echo "--- PHP-FPM Error Log ---"
tail -20 /var/log/php-fpm/error.log 2>/dev/null || echo "No hay logs de php-fpm"
echo ""

echo "--- Supervisor Log ---"
tail -20 /var/log/supervisor/supervisord.log 2>/dev/null || echo "No hay logs de supervisor"
echo ""

echo "--- Laravel Log ---"
tail -50 /app/storage/logs/laravel.log 2>/dev/null || echo "No hay logs de Laravel"
echo ""

echo "=== Test de endpoint ==="
curl -v http://localhost:${PORT:-8080}/api/health 2>&1
echo ""

echo "=== Configuración de Nginx ==="
cat /etc/nginx/sites-available/default | head -30
echo ""

echo "=== Estado de PHP-FPM ==="
if [ -S /var/run/php/php-fpm.sock ]; then
    echo "PHP-FPM socket existe"
else
    echo "PHP-FPM socket NO existe"
fi

if pgrep -x "php-fpm" > /dev/null; then
    echo "PHP-FPM está ejecutándose"
    pgrep -a php-fpm
else
    echo "PHP-FPM NO está ejecutándose"
fi