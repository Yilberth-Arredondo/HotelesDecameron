# Usar la imagen base de PHP-FPM en lugar de CLI
FROM php:8.1-fpm

# Instalar dependencias del sistema
# Nota: Ahora incluimos nginx y supervisor
RUN apt-get update && apt-get install -y \
    git \
    curl \
    net-tools \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP necesarias para Laravel
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Configurar PHP para producción
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/memory.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/execution.ini \
    && echo "post_max_size = 50M" >> /usr/local/etc/php/conf.d/upload.ini \
    && echo "upload_max_filesize = 50M" >> /usr/local/etc/php/conf.d/upload.ini \
    && echo "opcache.enable = 1" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files = 4000" >> /usr/local/etc/php/conf.d/opcache.ini

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Verificar que el usuario www-data existe (normalmente ya existe en php-fpm)
RUN id -u www-data &>/dev/null || useradd -m -s /bin/bash www-data

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de composer primero (para aprovechar cache de Docker)
COPY composer.json composer.lock ./

# Instalar dependencias de PHP sin scripts para evitar errores
RUN composer install --no-scripts --no-autoloader --no-dev --prefer-dist --optimize-autoloader

# Copiar el resto del código de la aplicación
COPY . .

# Generar autoloader optimizado
RUN composer dump-autoload --optimize

# Crear todos los directorios necesarios
RUN mkdir -p \
    storage/logs \
    storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache/data \
    storage/app/public \
    bootstrap/cache \
    /var/log/nginx \
    /var/log/supervisor \
    /run/php

# Establecer permisos correctos para Laravel
RUN chown -R www-data:www-data /app \
    && chmod -R 775 storage bootstrap/cache

# Remover configuración default de nginx si existe
RUN rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Copiar y preparar el script de inicio
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

# Exponer el puerto (Railway lo sobrescribirá con $PORT)
EXPOSE 8080

# Healthcheck mejorado que verifica tanto PHP como Nginx
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://127.0.0.1:8080/ || exit 1

# Comando de inicio
CMD ["/start.sh"]