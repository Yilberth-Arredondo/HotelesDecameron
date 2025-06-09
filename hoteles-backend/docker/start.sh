#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."

# Railway siempre proporciona PORT
PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Configurar PHP-FPM
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.d/www.conf << EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
clear_env = no
catch_workers_output = yes
EOF

# Configurar Nginx para usar el puerto de Railway
echo "🔧 Configurando Nginx para puerto $PORT..."
sed -i "s/listen 8080 default_server;/listen $PORT default_server;/g" /etc/nginx/sites-available/default
sed -i "s/listen \[::\]:8080 default_server;/listen \[::\]:$PORT default_server;/g" /etc/nginx/sites-available/default

# Verificar configuración de Nginx
echo "🔍 Verificando configuración de Nginx..."
nginx -t

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando conexión a PostgreSQL..."
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base de datos: $DB_DATABASE"

# Contador de intentos
attempts=0
max_attempts=30

until PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_DATABASE" -c '\q' 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ $attempts -eq $max_attempts ]; then
        echo "❌ No se pudo conectar a PostgreSQL después de $max_attempts intentos"
        exit 1
    fi
    echo "PostgreSQL no está listo - intento $attempts/$max_attempts"
    sleep 2
done

echo "✅ PostgreSQL está listo!"

# Antes de ejecutar migraciones
echo "🔧 Configurando nombre de tabla de migraciones..."
export MIGRATIONS_TABLE="migrations"
php artisan config:clear

echo "🔄 Ejecutando migraciones frescas..."
php artisan migrate:fresh --force --verbose || {
    echo "❌ Error en migraciones. Mostrando detalles:"
    php artisan migrate:status
    exit 1
}

echo "🌱 Ejecutando seeders..."
php artisan db:seed --force

# Verificar si hay datos
echo "📊 Verificando datos..."
HOTEL_COUNT=$(php artisan tinker --execute="echo \App\Models\Hotel::count();" 2>/dev/null | tail -1)

if [ "$HOTEL_COUNT" = "0" ] || [ -z "$HOTEL_COUNT" ]; then
    echo "🌱 Base de datos vacía, ejecutando seeders..."
    php artisan db:seed --force || echo "⚠️ Seeders no ejecutados"
else
    echo "✅ Base de datos contiene $HOTEL_COUNT hoteles"
fi

# Limpiar y optimizar caché
echo "🧹 Optimizando aplicación..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
# Configurar supervisor
mkdir -p /etc/supervisor/conf.d
cat > /etc/supervisor/conf.d/laravel.conf << EOF
[program:php-fpm]
command=php-fpm
autostart=true
autorestart=true
stderr_logfile=/var/log/php-fpm.err.log
stdout_logfile=/var/log/php-fpm.out.log

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/var/log/nginx.err.log
stdout_logfile=/var/log/nginx.out.log
EOF

echo "✅ Aplicación lista!"
echo "🌐 Servidor escuchando en puerto $PORT"
echo "📍 URL de la aplicación: $APP_URL"

# Añadir este comando antes de exec supervisord para verificar
echo "✅ Verificando si PHP-FPM puede ejecutar código PHP..."
php -r "echo 'PHP funcionando';"

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf