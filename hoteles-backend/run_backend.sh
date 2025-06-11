#!/bin/bash

# 🏨 HOTELES DECAMERON - BACKEND SETUP
# Script de instalación y configuración del backend Laravel
# Autor: Sistema de Gestión Hotelera

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Funciones de output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_step() { echo -e "${BOLD}${BLUE}🔧 $1${NC}"; }

echo ""
print_step "CONFIGURANDO BACKEND LARAVEL"
echo "=================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "composer.json" ]; then
    print_error "Este script debe ejecutarse desde el directorio del backend Laravel"
    exit 1
fi

# Verificar PHP y Composer
if ! command -v php &> /dev/null; then
    print_error "PHP no está instalado"
    exit 1
fi

if ! command -v composer &> /dev/null; then
    print_error "Composer no está instalado"
    exit 1
fi

# 1. Instalar dependencias de Composer
print_step "Instalando dependencias de Composer..."
if composer install --no-interaction --optimize-autoloader --no-dev; then
    print_success "Dependencias instaladas"
else
    print_error "Error instalando dependencias"
    exit 1
fi

# 2. Configurar archivo .env
print_step "Configurando archivo .env..."
if [ -f .env ]; then
    print_info "Archivo .env ya existe, creando backup..."
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
fi

cat > .env << 'EOF'
APP_NAME="Hoteles Decameron"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=hoteles_decameron
DB_USERNAME=postgres
DB_PASSWORD=postgres

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
EOF

print_success "Archivo .env configurado"

# 3. Generar clave de aplicación
print_step "Generando clave de aplicación..."
if php artisan key:generate --force; then
    print_success "Clave de aplicación generada"
else
    print_error "Error generando clave de aplicación"
    exit 1
fi

# 4. Verificar conexión a base de datos
print_step "Verificando conexión a base de datos..."
if php artisan migrate:status >/dev/null 2>&1; then
    print_success "Conexión a base de datos exitosa"
else
    print_warning "No se pudo conectar a la base de datos, continuando..."
fi

# 5. Ejecutar migraciones
print_step "Ejecutando migraciones..."
if php artisan migrate --force; then
    print_success "Migraciones ejecutadas"
else
    print_warning "Error en migraciones, pueden no existir aún"
fi

# 6. Ejecutar seeders si existen
if [ -d "database/seeders" ] && [ -n "$(ls -A database/seeders)" ]; then
    print_step "Ejecutando seeders..."
    if php artisan db:seed --force; then
        print_success "Seeders ejecutados"
    else
        print_warning "Error ejecutando seeders"
    fi
fi

# 7. Crear enlace simbólico para storage
print_step "Configurando almacenamiento..."
if php artisan storage:link; then
    print_success "Enlace de almacenamiento creado"
else
    print_warning "Error creando enlace de almacenamiento"
fi

# 8. Limpiar y optimizar caché
print_step "Optimizando caché..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# En desarrollo, evitar cache de rutas y config
if [ "$APP_ENV" = "local" ] || [ "$APP_DEBUG" = "true" ]; then
    print_info "Modo desarrollo: cache deshabilitado"
else
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

print_success "Caché optimizado"

# 9. Configurar permisos
print_step "Configurando permisos..."
if [ -d "storage" ]; then
    chmod -R 775 storage/
    print_success "Permisos de storage configurados"
fi

if [ -d "bootstrap/cache" ]; then
    chmod -R 775 bootstrap/cache/
    print_success "Permisos de bootstrap/cache configurados"
fi

# 10. Verificar configuración
print_step "Verificando configuración..."

# Verificar archivos críticos
critical_files=("artisan" "composer.json" ".env" "vendor/autoload.php")
for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file"
    else
        print_error "✗ $file (faltante)"
    fi
done

# Verificar directorios críticos
critical_dirs=("app" "config" "database" "routes" "storage" "vendor")
for dir in "${critical_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_success "✓ $dir/"
    else
        print_error "✗ $dir/ (faltante)"
    fi
done

# 11. Test de funcionamiento básico
print_step "Realizando test básico..."
if php artisan --version >/dev/null 2>&1; then
    print_success "Laravel funciona correctamente"
else
    print_error "Error en el funcionamiento de Laravel"
    exit 1
fi

echo ""
print_success "🎉 ¡BACKEND CONFIGURADO EXITOSAMENTE!"
echo "=================================="
print_info "Para iniciar el servidor:"
echo "  php artisan serve --port=8080"
echo ""
print_info "URLs disponibles:"
echo "  🌐 Aplicación: http://localhost:8080"
echo "  🔧 API: http://localhost:8080/api"
echo ""
print_info "Comandos útiles:"
echo "  php artisan route:list    # Listar rutas"
echo "  php artisan migrate       # Ejecutar migraciones"
echo "  php artisan db:seed       # Ejecutar seeders"
echo "  php artisan queue:work    # Procesar cola de trabajos"
echo ""

# 12. Mostrar información del entorno
print_step "Información del entorno..."
echo "  📋 PHP: $(php --version | head -n 1)"
echo "  📋 Composer: $(composer --version)"
echo "  📋 Laravel: $(php artisan --version)"
echo ""

# 13. Verificar endpoints principales
print_step "Verificando disponibilidad de archivos críticos..."
if [ -f "public/health.php" ]; then
    print_success "Health check endpoint disponible"
fi

if [ -f "routes/api.php" ]; then
    print_success "Rutas de API configuradas"
fi

echo ""
print_success "🚀 Backend listo para usar!"
echo "=================================================="