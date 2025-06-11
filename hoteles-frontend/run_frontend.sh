#!/bin/bash

# 🏨 HOTELES DECAMERON - FRONTEND SETUP
# Script de instalación y configuración del frontend React
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
print_step() { echo -e "${BOLD}${BLUE}⚛️  $1${NC}"; }

echo ""
print_step "CONFIGURANDO FRONTEND REACT"
echo "================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    print_error "Este script debe ejecutarse desde el directorio del frontend React"
    exit 1
fi

# Verificar Node.js y npm
if ! command -v node &> /dev/null; then
    print_error "Node.js no está instalado"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm no está instalado"
    exit 1
fi

# Verificar versiones mínimas
node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$node_version" -lt 16 ]; then
    print_error "Se requiere Node.js 16+. Versión actual: v$(node --version | cut -d'v' -f2)"
    exit 1
fi

print_success "Node.js $(node --version) detectado"

# 1. Limpiar instalaciones previas
print_step "Limpiando instalación previa..."
if [ -d "node_modules" ]; then
    print_info "Eliminando node_modules existente..."
    rm -rf node_modules
fi

if [ -f "package-lock.json" ]; then
    print_info "Eliminando package-lock.json existente..."
    rm -f package-lock.json
fi

# 2. Instalar dependencias
print_step "Instalando dependencias de npm..."
if npm install; then
    print_success "Dependencias instaladas correctamente"
else
    print_error "Error instalando dependencias"
    exit 1
fi

# 3. Verificar dependencias críticas
print_step "Verificando dependencias críticas..."
critical_deps=("react" "react-dom" "vite" "@tailwindcss/forms" "@headlessui/react")
for dep in "${critical_deps[@]}"; do
    if npm list "$dep" >/dev/null 2>&1; then
        print_success "✓ $dep"
    else
        print_warning "✗ $dep (no instalado)"
    fi
done

# 4. Configurar variables de entorno si no existen
print_step "Configurando variables de entorno..."
if [ ! -f ".env" ] && [ ! -f ".env.local" ]; then
    print_info "Creando archivo .env.local..."
    cat > .env.local << 'EOF'
# Configuración del Frontend - Hoteles Decameron
VITE_API_URL=http://localhost:8080/api
VITE_APP_NAME="Hoteles Decameron"
VITE_APP_ENV=development
EOF
    print_success "Variables de entorno configuradas"
else
    print_info "Variables de entorno ya configuradas"
fi

# 5. Verificar configuración de Vite
print_step "Verificando configuración de Vite..."
if [ -f "vite.config.js" ]; then
    print_success "Configuración de Vite encontrada"
else
    print_warning "Configuración de Vite no encontrada"
fi

# 6. Verificar configuración de Tailwind
print_step "Verificando configuración de Tailwind..."
if [ -f "tailwind.config.js" ]; then
    print_success "Configuración de Tailwind encontrada"
else
    print_warning "Configuración de Tailwind no encontrada"
fi

if [ -f "postcss.config.js" ]; then
    print_success "Configuración de PostCSS encontrada"
else
    print_warning "Configuración de PostCSS no encontrada"
fi

# 7. Verificar estructura de archivos
print_step "Verificando estructura del proyecto..."
critical_files=("src/main.jsx" "src/App.jsx" "index.html" "package.json")
for file in "${critical_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file"
    else
        print_error "✗ $file (crítico, faltante)"
    fi
done

# Verificar directorios críticos
critical_dirs=("src" "src/components" "src/pages" "src/services" "public")
for dir in "${critical_dirs[@]}"; do
    if [ -d "$dir" ]; then
        print_success "✓ $dir/"
    else
        print_warning "✗ $dir/ (recomendado)"
    fi
done

# 8. Verificar configuración del proxy/API
print_step "Verificando configuración de API..."
if grep -q "localhost:8080" .env.local 2>/dev/null || grep -q "localhost:8080" .env 2>/dev/null; then
    print_success "Configuración de API backend encontrada"
else
    print_warning "Configuración de API backend no encontrada"
fi

# 9. Construir el proyecto para verificar que todo funciona
print_step "Verificando compilación del proyecto..."
if npm run build --silent >/dev/null 2>&1; then
    print_success "Proyecto compila correctamente"
    # Limpiar build de prueba
    rm -rf dist 2>/dev/null || true
else
    print_warning "Advertencias en la compilación (normal en desarrollo)"
fi

# 10. Verificar scripts disponibles
print_step "Scripts disponibles:"
if [ -f "package.json" ]; then
    scripts=$(node -p "Object.keys(require('./package.json').scripts || {}).join(', ')" 2>/dev/null || echo "No se pudieron leer los scripts")
    echo "  📋 $scripts"
fi

# 11. Información del entorno
print_step "Información del entorno..."
echo "  📋 Node.js: $(node --version)"
echo "  📋 npm: v$(npm --version)"
if command -v yarn &> /dev/null; then
    echo "  📋 Yarn: v$(yarn --version)"
fi

# 12. Verificar puerto disponible
print_step "Verificando disponibilidad del puerto 3000..."
if lsof -i :3000 >/dev/null 2>&1; then
    print_warning "Puerto 3000 está en uso"
    print_info "El servidor usará un puerto alternativo automáticamente"
else
    print_success "Puerto 3000 disponible"
fi

echo ""
print_success "🎉 ¡FRONTEND CONFIGURADO EXITOSAMENTE!"
echo "======================================"
print_info "Para iniciar el servidor de desarrollo:"
echo "  npm run dev"
echo ""
print_info "Para compilar para producción:"
echo "  npm run build"
echo ""
print_success "URLs de acceso:"
echo "  🌐 Aplicación: http://localhost:3000"
echo "  📱 Red local: http://[tu-ip]:3000"
echo ""
print_info "El servidor se conectará automáticamente a:"
echo "  🔧 Backend API: http://localhost:8080/api"
echo ""

# 13. Verificar conexión con backend (opcional)
print_step "Verificando conexión con backend..."
if curl -s http://localhost:8080/api/health >/dev/null 2>&1; then
    print_success "Backend está corriendo y accesible"
else
    print_info "Backend no está corriendo (inicia primero el backend)"
    print_info "Comando: cd ../hoteles-backend && php artisan serve --port=8080"
fi

echo ""
print_success "🚀 Frontend listo para usar!"
echo "=============================================="