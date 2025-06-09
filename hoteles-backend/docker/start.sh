#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}

# Configurar PHP-FPM para escuchar en 127.0.0.1:9000
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
EOF

# Configurar Nginx para usar el puerto correcto
echo "🔧 Configurando Nginx para puerto $PORT..."
cat > /etc/nginx/sites-available/default << EOF
server {
    listen $PORT default_server;
    listen [::]:$PORT default_server;
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
EOF

# Iniciar los servicios
mkdir -p /run/php
php-fpm -D
nginx -g "daemon off;"