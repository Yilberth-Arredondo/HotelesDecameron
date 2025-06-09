# 🚀 Instalación Stack Completo - Hoteles Decameron

## 📋 Stack Requerido
- **PHP 8.1+** (con extensiones)
- **Composer** (gestor de dependencias PHP)
- **Node.js 18+** y **npm**
- **PostgreSQL 14+**
- **Git**
- **Editor de código** (VS Code recomendado)

---

# 🪟 **WINDOWS**

## 1. PHP y Composer

### Opción A: XAMPP (Recomendado para principiantes)
```bash
# 1. Descargar XAMPP con PHP 8.1+
# https://www.apachefriends.org/download.html

# 2. Instalar XAMPP en C:\xampp

# 3. Agregar PHP al PATH
# Panel de Control > Sistema > Variables de entorno
# Agregar: C:\xampp\php

# 4. Verificar instalación
php -v
```

### Opción B: PHP directo (Recomendado para desarrolladores)
```bash
# 1. Descargar PHP 8.1+ desde php.net
# https://windows.php.net/download/

# 2. Extraer en C:\php

# 3. Copiar php.ini-development a php.ini

# 4. Editar php.ini y habilitar extensiones:
extension=pdo_pgsql
extension=pgsql
extension=openssl
extension=curl
extension=fileinfo
extension=mbstring

# 5. Agregar C:\php al PATH del sistema
```

### Instalar Composer
```bash
# 1. Descargar desde getcomposer.org
# https://getcomposer.org/Composer-Setup.exe

# 2. Ejecutar el instalador

# 3. Verificar
composer -V
```

## 2. Node.js y npm
```bash
# 1. Descargar Node.js LTS desde nodejs.org
# https://nodejs.org/

# 2. Instalar con las opciones por defecto

# 3. Verificar instalación
node -v
npm -v
```

## 3. PostgreSQL
```bash
# 1. Descargar PostgreSQL 14+ desde postgresql.org
# https://www.postgresql.org/download/windows/

# 2. Durante la instalación:
#    - Puerto: 5432 (default)
#    - Usuario: postgres
#    - Contraseña: [tu_password]

# 3. Verificar instalación
psql -U postgres -h localhost
```

## 4. Git
```bash
# 1. Descargar Git para Windows
# https://git-scm.com/download/win

# 2. Instalar con configuración por defecto

# 3. Configurar usuario
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

---

# 🍎 **macOS**

## 1. Homebrew (Gestor de paquetes)
```bash
# Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Agregar al PATH
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 2. PHP y Composer
```bash
# Instalar PHP
brew install php@8.1

# Agregar al PATH
echo 'export PATH="/opt/homebrew/opt/php@8.1/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verificar
php -v

# Instalar Composer
brew install composer

# Verificar
composer -V
```

## 3. Node.js y npm
```bash
# Opción 1: Con Homebrew
brew install node

# Opción 2: Con NVM (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.zshrc
nvm install --lts
nvm use --lts

# Verificar
node -v
npm -v
```

## 4. PostgreSQL
```bash
# Instalar PostgreSQL
brew install postgresql@14

# Iniciar servicio
brew services start postgresql@14

# Crear usuario
createdb $(whoami)
psql postgres -c "CREATE USER postgres WITH PASSWORD 'password' SUPERUSER;"

# Verificar
psql -U postgres -h localhost
```

## 5. Git
```bash
# Git viene preinstalado en macOS, pero actualizar:
brew install git

# Configurar
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

---

# 🐧 **LINUX (Ubuntu/Debian)**

## 1. Actualizar sistema
```bash
sudo apt update && sudo apt upgrade -y
```

## 2. PHP y Composer
```bash
# Instalar PHP y extensiones
sudo apt install -y php8.1 php8.1-cli php8.1-common php8.1-mysql php8.1-pgsql \
php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath

# Verificar PHP
php -v

# Instalar Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Verificar Composer
composer -V
```

## 3. Node.js y npm
```bash
# Opción 1: Desde repositorios
sudo apt install -y nodejs npm

# Opción 2: Con NVM (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Verificar
node -v
npm -v
```

## 4. PostgreSQL
```bash
# Instalar PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Iniciar servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configurar usuario
sudo -u postgres psql -c "CREATE USER postgres WITH PASSWORD 'password' SUPERUSER;"

# Verificar
sudo -u postgres psql
```

## 5. Git
```bash
# Instalar Git
sudo apt install -y git

# Configurar
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

---

# ✅ **Verificación de Instalación**

Ejecuta estos comandos para verificar que todo esté instalado correctamente:

```bash
# PHP
php -v
# Debería mostrar: PHP 8.1.x

# Composer
composer -V
# Debería mostrar: Composer version 2.x

# Node.js
node -v
# Debería mostrar: v18.x.x o superior

# npm
npm -v
# Debería mostrar: 9.x.x o superior

# PostgreSQL
psql --version
# Debería mostrar: psql (PostgreSQL) 14.x

# Git
git --version
# Debería mostrar: git version 2.x
```

---

# 🔧 **Configuración Adicional**

## VS Code (Editor recomendado)
```bash
# Extensiones útiles:
# - PHP Intelephense
# - Laravel Extension Pack
# - ES7+ React/Redux/React-Native snippets
# - Thunder Client (para probar APIs)
# - GitLens
```

## Variables de Entorno Globales
```bash
# Windows (PowerShell como administrador)
[Environment]::SetEnvironmentVariable("COMPOSER_HOME", "$env:APPDATA\Composer", "User")

# macOS/Linux (.bashrc o .zshrc)
export COMPOSER_HOME="$HOME/.composer"
export PATH="$COMPOSER_HOME/vendor/bin:$PATH"
```

---

# 🚨 **Solución de Problemas Comunes**

## PHP no encuentra extensiones
```bash
# Verificar extensiones habilitadas
php -m

# Si faltan extensiones, editar php.ini y descomentar:
extension=pdo_pgsql
extension=pgsql
extension=openssl
extension=curl
```

## Composer muy lento
```bash
# Configurar mirror más rápido
composer config -g repo.packagist composer https://packagist.org
```

## Node.js versión incorrecta
```bash
# Con NVM cambiar versión
nvm list
nvm use 18.19.0
```

## PostgreSQL no se conecta
```bash
# Verificar si está corriendo
# Windows: Servicios > PostgreSQL
# macOS: brew services list
# Linux: sudo systemctl status postgresql
```

---
