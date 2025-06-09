FROM php:8.1-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    postgresql-client \
    nginx \
    supervisor \
    procps \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP necesarias
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Configurar PHP
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/memory.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/execution.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/upload.ini \
    && echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/upload.ini

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de composer primero (para cache de Docker)
COPY composer.json composer.lock ./

# Instalar dependencias de PHP
RUN composer install --no-scripts --no-autoloader --no-dev --prefer-dist

# Copiar el resto del código
COPY . .

# Generar autoloader optimizado
RUN composer dump-autoload --optimize

# Crear directorios necesarios con permisos correctos
RUN mkdir -p \
    /var/log/nginx \
    /var/log/php-fpm \
    /var/log/supervisor \
    /var/cache/nginx \
    /run/php \
    storage/logs \
    storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache/data \
    bootstrap/cache \
    && chown -R www-data:www-data /app \
    && chmod -R 775 storage bootstrap/cache

# Remover configuración default de nginx
RUN rm -f /etc/nginx/sites-enabled/default

# Crear enlace simbólico para sites-enabled
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Script de inicio
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Exponer puerto (Railway lo sobrescribirá con $PORT)
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/health.php || exit 1

# Comando de inicio
CMD ["/start.sh"]