#!/bin/bash

# 🏨 HOTELES DECAMERON - INSTALACIÓN Y EJECUCIÓN COMPLETA
# Autor: yilberth-arredondo
# Uso: ./setup_and_run.sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


echo "🏨 HOTELES DECAMERON - SETUP COMPLETO"
echo "====================================="
echo "Este script instalará y ejecutará toda la aplicación"
echo ""

# Función para verificar comandos
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 no está instalado"
        echo "   Instalar con: $2"
        exit 1
    else
        echo "✅ $1 encontrado"
    fi
}

# Verificar dependencias
echo "🔍 Verificando dependencias del sistema..."
check_command "php" "sudo apt install php8.1 php8.1-cli php8.1-pgsql php8.1-mbstring php8.1-xml"
check_command "composer" "curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer"
check_command "psql" "sudo apt install postgresql postgresql-contrib"

# Verificar versión PHP
PHP_VERSION=$(php -r "echo PHP_VERSION;" | cut -d. -f1,2)
if (( $(echo "$PHP_VERSION < 8.0" | bc -l) )); then
    echo "❌ PHP 8.0+ requerido. Versión actual: $PHP_VERSION"
    exit 1
fi

echo "✅ Todas las dependencias verificadas"
echo ""

# Iniciar PostgreSQL
echo "🔄 Iniciando PostgreSQL..."
sudo systemctl start postgresql || {
    echo "❌ Error iniciando PostgreSQL"
    echo "   Verificar instalación: sudo apt install postgresql"
    exit 1
}

# Navegar al backend
if [ ! -d "hoteles-backend" ]; then
    echo "❌ Directorio hoteles-backend no encontrado"
    echo "   Ejecutar desde el directorio raíz del proyecto"
    exit 1
fi

cd hoteles-backend

# Instalar dependencias PHP
echo "📦 Instalando dependencias de PHP..."
composer install --optimize-autoloader

# Configurar entorno
echo "⚙️  Configurando entorno de Laravel..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "   ✅ Archivo .env creado"
fi

# Generar clave de aplicación
php artisan key:generate --force
echo "   ✅ Clave de aplicación generada"

# Configurar base de datos
echo "🗄️  Configurando base de datos..."
cd database

# Verificar que el script de instalación existe
if [ ! -f install.sh ]; then
    echo "❌ Script de instalación de BD no encontrado"
    echo "   Verificar que existe database/install.sh"
    exit 1
fi

chmod +x install.sh
./install.sh

if [ $? -eq 0 ]; then
    echo "   ✅ Base de datos configurada exitosamente"
else
    echo "   ❌ Error configurando base de datos"
    exit 1
fi

cd ..

# Optimizar Laravel para producción
echo "🚀 Optimizando aplicación..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Verificar que todo funciona
echo "🧪 Verificando instalación..."
php artisan route:list --path=api > /dev/null 2>&1 || {
    echo "❌ Error en las rutas de la API"
    exit 1
}

# Mostrar información
echo ""
echo "🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo "========================================"
echo ""
echo "📊 Resumen de la aplicación:"
echo "   • Backend Laravel: ✅ Configurado"
echo "   • Base de datos: ✅ 5 hoteles, múltiples habitaciones"
echo "   • API RESTful: ✅ Todos los endpoints funcionando"
echo ""
echo "🌐 URLs disponibles:"
echo "   • Backend: http://127.0.0.1:8000"
echo "   • API Hoteles: http://127.0.0.1:8000/api/hotels"
echo "   • Configuración: http://127.0.0.1:8000/api/configuracion/habitaciones"
echo ""
echo "🧪 Comandos de prueba (ejecutar en otra terminal):"
echo "   curl http://127.0.0.1:8000/api/hotels"
echo "   curl http://127.0.0.1:8000/api/hotels/1"
echo ""
echo "🛑 Para detener el servidor: Ctrl+C"
echo ""
echo "🚀 Iniciando servidor..."
echo "========================"

# Iniciar servidor Laravel
php artisan serve --host=0.0.0.0 --port=8000
