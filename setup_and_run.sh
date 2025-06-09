#!/bin/bash

# 🏨 HOTELES DECAMERON - SETUP Y EJECUCIÓN
# Compatible con Linux/WSL
# Uso: ./setup_and_run.sh

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🏨 HOTELES DECAMERON - SETUP Y EJECUCIÓN"
echo "========================================"

# Verificar que estamos en el directorio correcto
if [ ! -d "hoteles-backend" ]; then
    print_error "Directorio 'hoteles-backend' no encontrado"
    print_info "Ejecutar este script desde el directorio raíz del proyecto"
    exit 1
fi

# Verificar dependencias básicas
print_info "Verificando dependencias del sistema..."

# Verificar PHP
if ! command -v php >/dev/null 2>&1; then
    print_error "PHP no encontrado"
    print_info "Para instalar en Ubuntu/WSL:"
    echo "   sudo apt update"
    echo "   sudo add-apt-repository ppa:ondrej/php -y"
    echo "   sudo apt install php8.1 php8.1-cli php8.1-pgsql php8.1-mbstring php8.1-xml"
    exit 1
fi

# Verificar versión de PHP
PHP_VERSION=$(php -r "echo PHP_VERSION;" | cut -d. -f1,2)
if [ "$(echo "$PHP_VERSION < 8.0" | bc -l 2>/dev/null)" = "1" ]; then
    print_error "PHP 8.0+ requerido. Versión actual: $PHP_VERSION"
    exit 1
fi
print_success "PHP $PHP_VERSION encontrado"

# Verificar Composer
if ! command -v composer >/dev/null 2>&1; then
    print_error "Composer no encontrado"
    print_info "Para instalar:"
    echo "   curl -sS https://getcomposer.org/installer | php"
    echo "   sudo mv composer.phar /usr/local/bin/composer"
    exit 1
fi
print_success "Composer encontrado"

# Verificar PostgreSQL
if ! command -v psql >/dev/null 2>&1; then
    print_error "PostgreSQL no encontrado"
    print_info "Para instalar en Ubuntu/WSL:"
    echo "   sudo apt install postgresql postgresql-contrib"
    exit 1
fi
print_success "PostgreSQL encontrado"

# Verificar si PostgreSQL está corriendo
if ! pgrep -x "postgres" > /dev/null; then
    print_warning "PostgreSQL no está ejecutándose"
    print_info "Intentando iniciar PostgreSQL..."
    
    # Intentar iniciar PostgreSQL (funciona en WSL y Linux)
    if sudo service postgresql start 2>/dev/null || sudo systemctl start postgresql 2>/dev/null; then
        print_success "PostgreSQL iniciado"
        sleep 2
    else
        print_error "No se pudo iniciar PostgreSQL automáticamente"
        print_info "Iniciar manualmente con:"
        echo "   sudo service postgresql start  # En WSL"
        echo "   sudo systemctl start postgresql  # En Linux nativo"
        exit 1
    fi
else
    print_success "PostgreSQL está ejecutándose"
fi

# Verificar conexión a PostgreSQL
if ! sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
    print_error "No se puede conectar a PostgreSQL"
    print_info "Verificar que PostgreSQL esté configurado correctamente"
    exit 1
fi
print_success "Conexión a PostgreSQL verificada"

print_success "Todas las dependencias verificadas"
echo ""

# Configurar el proyecto
print_info "Configurando proyecto Laravel..."
cd hoteles-backend

# Instalar dependencias
print_info "Instalando dependencias PHP..."
if ! composer install --optimize-autoloader --no-dev; then
    print_error "Error instalando dependencias con Composer"
    exit 1
fi
print_success "Dependencias instaladas"

# Configurar entorno
print_info "Configurando entorno Laravel..."
if [ ! -f .env ]; then
    cp .env.example .env
    print_success "Archivo .env creado"
else
    print_warning "Archivo .env ya existe"
fi

# Generar clave de aplicación
php artisan key:generate --force >/dev/null 2>&1
print_success "Clave de aplicación generada"

# Configurar base de datos
print_info "Configurando base de datos..."
cd database

if [ ! -f install.sh ]; then
    print_error "Script de instalación de BD no encontrado (database/install.sh)"
    exit 1
fi

chmod +x install.sh
if ./install.sh; then
    print_success "Base de datos configurada"
else
    print_error "Error configurando base de datos"
    exit 1
fi

cd ..

# Verificar que la aplicación funciona
print_info "Verificando configuración..."
if php artisan route:list --path=api >/dev/null 2>&1; then
    print_success "Rutas de API configuradas correctamente"
else
    print_error "Error en configuración de rutas"
    exit 1
fi

# Optimizar Laravel
print_info "Optimizando aplicación..."
php artisan config:cache >/dev/null 2>&1
php artisan route:cache >/dev/null 2>&1

# Verificar datos de ejemplo
print_info "Verificando datos de ejemplo..."
HOTEL_COUNT=$(php artisan tinker --execute="echo App\Models\Hotel::count();" 2>/dev/null | tail -1)
if [ "$HOTEL_COUNT" -gt 0 ] 2>/dev/null; then
    print_success "Base de datos contiene $HOTEL_COUNT hoteles de ejemplo"
else
    print_warning "No se pudieron verificar los datos de ejemplo"
fi

echo ""
print_success "¡Configuración completada exitosamente!"
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
echo "🚀 Iniciando servidor Laravel..."
echo "==============================="
echo ""

# Iniciar servidor Laravel
php artisan serve --host=0.0.0.0 --port=8000