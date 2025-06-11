#!/bin/bash

# 🧹 HOTELES DECAMERON - SCRIPT DE LIMPIEZA COMPLETA
# Este script elimina todo para simular un equipo nuevo
# Creado por: Yilberth-Arredondo

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
print_header() { echo -e "${BOLD}${RED}🧹 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_step() { echo -e "${BOLD}${YELLOW}🗑️  $1${NC}"; }

echo ""
print_header "LIMPIEZA COMPLETA DEL PROYECTO"
echo "=========================================="
print_warning "ATENCIÓN: Este script eliminará COMPLETAMENTE:"
echo "  • Base de datos PostgreSQL"
echo "  • Archivos de configuración (.env)"
echo "  • Dependencias instaladas (vendor/, node_modules/)"
echo "  • Caché y archivos temporales"
echo "  • Logs y archivos de sesión"
echo ""

# Confirmación de seguridad
read -p "¿Estás seguro de que quieres continuar? (escribe 'SI' para confirmar): " -r
echo
if [[ ! $REPLY == "SI" ]]; then
    print_info "Operación cancelada"
    exit 0
fi

echo ""
print_info "Iniciando limpieza completa..."
echo ""

# Variables
PROJECT_ROOT=$(pwd)
BACKEND_DIR="hoteles-backend"
FRONTEND_DIR="hoteles-frontend"
DB_NAME="hoteles_decameron"

# Función para eliminar base de datos
cleanup_database() {
    print_step "Limpiando base de datos PostgreSQL..."
    
    # Verificar si PostgreSQL está corriendo
    if pgrep -x "postgres" > /dev/null; then
        print_info "PostgreSQL está corriendo, eliminando base de datos..."
        
        # Terminar conexiones activas a la base de datos
        sudo -u postgres psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$DB_NAME' AND pid <> pg_backend_pid();" 2>/dev/null || true
        
        # Eliminar base de datos
        if sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null; then
            print_success "Base de datos '$DB_NAME' eliminada"
        else
            print_warning "No se pudo eliminar la base de datos (puede que no exista)"
        fi
        
        # Opcional: resetear contraseña del usuario postgres
        sudo -u postgres psql -c "ALTER USER postgres PASSWORD '';" 2>/dev/null || true
        print_info "Contraseña del usuario postgres reseteada"
    else
        print_info "PostgreSQL no está corriendo, saltando limpieza de BD"
    fi
}

# Función para limpiar backend
cleanup_backend() {
    print_step "Limpiando backend Laravel..."
    
    if [ -d "$BACKEND_DIR" ]; then
        cd "$BACKEND_DIR"
        
        # Eliminar archivos de configuración
        print_info "Eliminando archivos de configuración..."
        rm -f .env .env.backup.* 2>/dev/null || true
        print_success "Archivos .env eliminados"
        
        # Eliminar dependencias de Composer
        if [ -d "vendor" ]; then
            print_info "Eliminando vendor/..."
            rm -rf vendor/
            print_success "Directorio vendor/ eliminado"
        fi
        
        # Eliminar archivos de lock
        rm -f composer.lock 2>/dev/null || true
        
        # Limpiar caché de Laravel
        print_info "Limpiando caché de Laravel..."
        if [ -d "bootstrap/cache" ]; then
            rm -f bootstrap/cache/*.php 2>/dev/null || true
        fi
        
        # Limpiar storage
        if [ -d "storage" ]; then
            print_info "Limpiando storage..."
            rm -rf storage/app/public/* 2>/dev/null || true
            rm -rf storage/framework/cache/data/* 2>/dev/null || true
            rm -rf storage/framework/sessions/* 2>/dev/null || true
            rm -rf storage/framework/views/* 2>/dev/null || true
            rm -f storage/logs/*.log 2>/dev/null || true
            print_success "Storage limpiado"
        fi
        
        cd "$PROJECT_ROOT"
        print_success "Backend limpiado completamente"
    else
        print_warning "Directorio backend no encontrado"
    fi
}

# Función para limpiar frontend
cleanup_frontend() {
    print_step "Limpiando frontend React..."
    
    if [ -d "$FRONTEND_DIR" ]; then
        cd "$FRONTEND_DIR"
        
        # Eliminar node_modules
        if [ -d "node_modules" ]; then
            print_info "Eliminando node_modules/..."
            rm -rf node_modules/
            print_success "Directorio node_modules/ eliminado"
        fi
        
        # Eliminar archivos de lock
        print_info "Eliminando archivos de lock..."
        rm -f package-lock.json yarn.lock 2>/dev/null || true
        
        # Eliminar build de producción
        if [ -d "dist" ]; then
            rm -rf dist/ 2>/dev/null || true
            print_success "Build de producción eliminado"
        fi
        
        # Eliminar archivos de entorno
        rm -f .env .env.local .env.production 2>/dev/null || true
        print_success "Archivos de entorno eliminados"
        
        # Limpiar caché de Vite
        if [ -d ".vite" ]; then
            rm -rf .vite/ 2>/dev/null || true
        fi
        
        cd "$PROJECT_ROOT"
        print_success "Frontend limpiado completamente"
    else
        print_warning "Directorio frontend no encontrado"
    fi
}

# Función para limpiar archivos del proyecto raíz
cleanup_root() {
    print_step "Limpiando archivos del proyecto raíz..."
    
    # Eliminar logs globales si existen
    rm -f *.log 2>/dev/null || true
    
    # Eliminar archivos temporales
    rm -f .DS_Store **/.DS_Store 2>/dev/null || true
    rm -f Thumbs.db **/Thumbs.db 2>/dev/null || true
    
    # Limpiar caché de npm global relacionado al proyecto
    if command -v npm &> /dev/null; then
        npm cache clean --force >/dev/null 2>&1 || true
        print_success "Caché de npm limpiado"
    fi
    
    print_success "Archivos del proyecto raíz limpiados"
}

# Función para verificar limpieza
verify_cleanup() {
    print_step "Verificando limpieza..."
    
    local issues=0
    
    # Verificar base de datos
    if sudo -u postgres psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        print_error "Base de datos '$DB_NAME' aún existe"
        ((issues++))
    else
        print_success "✓ Base de datos eliminada"
    fi
    
    # Verificar backend
    if [ -f "$BACKEND_DIR/.env" ]; then
        print_error "Archivo .env del backend aún existe"
        ((issues++))
    else
        print_success "✓ Configuración del backend eliminada"
    fi
    
    if [ -d "$BACKEND_DIR/vendor" ]; then
        print_error "Directorio vendor/ aún existe"
        ((issues++))
    else
        print_success "✓ Dependencias del backend eliminadas"
    fi
    
    # Verificar frontend
    if [ -d "$FRONTEND_DIR/node_modules" ]; then
        print_error "Directorio node_modules/ aún existe"
        ((issues++))
    else
        print_success "✓ Dependencias del frontend eliminadas"
    fi
    
    if [ -f "$FRONTEND_DIR/.env.local" ]; then
        print_error "Archivo .env.local del frontend aún existe"
        ((issues++))
    else
        print_success "✓ Configuración del frontend eliminada"
    fi
    
    echo ""
    if [ $issues -eq 0 ]; then
        print_success "🎉 Limpieza completada exitosamente"
        print_info "El proyecto está listo para una instalación fresca"
    else
        print_warning "Limpieza completada con $issues problemas"
        print_info "Algunos archivos pueden requerir eliminación manual"
    fi
}

# Función para mostrar siguiente paso
show_next_steps() {
    echo ""
    print_header "PRÓXIMOS PASOS"
    echo "==============="
    print_info "Para probar la instalación desde cero:"
    echo ""
    echo "Es recomendable ejecutar el archivo 'install-requirements.sh' primero"
    echo ""
    echo "1. Ejecutar el script de instalación:"
    echo "   ./run.sh"
    echo ""
    echo "2. Verificar que todo funcione:"
    echo "   • Backend: http://localhost:8080/api/health"
    echo "   • Frontend: http://localhost:3000"
    echo ""
    print_warning "NOTA: Asegúrate de tener los requisitos instalados:"
    echo "  • PHP 8.1+"
    echo "  • Composer"
    echo "  • Node.js 16+"
    echo "  • PostgreSQL"
    echo ""
}

# Función principal
main() {
    # Verificar que estemos en el directorio correcto
    if [ ! -f "run.sh" ]; then
        print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
        print_info "Asegúrate de que el archivo 'run.sh' esté presente"
        exit 1
    fi
    
    # Ejecutar limpieza
    cleanup_database
    cleanup_backend
    cleanup_frontend
    cleanup_root
    verify_cleanup
    show_next_steps
}

# Función de manejo de errores
handle_error() {
    print_error "Error durante la limpieza en la línea $1"
    print_info "Puedes intentar continuar o limpiar manualmente"
    exit 1
}

# Configurar manejo de errores
trap 'handle_error $LINENO' ERR

# Ejecutar función principal
main "$@"

echo ""
print_success "🚀 Limpieza completa finalizada"
echo "=============================================="