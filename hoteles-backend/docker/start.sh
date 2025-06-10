#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

# Configuración mínima de PHP-FPM
echo "🔧 Configurando PHP-FPM..."
php-fpm -D

# Verificar que PHP-FPM está funcionando
echo "🔍 Verificando PHP-FPM..."
sleep 2
if ! pgrep php-fpm > /dev/null; then
    echo "❌ PHP-FPM no está funcionando"
    exit 1
fi
echo "✅ PHP-FPM funcionando correctamente"

# Configuración completa de Nginx
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
        
        location ~ /\.ht {
            deny all;
        }
    }
}
EOF

# Verificar configuración de Nginx
echo "🔍 Verificando configuración de Nginx..."
nginx -t
if [ $? -ne 0 ]; then
    echo "❌ Error en configuración de Nginx"
    exit 1
fi

# Setup Laravel básico
echo "🔧 Configurando Laravel..."
cd /app
php artisan config:clear
php artisan migrate --force || true

# Crear archivo de prueba
echo '<?php echo json_encode(["status" => "ok", "time" => date("c")]);' > /app/public/health.php

echo "✅ Iniciando Nginx..."
echo "📊 Estado antes de iniciar Nginx:"
echo "- Puerto configurado: $PORT"
echo "- PHP-FPM PID: $(pgrep php-fmp || echo 'No encontrado')"
echo "- Directorio público: $(ls -la /app/public/ | head -3)"

# Iniciar Nginx con logs de depuración
exec nginx -g "daemon off; error_log /dev/stderr info;"