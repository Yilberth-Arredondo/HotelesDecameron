#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

# Configurar PHP-FPM - Más simple y directo
cat > /usr/local/etc/php-fmp.conf << EOF
[global]
daemonize = no
error_log = /proc/self/fd/2

[www]
listen = 127.0.0.1:9000
listen.allowed_clients = 127.0.0.1
user = www-data
group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
catch_workers_output = yes
EOF

# Configurar Nginx - Más simple
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
error_log stderr;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;
    
    server {
        listen $PORT;
        root /app/public;
        index index.php;
        
        location / {
            try_files \$uri /index.php?\$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
EOF

# Preparar Laravel
cd /app
chown -R www-data:www-data .
chmod -R 755 .
chmod -R 775 storage bootstrap/cache

# Setup rápido
php artisan config:clear
php artisan migrate --force || true
php artisan config:cache
php artisan route:cache

# Archivo de test
echo "<?php phpinfo();" > public/info.php
echo "<?php echo json_encode(['status'=>'ok','time'=>date('c')]);" > public/health.php

# Usar supervisor simple
cat > /etc/supervisor/conf.d/app.conf << EOF
[supervisord]
nodaemon=true

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
EOF

echo "✅ Iniciando con Supervisor..."
exec supervisord -c /etc/supervisor/conf.d/app.conf