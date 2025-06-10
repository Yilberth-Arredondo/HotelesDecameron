#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
echo "⏰ Hora: $(date)"

# Railway SIEMPRE proporciona PORT
PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Crear directorios necesarios
mkdir -p /run/nginx /var/log/nginx /run/php

# Configurar PHP-FPM con configuración mínima
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
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
catch_workers_output = yes
EOF

# Configurar Nginx - NOTA: Ahora usamos bash para expandir la variable directamente
echo "🔧 Configurando Nginx para puerto $PORT..."
# Aquí está el truco: usamos comillas dobles para que bash expanda $PORT
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
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

    server {
        # Aquí $PORT se expandirá al valor real (8080)
        listen $PORT default_server;
        listen [::]:$PORT default_server;
        
        root /app/public;
        index index.php index.html;
        
        server_name _;
        
        # Archivo de health check
        location = /health.php {
            try_files \$uri =404;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Rutas de Laravel
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        # Procesamiento de PHP
        location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
        }
        
        # Denegar acceso a archivos ocultos
        location ~ /\. {
            deny all;
        }
    }
}
EOF

# Verificar la configuración
echo "🔍 Verificando configuración de Nginx..."
echo "Puerto configurado: $PORT"
nginx -t

# Preparar Laravel
cd /app

echo "🔐 Configurando permisos..."
chown -R www-data:www-data /app
chmod -R 755 /app
chmod -R 775 /app/storage /app/bootstrap/cache

# Crear archivo de health check simple
cat > /app/public/health.php << 'EOPHP'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'port' => $_SERVER['SERVER_PORT'] ?? 'unknown',
    'time' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION,
    'server' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown'
]);
EOPHP
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

# Iniciar PHP-FPM en segundo plano
echo "🚀 Iniciando PHP-FPM..."
php-fpm &
PHP_FPM_PID=$!

# Esperar a que PHP-FPM esté listo
sleep 3

# Verificar que PHP-FPM esté ejecutándose
if ! kill -0 $PHP_FPM_PID 2>/dev/null; then
    echo "❌ Error: PHP-FPM no pudo iniciar"
    echo "Intentando ver qué salió mal..."
    php-fpm -t
    exit 1
fi

echo "✅ PHP-FPM iniciado correctamente (PID: $PHP_FPM_PID)"

# Verificación rápida local
echo "🧪 Verificando que el servidor responde localmente..."
sleep 2
curl -s http://localhost:$PORT/health.php || echo "⚠️  No se pudo verificar localmente"

echo ""
echo "✅ Configuración completa"
echo "📋 La aplicación estará disponible en:"
echo "   ${APP_URL}/health.php"
echo "   ${APP_URL}/api/health"
echo "   ${APP_URL}/api/hoteles"
echo ""
echo "🌐 Iniciando Nginx en puerto $PORT..."

# Iniciar Nginx en primer plano
exec nginx -g "daemon off;"