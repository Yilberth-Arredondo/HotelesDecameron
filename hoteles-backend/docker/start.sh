#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
echo "⏰ Hora: $(date)"

# Railway SIEMPRE proporciona PORT
PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Crear directorios necesarios
mkdir -p /run/nginx /var/log/nginx

# Configurar PHP-FPM con configuración mínima
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.conf << EOF
[global]
error_log = /proc/self/fd/2
daemonize = no

[www]
user = www-data
group = www-data
listen = /run/php/php-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
catch_workers_output = yes
EOF

# Crear directorio para el socket
mkdir -p /run/php
chown www-data:www-data /run/php

# Configurar Nginx - NOTA: Usamos envsubst para asegurar que PORT se expanda
echo "🔧 Configurando Nginx para puerto $PORT..."
cat > /tmp/nginx.conf.template << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx/nginx.pid;
error_log stderr;

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
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    server {
        listen ${PORT} default_server;
        listen [::]:${PORT} default_server;
        
        root /app/public;
        index index.php index.html;
        
        server_name _;
        
        # Archivo de health check
        location = /health.php {
            try_files $uri =404;
            fastcgi_pass unix:/run/php/php-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Rutas de Laravel
        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }
        
        # Procesamiento de PHP
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass unix:/run/php/php-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Denegar acceso a archivos .ht*
        location ~ /\.ht {
            deny all;
        }
    }
}
EOF

# Expandir la variable PORT en la configuración
envsubst '${PORT}' < /tmp/nginx.conf.template > /etc/nginx/nginx.conf

# Verificar la configuración
echo "🔍 Verificando configuración de Nginx..."
nginx -t

# Preparar Laravel
cd /app

echo "🔐 Configurando permisos..."
chown -R www-data:www-data /app
chmod -R 755 /app
chmod -R 775 /app/storage /app/bootstrap/cache

# Crear archivo de health check simple
echo "<?php echo json_encode(['status' => 'ok', 'port' => $_SERVER['SERVER_PORT'] ?? 'unknown', 'time' => date('Y-m-d H:i:s')]);" > /app/public/health.php
chown www-data:www-data /app/public/health.php

echo "🧹 Preparando Laravel..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Migraciones (con manejo de errores)
echo "📦 Ejecutando migraciones..."
php artisan migrate --force || echo "⚠️  Migraciones ya ejecutadas"

# Optimizar
echo "⚡ Optimizando..."
php artisan config:cache
php artisan route:cache

# Usar supervisord para manejar ambos procesos
echo "🔧 Configurando Supervisor..."
cat > /etc/supervisor/conf.d/laravel.conf << EOF
[supervisord]
nodaemon=true
user=root
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid

[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
depends_on=php-fpm
EOF

echo ""
echo "✅ Configuración completa"
echo "📋 La aplicación estará disponible en:"
echo "   ${APP_URL}/health.php"
echo "   ${APP_URL}/api/health"
echo "   ${APP_URL}/api/hoteles"
echo ""
echo "🚀 Iniciando servicios con Supervisor..."

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/laravel.conf