#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."

# Railway siempre proporciona PORT
PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Crear directorios necesarios para logs
mkdir -p /var/log/supervisor /var/log/nginx /var/log/php-fpm

# Configurar PHP-FPM
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.d/www.conf << EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
listen.allowed_clients = 127.0.0.1
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
clear_env = no
catch_workers_output = yes
php_admin_flag[log_errors] = on
php_admin_value[error_log] = /var/log/php-fpm/error.log
EOF

# Crear configuración principal de PHP-FPM
cat > /usr/local/etc/php-fpm.conf << EOF
[global]
error_log = /var/log/php-fpm/php-fpm.log
log_level = notice
daemonize = no
EOF

# Configurar Nginx dinámicamente
echo "🔧 Configurando Nginx para puerto $PORT..."
cat > /etc/nginx/sites-available/default << EOF
server {
    listen $PORT default_server;
    listen [::]:$PORT default_server;
    
    root /app/public;
    index index.php index.html;
    
    server_name _;
    
    # Logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
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
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_buffer_size 32k;
        fastcgi_buffers 4 32k;
        fastcgi_read_timeout 600;
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
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;

    gzip on;
    gzip_disable "msie6";

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

# Configurar la aplicación Laravel
echo "🔧 Configurando Laravel..."
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

# Crear configuración principal de supervisord
echo "🔧 Configurando Supervisor..."
cat > /etc/supervisor/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[unix_http_server]
file=/var/run/supervisor.sock

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[include]
files = /etc/supervisor/conf.d/*.conf
EOF

# Configurar programas de supervisor
mkdir -p /etc/supervisor/conf.d
cat > /etc/supervisor/conf.d/laravel.conf << EOF
[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
priority=5
stdout_logfile=/var/log/supervisor/php-fpm.log
stderr_logfile=/var/log/supervisor/php-fpm-error.log

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
priority=10
stdout_logfile=/var/log/supervisor/nginx.log
stderr_logfile=/var/log/supervisor/nginx-error.log
EOF

# Crear un script de healthcheck
cat > /app/public/health.php << 'EOF'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION
]);
EOF

echo "✅ Aplicación lista!"
echo "🌐 Servidor escuchando en puerto $PORT"
echo "📍 URL de la aplicación: $APP_URL"

# Iniciar supervisor
echo "🚀 Iniciando servicios..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf