#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

# Configuración mínima de PHP-FPM
echo "🔧 Configurando PHP-FPM..."
php-fpm -D

# Configuración mínima de Nginx
echo "🔧 Configurando Nginx..."
cat > /etc/nginx/sites-available/default << EOF
server {
    listen $PORT default_server;
    root /app/public;
    index index.php;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Activar configuración y probar
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
nginx -t

# Setup Laravel básico
cd /app
php artisan config:clear
php artisan migrate --force || true

echo "✅ Iniciando Nginx..."
exec nginx -g "daemon off;"