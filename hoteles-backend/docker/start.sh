#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
echo "⏰ Hora: $(date)"

PORT=${PORT:-8080}
echo "📍 Puerto asignado por Railway: $PORT"

# Función para logging con timestamp
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Crear directorios necesarios
log "📁 Creando directorios necesarios..."
mkdir -p /run/nginx /var/log/nginx /run/php /var/log/php-fpm

# Configurar PHP-FPM
log "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.conf << EOF
[global]
error_log = /proc/self/fd/2
daemonize = no
log_level = debug

[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
listen.allowed_clients = 127.0.0.1
listen.backlog = 512
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 5
pm.max_requests = 500
request_terminate_timeout = 300
catch_workers_output = yes
access.log = /proc/self/fd/2
slowlog = /proc/self/fd/2
request_slowlog_timeout = 5s
clear_env = no
EOF

# Configurar Nginx con logging mejorado
log "🔧 Configurando Nginx para puerto $PORT..."
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /proc/self/fd/2 debug;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging mejorado
    log_format detailed '\$remote_addr - \$remote_user [\$time_local] '
                       '"\$request" \$status \$body_bytes_sent '
                       '"\$http_referer" "\$http_user_agent" '
                       'rt=\$request_time uct="\$upstream_connect_time" '
                       'uht="\$upstream_header_time" urt="\$upstream_response_time"';
    
    access_log /proc/self/fd/1 detailed;

    # Configuración de upstream para PHP
    upstream php-fpm {
        server 127.0.0.1:9000 max_fails=3 fail_timeout=30s;
    }

    server {
        listen $PORT default_server;
        listen [::]:$PORT default_server;
        
        root /app/public;
        index index.php index.html;
        
        server_name _;
        
        # Logging específico del servidor
        error_log /proc/self/fd/2 debug;
        access_log /proc/self/fd/1 detailed;
        
        # Health check endpoint simple
        location = /nginx-health {
            access_log off;
            return 200 "nginx is running on port $PORT\n";
            add_header Content-Type text/plain;
        }
        
        # Archivo de health check PHP
        location = /health.php {
            try_files \$uri =404;
            fastcgi_pass php-fpm;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include fastcgi_params;
            fastcgi_connect_timeout 5s;
            fastcgi_send_timeout 5s;
            fastcgi_read_timeout 5s;
        }
        
        # Rutas de Laravel
        location / {
            try_files \$uri \$uri/ /index.php?\$query_string;
        }
        
        # Procesamiento de PHP
        location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass php-fpm;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param PATH_INFO \$fastcgi_path_info;
            include fastcgi_params;
            
            # Timeouts
            fastcgi_connect_timeout 10s;
            fastcgi_send_timeout 60s;
            fastcgi_read_timeout 60s;
            
            # Buffer sizes
            fastcgi_buffer_size 32k;
            fastcgi_buffers 8 16k;
        }
        
        # Denegar acceso a archivos ocultos
        location ~ /\. {
            deny all;
        }
    }
}
EOF

# Verificar configuración
log "🔍 Verificando configuración de Nginx..."
nginx -t || {
    echo "❌ Error en configuración de Nginx"
    exit 1
}

# Preparar Laravel
cd /app

log "🔐 Configurando permisos..."
chown -R www-data:www-data /app
chmod -R 755 /app
chmod -R 775 /app/storage /app/bootstrap/cache

# Crear archivos de prueba
log "📝 Creando archivos de prueba..."
echo "<?php echo 'PHP is working!';" > /app/public/test.php
cat > /app/public/health.php << 'EOPHP'
<?php
header('Content-Type: application/json');
$response = [
    'status' => 'ok',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION,
    'server_port' => $_SERVER['SERVER_PORT'] ?? 'unknown',
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown',
    'sapi_name' => php_sapi_name(),
    'loaded_extensions' => get_loaded_extensions()
];
echo json_encode($response, JSON_PRETTY_PRINT);
EOPHP

# Laravel setup
log "🧹 Preparando Laravel..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

log "📦 Ejecutando migraciones..."
php artisan migrate --force || echo "⚠️  Migraciones ya ejecutadas"

log "⚡ Optimizando..."
php artisan config:cache
php artisan route:cache

# Iniciar PHP-FPM
log "🚀 Iniciando PHP-FPM..."
php-fpm -F &
PHP_FPM_PID=$!

# Esperar más tiempo para que PHP-FPM esté completamente listo
log "⏳ Esperando a que PHP-FPM esté completamente listo..."
sleep 5

# Verificar que PHP-FPM esté escuchando
log "🔍 Verificando que PHP-FPM esté escuchando en puerto 9000..."
for i in {1..10}; do
    if netstat -tuln 2>/dev/null | grep -q ":9000 "; then
        log "✅ PHP-FPM está escuchando en puerto 9000"
        break
    elif [ $i -eq 10 ]; then
        log "❌ PHP-FPM no está escuchando después de 10 intentos"
        log "Procesos PHP-FPM actuales:"
        ps aux | grep php-fpm || true
        log "Puertos en escucha:"
        netstat -tuln || ss -tuln || true
        exit 1
    else
        log "Intento $i/10: esperando a PHP-FPM..."
        sleep 1
    fi
done

# Iniciar Nginx
log "🌐 Iniciando Nginx..."
nginx &
NGINX_PID=$!

# Esperar a que Nginx esté listo
sleep 3

# Verificaciones finales
log "🔍 Verificaciones finales..."
log "PHP-FPM PID: $PHP_FPM_PID - Estado: $(kill -0 $PHP_FPM_PID 2>/dev/null && echo 'Activo' || echo 'Inactivo')"
log "Nginx PID: $NGINX_PID - Estado: $(kill -0 $NGINX_PID 2>/dev/null && echo 'Activo' || echo 'Inactivo')"

# Pruebas locales
log "🧪 Realizando pruebas locales..."

# Prueba 1: Nginx health
log "Prueba 1: Nginx health check..."
curl -s -o /dev/null -w "Código HTTP: %{http_code}\n" http://localhost:$PORT/nginx-health || log "❌ Fallo prueba Nginx"

# Prueba 2: PHP simple
log "Prueba 2: PHP simple..."
curl -s http://localhost:$PORT/test.php || log "❌ Fallo prueba PHP simple"
echo ""

# Prueba 3: Health endpoint
log "Prueba 3: Health endpoint..."
curl -s http://localhost:$PORT/health.php | head -5 || log "❌ Fallo health endpoint"

echo ""
log "✅ Configuración completa"
log "📋 La aplicación está disponible en:"
log "   ${APP_URL}/nginx-health - Verificación de Nginx"
log "   ${APP_URL}/test.php - Prueba PHP simple"
log "   ${APP_URL}/health.php - Estado detallado"
log "   ${APP_URL}/api/health - API health check"
log "   ${APP_URL}/api/hoteles - Lista de hoteles"

# Mantener el contenedor activo esperando en primer plano
log "👀 Monitoreando servicios..."
wait