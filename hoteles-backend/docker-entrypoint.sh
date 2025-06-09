#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel..."

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a PostgreSQL..."
until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USERNAME" -d "$DB_DATABASE" -c '\q' 2>/dev/null; do
  >&2 echo "PostgreSQL no está listo - esperando..."
  sleep 2
done

echo "✅ PostgreSQL está listo!"

# Ejecutar migraciones
echo "🔄 Ejecutando migraciones..."
php artisan migrate --force

# Verificar si hay datos
HOTEL_COUNT=$(php artisan tinker --execute="echo \App\Models\Hotel::count();" 2>/dev/null | tail -1)

if [ "$HOTEL_COUNT" = "0" ] || [ -z "$HOTEL_COUNT" ]; then
    echo "📊 Base de datos vacía, ejecutando seeders..."
    php artisan db:seed --force || echo "⚠️ Seeders no disponibles o ya ejecutados"
fi

# Limpiar y optimizar caché
echo "🧹 Optimizando aplicación..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "✅ Aplicación lista!"

# Ejecutar comando principal
exec "$@"