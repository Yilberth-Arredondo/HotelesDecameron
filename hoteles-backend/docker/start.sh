#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
PORT=${PORT:-8080}

# Verificar base de datos y ejecutar migraciones
echo "🔧 Verificando base de datos..."
php artisan config:clear
php artisan migrate --force

# Iniciar servidor PHP
echo "🌐 Iniciando servidor en puerto $PORT..."
exec php artisan serve --host=0.0.0.0 --port=$PORT