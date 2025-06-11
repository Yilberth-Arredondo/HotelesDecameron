#!/bin/bash

# 🏨 HOTELES DECAMERON - INSTALACIÓN AUTOMÁTICA
# Autor: Sistema de Gestión Hotelera
# Compatible con WSL y Linux nativo

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Funciones de output
print_header() { echo -e "${BOLD}${BLUE}🏨 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_step() { echo -e "${BOLD}${YELLOW}📋 $1${NC}"; }

# Variables
PROJECT_ROOT=$(pwd)
BACKEND_DIR="hoteles-backend"
FRONTEND_DIR="hoteles-frontend"
DB_NAME="hoteles_decameron"

echo ""
print_header "HOTELES DECAMERON - INSTALACIÓN AUTOMÁTICA"
echo "==========================================================="
print_info "Este script instalará y configurará automáticamente:"
print_info "• Base de datos PostgreSQL con datos iniciales"
print_info "• Backend Laravel (Puerto 8080)"
print_info "• Frontend React (Puerto 3000)"
echo ""

# Función para ejecutar verificación previa
run_precheck() {
    print_step "Verificación rápida de requisitos..."
    
    # Usar verificación rápida si existe, sino la completa
    if [ -f "quick-check.sh" ]; then
        chmod +x quick-check.sh 2>/dev/null || true
        if ./quick-check.sh; then
            print_success "Verificación completada - sistema listo"
        else
            print_error "Faltan requisitos importantes"
            print_info "Instala los componentes faltantes antes de continuar"
            exit 1
        fi
    elif [ -f "pre-install-check.sh" ]; then
        chmod +x pre-install-check.sh 2>/dev/null || true
        print_info "Ejecutando verificación completa..."
        if timeout 30 ./pre-install-check.sh >/dev/null 2>&1; then
            print_success "Verificación completada"
        else
            print_warning "Verificación tomó demasiado tiempo, continuando..."
        fi
    else
        print_info "No se encontró script de verificación, continuando..."
    fi
    
    echo ""
}

# Función para verificar comandos requeridos
check_requirements() {
    print_step "Verificando requisitos del sistema..."
    
    # Verificar PHP
    if ! command -v php &> /dev/null; then
        print_error "PHP no está instalado. Se requiere PHP 8.1+"
        exit 1
    fi
    
    php_version=$(php -r "echo PHP_VERSION;" | cut -d. -f1,2)
    if [ "$(printf '%s\n' "8.1" "$php_version" | sort -V | head -n1)" != "8.1" ]; then
        print_error "Se requiere PHP 8.1+. Versión actual: $php_version"
        exit 1
    fi
    
    # Verificar Composer
    if ! command -v composer &> /dev/null; then
        print_error "Composer no está instalado"
        exit 1
    fi
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js no está instalado. Se requiere Node.js 16+"
        exit 1
    fi
    
    # Verificar npm
    if ! command -v npm &> /dev/null; then
        print_error "npm no está instalado"
        exit 1
    fi
    
    # Verificar PostgreSQL
    if ! command -v psql &> /dev/null; then
        print_error "PostgreSQL no está instalado"
        exit 1
    fi
    
    print_success "Todos los requisitos están satisfechos"
}

# Función para configurar PostgreSQL
setup_postgresql() {
    print_step "Configurando PostgreSQL..."
    
    # Intentar iniciar PostgreSQL
    if ! pgrep -x "postgres" > /dev/null; then
        print_info "Iniciando PostgreSQL..."
        if sudo service postgresql start 2>/dev/null || sudo systemctl start postgresql 2>/dev/null; then
            sleep 3
            print_success "PostgreSQL iniciado"
        else
            print_error "No se pudo iniciar PostgreSQL automáticamente"
            print_info "Inicia PostgreSQL manualmente e intenta de nuevo"
            exit 1
        fi
    else
        print_success "PostgreSQL ya está ejecutándose"
    fi
    
    # Configurar usuario postgres con contraseña
    print_info "Configurando usuario postgres..."
    if sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null; then
        print_success "Usuario postgres configurado"
    else
        print_warning "No se pudo configurar la contraseña del usuario postgres"
    fi
    
    # Crear/recrear base de datos
    print_info "Configurando base de datos '$DB_NAME'..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
    
    if sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;" 2>/dev/null; then
        print_success "Base de datos '$DB_NAME' creada"
    else
        print_error "No se pudo crear la base de datos"
        exit 1
    fi
    
    # Cargar datos iniciales si existe el archivo SQL
    if [ -f "database/hoteles_decameron_install.sql" ]; then
        print_info "Cargando datos iniciales desde SQL..."
        if sudo -u postgres psql -d "$DB_NAME" < database/hoteles_decameron_install.sql >/dev/null 2>&1; then
            print_success "Datos iniciales cargados desde archivo SQL"
        else
            print_warning "Error cargando desde SQL, se usarán las migraciones de Laravel"
        fi
    elif [ -f "hoteles_decameron_install.sql" ]; then
        print_info "Cargando datos iniciales desde SQL..."
        if sudo -u postgres psql -d "$DB_NAME" < hoteles_decameron_install.sql >/dev/null 2>&1; then
            print_success "Datos iniciales cargados desde archivo SQL"
        else
            print_warning "Error cargando desde SQL, se usarán las migraciones de Laravel"
        fi
    else
        print_info "No se encontró archivo SQL, se usarán las migraciones de Laravel"
    fi
}

# Función para instalar backend
setup_backend() {
    print_step "Configurando Backend (Laravel)..."
    
    if [ ! -d "$BACKEND_DIR" ]; then
        print_error "Directorio '$BACKEND_DIR' no encontrado"
        exit 1
    fi
    
    cd "$BACKEND_DIR"
    
    # Hacer ejecutable el script del backend
    chmod +x run-backend.sh 2>/dev/null || true
    
    # Ejecutar script del backend
    if [ -f "run-backend.sh" ]; then
        print_info "Ejecutando script de instalación del backend..."
        ./run-backend.sh
    else
        print_warning "Script run-backend.sh no encontrado, instalando manualmente..."
        
        # Instalar dependencias
        print_info "Instalando dependencias de Composer..."
        composer install --no-interaction --quiet
        
        # Configurar .env
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
        fi
        
        # Generar key
        php artisan key:generate --force
        
        # Ejecutar migraciones
        print_info "Ejecutando migraciones..."
        php artisan migrate --force
        
        # Ejecutar seeders
        print_info "Ejecutando seeders..."
        if php artisan db:seed --force; then
            print_success "Datos iniciales cargados"
        else
            print_warning "Error ejecutando seeders (normal si no existen)"
        fi
        
        # Limpiar caché
        php artisan config:clear
        php artisan cache:clear
        php artisan route:clear
    fi
    
    cd "$PROJECT_ROOT"
    print_success "Backend configurado correctamente"
}

# Función para instalar frontend
setup_frontend() {
    print_step "Configurando Frontend (React)..."
    
    if [ ! -d "$FRONTEND_DIR" ]; then
        print_error "Directorio '$FRONTEND_DIR' no encontrado"
        exit 1
    fi
    
    cd "$FRONTEND_DIR"
    
    # Hacer ejecutable el script del frontend
    chmod +x run-frontend.sh 2>/dev/null || true
    
    # Ejecutar script del frontend
    if [ -f "run-frontend.sh" ]; then
        print_info "Ejecutando script de instalación del frontend..."
        ./run-frontend.sh
    else
        print_warning "Script run-frontend.sh no encontrado, instalando manualmente..."
        
        # Instalar dependencias
        print_info "Instalando dependencias de npm..."
        npm install --silent
    fi
    
    cd "$PROJECT_ROOT"
    print_success "Frontend configurado correctamente"
}

# Función para verificar instalación
verify_installation() {
    print_step "Verificando instalación..."
    
    # Verificar base de datos
    hotels_count=$(sudo -u postgres psql -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name IN ('hotels', 'rooms');" 2>/dev/null | xargs || echo "0")
    
    if [ "$hotels_count" -ge 1 ]; then
        print_success "Base de datos verificada correctamente"
    else
        print_warning "Verificación de base de datos parcial"
    fi
    
    # Verificar archivos del backend
    if [ -f "$BACKEND_DIR/.env" ] && [ -f "$BACKEND_DIR/vendor/autoload.php" ]; then
        print_success "Backend verificado correctamente"
    else
        print_error "Error en la verificación del backend"
        return 1
    fi
    
    # Verificar archivos del frontend
    if [ -d "$FRONTEND_DIR/node_modules" ]; then
        print_success "Frontend verificado correctamente"
    else
        print_error "Error en la verificación del frontend"
        return 1
    fi
}

# Función para iniciar servidores
start_servers() {
    print_step "Preparando inicio de servidores..."
    
    echo ""
    print_header "¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
    echo "============================================"
    echo ""
    print_info "Para ejecutar el proyecto, abre 2 terminales:"
    echo ""
    echo -e "${BOLD}Terminal 1 - Backend:${NC}"
    echo "  cd $BACKEND_DIR"
    echo "  php artisan serve --port=8080"
    echo ""
    echo -e "${BOLD}Terminal 2 - Frontend:${NC}"
    echo "  cd $FRONTEND_DIR"
    echo "  npm run dev"
    echo ""
    print_success "URLs de acceso:"
    echo "  🌐 Frontend: http://localhost:3000"
    echo "  🔧 Backend API: http://localhost:8080/api"
    echo "  ❤️  Health Check: http://localhost:8080/api/health"
    echo ""
    print_info "Test rápido de la API:"
    echo "  curl http://localhost:8080/api/health"
    echo "  curl http://localhost:8080/api/hotels"
    echo ""
    
    # Preguntar si quiere iniciar automáticamente
    read -p "¿Deseas iniciar los servidores automáticamente ahora? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Iniciando servidores..."
        
        # Iniciar backend en background
        cd "$BACKEND_DIR"
        php artisan serve --port=8080 &
        BACKEND_PID=$!
        
        cd "$PROJECT_ROOT/$FRONTEND_DIR"
        
        print_success "Backend iniciado en puerto 8080 (PID: $BACKEND_PID)"
        print_info "Iniciando frontend en puerto 3000..."
        print_warning "Presiona Ctrl+C para detener ambos servidores"
        
        # Iniciar frontend (esto mantendrá el script corriendo)
        npm run dev
    else
        print_info "Los servidores no se iniciaron automáticamente"
        print_info "Usa los comandos mostrados arriba para iniciarlos manualmente"
    fi
}

# Función principal
main() {
    # Verificar si se ejecuta desde el directorio correcto
    if [ ! -d "$BACKEND_DIR" ] && [ ! -d "$FRONTEND_DIR" ]; then
        print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
        print_info "Asegúrate de que existan los directorios '$BACKEND_DIR' y '$FRONTEND_DIR'"
        exit 1
    fi
    
    # Ejecutar pasos de instalación
    run_precheck
    check_requirements
    setup_postgresql
    setup_backend
    setup_frontend
    verify_installation
    start_servers
}

# Manejo de señales para cleanup
cleanup() {
    if [ ! -z "$BACKEND_PID" ]; then
        print_info "Deteniendo servidores..."
        kill $BACKEND_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Ejecutar función principal
main "$@"