#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
echo "⏰ Hora de inicio: $(date)"

# Variables de entorno
PORT=${PORT:-8080}
echo "📍 Puerto asignado: $PORT"

# Paso 1: Configurar PHP-FPM
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.conf << EOF
[global]
; Enviar logs a la salida estándar para que Railway pueda verlos
error_log = /proc/self/fd/2
daemonize = no

[www]
; Usuario y grupo para ejecutar PHP
user = www-data
group = www-data

; Socket para comunicación con Nginx
listen = 127.0.0.1:9000

; Configuración de procesos
pm = dynamic
pm.max_children = 20
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 5

; Importante: permitir que las variables de entorno pasen a PHP
clear_env = no

; Capturar output para debugging
catch_workers_output = yes
EOF

# Paso 2: Configurar Nginx
echo "🔧 Configurando Nginx..."
cat > /etc/nginx/nginx.conf << EOF
# Configuración principal de Nginx
user www-data;
worker_processes 1;
pid /run/nginx.pid;

# Enviar logs de error a stderr para que Railway los capture
error_log /dev/stderr warn;

events {
    worker_connections 1024;
}

http {
    # Configuración HTTP básica
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Tipos MIME
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logs de acceso a stdout
    access_log /dev/stdout;

    # Configuración del servidor
    server {
        # Escuchar en el puerto asignado por Railway
        listen ${PORT} default_server;
        server_name _;

        # Directorio raíz de Laravel
        root /app/public;
        index index.php;

        # Manejo de rutas
        location / {
            # Primero intenta servir el archivo solicitado
            # Si no existe, pasa la petición a index.php
            try_files \$uri \$uri/ /index.php?\$query_string;
        }

        # Configuración para archivos PHP
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            
            # Timeouts para evitar problemas con operaciones largas
            fastcgi_read_timeout 300;
            fastcgi_send_timeout 300;
        }

        # Denegar acceso a archivos ocultos
        location ~ /\. {
            deny all;
        }
    }
}
EOF

# Paso 3: Configurar la aplicación Laravel
cd /app

echo "🔐 Configurando permisos..."
# Asegurar que www-data pueda escribir en los directorios necesarios
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

echo "🧹 Limpiando caché anterior..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

echo "📦 Ejecutando migraciones..."
php artisan migrate --force

echo "🌱 Ejecutando seeders..."
php artisan db:seed --force || echo "ℹ️  Seeders ya ejecutados o no hay seeders"

echo "⚡ Optimizando para producción..."
# Cachear configuración para mejor rendimiento
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Paso 4: Crear archivo de verificación
echo "<?php echo json_encode(['status' => 'ok', 'time' => date('Y-m-d H:i:s')]);" > /app/public/health.php

# Paso 5: Iniciar servicios
echo "🚀 Iniciando servicios..."

# Iniciar PHP-FPM en segundo plano
php-fpm &
PHP_FPM_PID=$!

# Esperar a que PHP-FPM esté listo
sleep 2

# Verificar que PHP-FPM esté ejecutándose
if ! kill -0 $PHP_FPM_PID 2>/dev/null; then
    echo "❌ Error: PHP-FPM no pudo iniciar"
    exit 1
fi

echo "✅ PHP-FPM iniciado correctamente"

# Mostrar información útil
echo ""
echo "📋 Información de la aplicación:"
echo "   URL: ${APP_URL}"
echo "   Puerto: ${PORT}"
echo "   Entorno: producción"
echo ""
echo "🔍 Endpoints disponibles:"
echo "   ${APP_URL}/health.php - Verificación rápida"
echo "   ${APP_URL}/api/health - Estado detallado"
echo "   ${APP_URL}/api/hoteles - Lista de hoteles"
echo "   ${APP_URL}/api - Información de la API"
echo ""

# Iniciar Nginx en primer plano
echo "🌐 Iniciando Nginx..."
exec nginx -g "daemon off;"