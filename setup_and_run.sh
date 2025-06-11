#!/bin/bash

# 🏨 HOTELES DECAMERON - SETUP LOCAL
# Puerto 8080 para Laravel, 3000 para React

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🏨 HOTELES DECAMERON - SETUP LOCAL"
echo "=================================="

# Verificar PostgreSQL
print_info "Configurando PostgreSQL..."

# Intentar iniciar PostgreSQL si no está corriendo
if ! pgrep -x "postgres" > /dev/null; then
    sudo service postgresql start 2>/dev/null || sudo systemctl start postgresql 2>/dev/null
    sleep 2
fi

# Crear base de datos
print_info "Creando base de datos..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS hoteles_decameron;" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE hoteles_decameron;" 2>/dev/null || {
    print_error "No se pudo crear la base de datos"
    print_info "Crear manualmente con: sudo -u postgres createdb hoteles_decameron"
    exit 1
}

# Verificar/crear usuario postgres con contraseña
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null || true

print_success "Base de datos configurada"

# Configurar Laravel
cd hoteles-backend

# Copiar .env de ejemplo
if [ ! -f .env ]; then
    print_info "Creando archivo .env..."
    cat > .env << 'EOF'
APP_NAME="Hoteles Decameron"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack
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

CORS_ALLOWED_ORIGINS=http://localhost:3000
EOF
    print_success ".env creado"
fi

# Instalar dependencias
print_info "Instalando dependencias..."
composer install --no-interaction --quiet

# Generar key
php artisan key:generate

# Migrar base de datos
print_info "Ejecutando migraciones..."
php artisan migrate:fresh --force

# Limpiar caché
php artisan config:clear
php artisan cache:clear
php artisan route:clear

print_success "¡Setup completado!"
echo ""
echo "📝 Para ejecutar el proyecto:"
echo ""
echo "Terminal 1 - Backend:"
echo "  cd hoteles-backend"
echo "  php artisan serve --port=8080"
echo ""
echo "Terminal 2 - Frontend:"
echo "  cd hoteles-frontend"
echo "  npm install"
echo "  npm start"
echo ""
echo "🌐 URLs:"
echo "  Backend: http://localhost:8080/api"
echo "  Frontend: http://localhost:3000"
echo ""
echo "🧪 Test rápido:"
echo "  curl http://localhost:8080/api/health"