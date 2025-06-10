#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

# Setup Laravel básico primero
echo "🔧 Configurando Laravel..."
cd /app
php artisan config:clear
php artisan migrate --force || true

# Crear archivo de prueba
echo '<?php echo json_encode(["status" => "ok", "time" => date("c")]);' > /app/public/health.php

# Configuración de Nginx
echo "🔧 Configurando Nginx..."
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes 1;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    
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
            fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
EOF

# Configurar Supervisor
echo "🔧 Configurando Supervisor..."
cat > /etc/supervisor/conf.d/app.conf << EOF
[supervisord]
nodaemon=true
loglevel=info

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

# Verificar configuración de Nginx
echo "🔍 Verificando configuración de Nginx..."
nginx -t

echo "✅ Iniciando Supervisor con PHP-FPM y Nginx..."

# Iniciar supervisor en background para poder hacer diagnóstico
supervisord -c /etc/supervisor/supervisord.conf &
SUPERVISOR_PID=$!

# Esperar que los servicios inicien
sleep 5

# Diagnóstico
echo "🔍 DIAGNÓSTICO POST-INICIO:"
echo "- Supervisor PID: $SUPERVISOR_PID"
echo "- Procesos nginx: $(pgrep nginx || echo 'ninguno')"
echo "- Procesos php-fpm: $(pgrep php-fmp || echo 'ninguno')"
echo "- Puerto configurado: $PORT"
echo "- Netstat:"
netstat -tlnp | grep :$PORT || echo "Puerto $PORT no está escuchando"
echo "- Test HTTP local:"
curl -I "http://127.0.0.1:$PORT/health.php" 2>&1 || echo "Request HTTP falló"

# Mantener supervisor en foreground
wait $SUPERVISOR_PID