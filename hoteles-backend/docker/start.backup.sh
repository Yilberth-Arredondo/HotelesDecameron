#!/bin/bash
set -e

echo "🚀 Iniciando aplicación Laravel en Railway..."
echo "⏰ $(date)"

PORT=${PORT:-8080}
echo "📍 Puerto: $PORT"

cd /app

# Permisos básicos
echo "🔧 Configurando permisos..."
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

# Verificar conexión a DB
echo "🔍 Verificando base de datos..."
php artisan tinker --execute="try { \DB::select('SELECT 1'); echo '✅ Base de datos conectada'; } catch (\Exception \$e) { echo '❌ Error DB: ' . \$e->getMessage(); }" || true
echo ""

# Limpiar caché
echo "🧹 Limpiando caché..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Ejecutar migraciones
echo "📦 Ejecutando migraciones..."
php artisan migrate --force || echo "⚠️  Error en migraciones"

# Ejecutar seeders
echo "🌱 Ejecutando seeders..."
php artisan db:seed --force || echo "⚠️  Error en seeders"

# Cachear configuración
echo "⚡ Optimizando..."
php artisan config:cache
php artisan route:cache

# Mostrar información
echo ""
echo "✅ Aplicación lista!"
echo "🌐 URL: $APP_URL"
echo "📍 Puerto: $PORT"
echo ""
echo "📋 Endpoints disponibles:"
echo "   - $APP_URL/api/health"
echo "   - $APP_URL/api/hotels"
echo "   - $APP_URL/api/hotels/{id}/rooms"
echo ""

# Opción 1: Usar servidor de Laravel (más simple)
echo "🚀 Iniciando servidor Laravel..."
exec php artisan serve --host=0.0.0.0 --port=$PORT