#!/bin/bash

# 🚀 HOTELES DECAMERON - VERIFICACIÓN RÁPIDA DE REQUISITOS
# Versión optimizada para verificación antes de instalación
# Autor: Yilberth-Arredondo

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones de output simplificadas
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo "🚀 Verificación rápida de requisitos..."

# Contadores
ok=0
total=0
critical_missing=0

# Función para verificar comando con múltiples rutas
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3
    local min_version=$4
    local is_critical=$5
    
    ((total++))
    
    # Verificar en PATH y rutas comunes
    local found=false
    local cmd_path=""
    
    # Verificar en PATH
    if command -v "$cmd" >/dev/null 2>&1; then
        cmd_path=$(command -v "$cmd")
        found=true
    else
        # Verificar rutas comunes
        local common_paths=(
            "/usr/bin/$cmd"
            "/usr/local/bin/$cmd"
            "/opt/homebrew/bin/$cmd"
            "/snap/bin/$cmd"
            "$HOME/.local/bin/$cmd"
        )
        
        for path in "${common_paths[@]}"; do
            if [ -x "$path" ]; then
                cmd_path="$path"
                found=true
                break
            fi
        done
    fi
    
    if [ "$found" = true ]; then
        if [ -n "$version_cmd" ]; then
            local current_version=$($cmd_path --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
            if [ -n "$current_version" ] && [ -n "$min_version" ]; then
                if awk "BEGIN {exit !($current_version >= $min_version)}" 2>/dev/null; then
                    success "$name v$current_version"
                    ((ok++))
                else
                    warning "$name v$current_version (se recomienda $min_version+)"
                    ((ok++))
                fi
            else
                success "$name (instalado en $cmd_path)"
                ((ok++))
            fi
        else
            success "$name"
            ((ok++))
        fi
    else
        error "$name no encontrado"
        if [ "$is_critical" = "true" ]; then
            ((critical_missing++))
        fi
    fi
}

# Verificar comandos principales
check_command "php" "PHP" "version" "8.1" "true"

# Verificar Node.js (con soporte para NVM)
((total++))
node_found=false

# Cargar NVM si está disponible
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
    \. "$NVM_DIR/nvm.sh"
    \. "$NVM_DIR/bash_completion" 2>/dev/null || true
fi

if command -v node >/dev/null 2>&1; then
    node_version=$(node --version 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
    full_version=$(node --version 2>/dev/null)
    
    if [ "$node_version" -ge 16 ] 2>/dev/null; then
        # Verificar si viene de NVM
        node_path=$(which node)
        if [[ "$node_path" == *".nvm"* ]]; then
            success "Node.js $full_version (via NVM)"
        else
            success "Node.js $full_version (sistema)"
        fi
        ((ok++))
        node_found=true
    else
        warning "Node.js $full_version (se recomienda 16+)"
        if [ -s "$HOME/.nvm/nvm.sh" ]; then
            info "NVM detectado - puedes actualizar con: nvm install 18 && nvm use 18"
        fi
        ((ok++))
        node_found=true
    fi
fi

if [ "$node_found" = false ]; then
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        warning "NVM instalado pero Node.js no activo"
        info "Activa Node.js con: nvm install 18 && nvm use 18"
    else
        error "Node.js no encontrado"
        info "Instala via NVM (recomendado) o sistema"
        ((critical_missing++))
    fi
fi

# Verificar npm
((total++))
if command -v npm >/dev/null 2>&1; then
    npm_version=$(npm --version 2>/dev/null)
    success "npm v$npm_version"
    ((ok++))
else
    if [ "$node_found" = true ]; then
        warning "Node.js instalado pero npm no disponible"
    else
        error "npm no encontrado"
        ((critical_missing++))
    fi
fi
check_command "psql" "PostgreSQL" "version" "" "true"
check_command "git" "Git" "version" "" "false"

# Verificar PostgreSQL corriendo
((total++))
if pgrep -x postgres >/dev/null 2>&1 || pgrep -x postgresql >/dev/null 2>&1; then
    success "PostgreSQL (servicio activo)"
    ((ok++))
elif systemctl is-active postgresql >/dev/null 2>&1; then
    success "PostgreSQL (systemctl activo)"
    ((ok++))
elif service postgresql status >/dev/null 2>&1; then
    success "PostgreSQL (service activo)"
    ((ok++))
else
    warning "PostgreSQL no está corriendo"
    info "Inicia con: sudo service postgresql start"
fi

# Verificar estructura del proyecto
((total++))
if [ -f "hoteles-backend/composer.json" ] && [ -f "hoteles-frontend/package.json" ]; then
    success "Estructura del proyecto"
    ((ok++))
else
    error "Estructura del proyecto incompleta"
    ((critical_missing++))
fi

echo ""
echo "Resultado: $ok/$total requisitos verificados"

# Evaluar resultado
if [ $critical_missing -eq 0 ] && [ $ok -eq $total ]; then
    success "✨ Sistema completamente listo ---------(recuerda ejecutar: composer --version)--------"
    exit 0
elif [ $critical_missing -eq 0 ] && [ $ok -ge $((total - 1)) ]; then
    warning "⚡ Sistema casi listo (puede continuar)"
    exit 0
elif [ $critical_missing -le 2 ]; then
    warning "⚠️  Faltan algunos requisitos pero se puede intentar"
    info "Usa: ./install-requirements.sh para instalar automáticamente"
    exit 1
else
    error "💥 Faltan requisitos críticos"
    echo ""
    info "Opciones para continuar:"
    info "1. Instalación automática: ./install-requirements.sh"
    info "2. Instalación manual:"
    info "   • Ubuntu/Debian: sudo apt update && sudo apt install php8.1 php8.1-cli composer nodejs npm postgresql git"
    info "   • macOS: brew install php composer node postgresql git"
    exit 1
fi