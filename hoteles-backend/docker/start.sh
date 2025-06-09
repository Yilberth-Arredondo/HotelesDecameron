#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."

# Railway siempre proporciona PORT, pero por si acaso
PORT=${PORT:-8000}
echo "📍 Puerto asignado por Railway: $PORT"

# Configurar PHP-FPM
echo "🔧 Configurando PHP-FPM..."
cat > /usr/local/etc/php-fpm.d/www.conf << EOF
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
clear_env = no
catch_workers_output = yes
EOF

# Configurar Nginx para usar el puerto de Railway
echo "🔧 Configurando Nginx para puerto $PORT..."
cat > /etc/nginx/sites-enabled/default << EOF
server {
    listen $PORT default_server;
    listen [::]:$PORT default_server;
    
    root /app/public;
    index index.php index.html;
    
    server_name _;
    
    # Logs
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
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_read_timeout 300;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Eliminar default de sites-available si existe
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

# Configuración principal de Nginx
cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /dev/stderr;

events {
    worker_connections 1024;
}

http {
    access_log /dev/stdout;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml application/atom+xml image/svg+xml;
    
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

# Ejecutar migraciones
echo "🔄 Ejecutando migraciones..."
php artisan migrate --force || {
    echo "❌ Error en migraciones. Verificando conexión..."
    php artisan db:show
    exit 1
}

# Verificar si hay datos
echo "📊 Verificando datos..."
HOTEL_COUNT=$(php artisan tinker --execute="echo \App\Models\Hotel::count();" 2>/dev/null | tail -1)

if [ "$HOTEL_COUNT" = "0" ] || [ -z "$HOTEL_COUNT" ]; then
    echo "🌱 Base de datos vacía, ejecutando seeders..."
    php artisan db:seed --force || echo "⚠️ Seeders no ejecutados"
else
    echo "✅ Base de datos contiene $HOTEL_COUNT hoteles"
fi

# Limpiar y optimizar caché
echo "🧹 Optimizando aplicación..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Crear archivo de configuración de supervisor
mkdir -p /etc/supervisor/conf.d
cat > /etc/supervisor/supervisord.conf << EOF
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/var/run/supervisord.pid

[program:php-fpm]
command=/usr/local/sbin/php-fpm -F
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF

echo "✅ Aplicación lista!"
echo "🌐 Servidor escuchando en puerto $PORT"
echo "📍 URL de la aplicación: $APP_URL"

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf