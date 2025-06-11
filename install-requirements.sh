#!/bin/bash

# 📦 HOTELES DECAMERON - INSTALADOR DE REQUISITOS
# Script para instalar automáticamente todos los requisitos
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
print_header() { echo -e "${BOLD}${BLUE}📦 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_step() { echo -e "${BOLD}${YELLOW}📋 $1${NC}"; }

echo ""
print_header "INSTALADOR AUTOMÁTICO DE REQUISITOS"
echo "==========================================="
print_info "Este script instalará automáticamente:"
echo "  • PHP 8.1+ y extensiones necesarias"
echo "  • Node.js 18+ LTS y npm"
echo "  • PostgreSQL"
echo "  • Git y herramientas básicas"
echo ""

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Actualizar sistema
update_system() {
    print_step "Actualizando sistema..."
    
    case $OS in
        "debian")
            sudo apt update && sudo apt upgrade -y
            print_success "Sistema Debian/Ubuntu actualizado"
            ;;
        "redhat")
            sudo yum update -y || sudo dnf update -y
            print_success "Sistema RedHat/CentOS actualizado"
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew update
                print_success "Homebrew actualizado"
            else
                print_error "Homebrew no instalado. Instala desde: https://brew.sh"
                exit 1
            fi
            ;;
        *)
            print_warning "Sistema no reconocido, saltando actualización"
            ;;
    esac
}

# Instalar PHP
install_php() {
    print_step "Instalando PHP 8.1+..."
    
    if command -v php >/dev/null 2>&1; then
        php_version=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;" 2>/dev/null)
        if [[ "$php_version" == "8."* ]]; then
            print_success "PHP $php_version ya instalado"
            return
        fi
    fi
    
    case $OS in
        "debian")
            # Agregar repositorio de PHP
            sudo apt install -y software-properties-common
            sudo add-apt-repository ppa:ondrej/php -y
            sudo apt update
            
            # Instalar PHP y extensiones
            sudo apt install -y \
                php8.1 \
                php8.1-cli \
                php8.1-fpm \
                php8.1-mysql \
                php8.1-pgsql \
                php8.1-sqlite3 \
                php8.1-curl \
                php8.1-gd \
                php8.1-mbstring \
                php8.1-xml \
                php8.1-zip \
                php8.1-bcmath \
                php8.1-intl \
                php8.1-json \
                php8.1-tokenizer \
                unzip
            
            print_success "PHP 8.1 y extensiones instaladas"
            ;;
        "macos")
            brew install php@8.1
            brew link php@8.1 --force
            print_success "PHP 8.1 instalado via Homebrew"
            ;;
        *)
            print_error "Instalación de PHP no soportada para este OS"
            ;;
    esac
}

# Instalar Node.js
install_nodejs() {
    print_step "Verificando Node.js..."
    
    # Verificar si NVM está instalado
    if [ -s "$HOME/.nvm/nvm.sh" ] || command -v nvm >/dev/null 2>&1; then
        print_success "NVM detectado - usando gestión via NVM"
        
        # Cargar NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        # Verificar versión actual de Node
        if command -v node >/dev/null 2>&1; then
            node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
            if [ "$node_version" -ge 16 ] 2>/dev/null; then
                print_success "Node.js v$(node --version) ya instalado via NVM"
                print_info "npm versión: $(npm --version 2>/dev/null || echo 'no disponible')"
                return
            else
                print_warning "Node.js v$(node --version) es muy antiguo"
                print_info "Instalando Node.js 18 LTS via NVM..."
                
                # Instalar Node 18 LTS con NVM
                nvm install 18
                nvm use 18
                nvm alias default 18
                
                print_success "Node.js 18 LTS instalado via NVM"
                print_info "Versión activa: $(node --version)"
            fi
        else
            print_info "Node.js no está activo, instalando Node.js 18 LTS via NVM..."
            
            # Instalar Node 18 LTS con NVM
            nvm install 18
            nvm use 18
            nvm alias default 18
            
            print_success "Node.js 18 LTS instalado via NVM"
            print_info "Versión activa: $(node --version)"
        fi
        
        return
    fi
    
    # Si no hay NVM, verificar si hay conflictos con instalaciones del sistema
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$node_version" -ge 16 ] 2>/dev/null; then
            print_success "Node.js v$(node --version) ya instalado (sistema)"
            return
        else
            print_warning "Node.js v$(node --version) es muy antiguo"
            print_info "Se recomienda usar NVM para gestionar versiones de Node.js"
            
            # Preguntar si instalar NVM
            read -p "¿Quieres instalar NVM para gestionar Node.js? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_nvm_and_node
                return
            else
                print_info "Continuando con instalación via sistema..."
            fi
        fi
    fi
    
    case $OS in
        "debian")
            # Verificar si hay conflictos conocidos
            if dpkg -l | grep -q "libnode-dev.*12\."; then
                print_warning "Detectado conflicto con libnode-dev versión 12"
                print_info "Removiendo paquetes conflictivos..."
                
                sudo apt remove -y nodejs libnode-dev libnode72 2>/dev/null || true
                sudo apt autoremove -y 2>/dev/null || true
            fi
            
            print_info "Instalando Node.js 18 LTS desde NodeSource..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            
            if sudo apt-get install -y nodejs; then
                print_success "Node.js 18 LTS instalado"
            else
                print_error "Error en instalación, recomendando NVM..."
                install_nvm_and_node
            fi
            ;;
        "macos")
            brew install node@18
            brew link node@18 --force
            print_success "Node.js 18 instalado via Homebrew"
            ;;
        *)
            print_warning "Sistema no soportado, instalando NVM..."
            install_nvm_and_node
            ;;
    esac
}

# Función para instalar NVM y Node.js
install_nvm_and_node() {
    print_step "Instalando NVM y Node.js..."
    
    # Instalar NVM
    print_info "Descargando e instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Cargar NVM en la sesión actual
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Instalar Node.js 18 LTS
    print_info "Instalando Node.js 18 LTS con NVM..."
    nvm install 18
    nvm use 18
    nvm alias default 18
    
    print_success "NVM y Node.js 18 LTS instalados"
    print_info "Versión de Node.js: $(node --version)"
    print_info "Versión de npm: $(npm --version)"
    print_info "Para usar NVM en nuevas terminales, ejecuta: source ~/.bashrc"
}

# Instalar PostgreSQL
install_postgresql() {
    print_step "Instalando PostgreSQL..."
    
    if command -v psql >/dev/null 2>&1; then
        print_success "PostgreSQL ya instalado"
        # Intentar iniciar el servicio
        sudo service postgresql start 2>/dev/null || sudo systemctl start postgresql 2>/dev/null || true
        return
    fi
    
    case $OS in
        "debian")
            sudo apt install -y postgresql postgresql-contrib
            sudo systemctl enable postgresql
            sudo systemctl start postgresql
            print_success "PostgreSQL instalado y iniciado"
            ;;
        "macos")
            brew install postgresql
            brew services start postgresql
            print_success "PostgreSQL instalado via Homebrew"
            ;;
        *)
            print_error "Instalación de PostgreSQL no soportada para este OS"
            ;;
    esac
}

# Instalar herramientas adicionales
install_tools() {
    print_step "Instalando herramientas adicionales..."
    
    case $OS in
        "debian")
            sudo apt install -y git curl wget unzip zip
            print_success "Git, curl y herramientas básicas instaladas"
            ;;
        "macos")
            brew install git curl wget
            print_success "Git, curl y herramientas básicas instaladas"
            ;;
        *)
            print_warning "Instalación de herramientas no soportada para este OS"
            ;;
    esac
}

# Configurar PostgreSQL
configure_postgresql() {
    print_step "Configurando PostgreSQL..."
    
    # Configurar usuario postgres con contraseña
    if sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';" 2>/dev/null; then
        print_success "Usuario postgres configurado"
    else
        print_warning "No se pudo configurar usuario postgres (normal en algunas instalaciones)"
    fi
    
    # Configurar acceso local
    if [ -f "/etc/postgresql/*/main/pg_hba.conf" ]; then
        sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/' /etc/postgresql/*/main/pg_hba.conf 2>/dev/null || true
        sudo systemctl restart postgresql 2>/dev/null || true
        print_success "Configuración de acceso actualizada"
    fi
}

# Verificar instalación
verify_installation() {
    print_step "Verificando instalación..."
    
    local all_good=true
    
    # Verificar PHP
    if command -v php >/dev/null 2>&1; then
        print_success "✓ PHP $(php --version | head -n1 | cut -d' ' -f2)"
    else
        print_error "✗ PHP no disponible"
        all_good=false
    fi
    
    # Verificar Node.js
    if command -v node >/dev/null 2>&1; then
        print_success "✓ Node.js $(node --version)"
    else
        print_error "✗ Node.js no disponible"
        all_good=false
    fi
    
    # Verificar npm
    if command -v npm >/dev/null 2>&1; then
        print_success "✓ npm $(npm --version)"
    else
        print_error "✗ npm no disponible"
        all_good=false
    fi
    
    # Verificar PostgreSQL
    if command -v psql >/dev/null 2>&1; then
        if pgrep -x postgres >/dev/null 2>&1; then
            print_success "✓ PostgreSQL corriendo"
        else
            print_warning "✓ PostgreSQL instalado pero no corriendo"
            print_info "Inicia con: sudo service postgresql start"
        fi
    else
        print_error "✗ PostgreSQL no disponible"
        all_good=false
    fi
    
    # Verificar Git
    if command -v git >/dev/null 2>&1; then
        print_success "✓ Git $(git --version | cut -d' ' -f3)"
    else
        print_error "✗ Git no disponible"
        all_good=false
    fi
    
    echo ""
    if [ "$all_good" = true ]; then
        print_success "🎉 ¡Todos los requisitos instalados correctamente!"
        print_info "Ahora puedes ejecutar: ./run.sh"
    else
        print_error "❌ Algunos componentes no se instalaron correctamente"
        print_info "Revisa los errores anteriores"
    fi
}

# Función principal
main() {
    OS=$(detect_os)
    print_info "Sistema detectado: $OS"
    
    if [ "$OS" = "unknown" ]; then
        print_error "Sistema operativo no soportado"
        print_info "Instala manualmente: PHP 8.1+, Composer, Node.js 16+, PostgreSQL, Git"
        exit 1
    fi
    
    echo ""
    read -p "¿Continuar con la instalación? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Instalación cancelada"
        exit 0
    fi
    
    echo ""
    update_system
    install_php
    install_nodejs
    install_postgresql
    install_tools
    configure_postgresql
    verify_installation
    
    echo ""
    print_header "INSTALACIÓN COMPLETADA"
    echo "======================="
    print_info "Próximos pasos:"
    echo "1. Ejecutar verificación: ./quick-check.sh"
    echo "2. Instalar proyecto: ./run.sh"
}

# Verificar permisos de sudo
if ! sudo -n true 2>/dev/null; then
    print_warning "Este script requiere permisos de sudo"
    print_info "Te pedirá la contraseña durante la instalación"
    echo ""
fi

# Ejecutar función principal
main "$@"