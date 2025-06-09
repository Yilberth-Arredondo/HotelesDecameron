#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."

# Railway siempre proporciona PORT
PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Crear directorios necesarios
mkdir -p /var/log/supervisor /run/php

# Configurar PHP-FPM de manera simplificada
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.conf << EOF
[global]
error_log = /proc/self/fd/2
daemonize = no

[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
clear_env = no
catch_workers_output = yes
decorate_workers_output = no
EOF

# Configurar Nginx
echo "🔧 Configurando Nginx para puerto $PORT..."
cat > /etc/nginx/sites-available/default << EOF
server {
    listen $PORT default_server;
    listen [::]:$PORT default_server;
    
    root /app/public;
    index index.php index.html;
    
    server_name _;
    
    access_log /dev/stdout;
    error_log /dev/stderr;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Configurar nginx.conf principal
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /dev/stderr;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /dev/stdout;

    gzip on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Verificar configuración de Nginx
echo "🔍 Verificando configuración de Nginx..."
nginx -t

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando conexión a PostgreSQL..."
echo "   Host: $DB_HOST"

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

# Configurar la aplicación Laravel
cd /app

# Asegurar permisos correctos
chown -R www-data:www-data /app/storage /app/bootstrap/cache
chmod -R 775 /app/storage /app/bootstrap/cache

# Limpiar caché
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Ejecutar migraciones
echo "🔄 Ejecutando migraciones..."
php artisan migrate:fresh --force --seed

# Optimizar para producción
echo "🧹 Optimizando aplicación..."
php artisan config:cache
php artisan route:cache

# Iniciar PHP-FPM directamente para ver errores
echo "🚀 Iniciando PHP-FPM..."
php-fpm -F &
PHP_FPM_PID=$!

# Esperar un momento para que PHP-FPM inicie
sleep 2

# Verificar si PHP-FPM está ejecutándose
if ! kill -0 $PHP_FPM_PID 2>/dev/null; then
    echo "❌ PHP-FPM falló al iniciar"
    exit 1
fi

echo "✅ PHP-FPM iniciado correctamente"

# Iniciar Nginx
echo "🚀 Iniciando Nginx..."
nginx -g "daemon off;"