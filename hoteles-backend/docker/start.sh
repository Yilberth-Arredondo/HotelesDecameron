#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

# Setup Laravel
echo "🔧 Configurando Laravel..."
cd /app
php artisan config:clear
php artisan migrate --force || true

# Crear archivo de prueba
echo '<?php echo json_encode(["status" => "ok", "time" => date("c")]);' > /app/public/health.php

# Configuración de PHP-FPM
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.d/www.conf << EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
EOF

# Configuración de Nginx
echo "🔧 Configurando Nginx..."
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
pid /run/nginx.pid;
error_log /dev/stderr warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /dev/stdout;
    
    sendfile on;
    keepalive_timeout 65;
    
    server {
        listen $PORT;
        root /app/public;
        index index.php index.html;
        
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
EOF

# Verificar configuración
nginx -t

# Configuración completa de Supervisor
echo "🔧 Configurando Supervisor..."
cat > /etc/supervisor/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[unix_http_server]
file=/var/run/supervisor.sock

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock

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

echo "✅ Iniciando servicios..."
exec supervisord -c /etc/supervisor/supervisord.conf