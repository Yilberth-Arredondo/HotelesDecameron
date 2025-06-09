#!/bin/bash

# Script de instalación - Hoteles Decameron
# Autor: yilberth-arredondo
# Fecha: $(date +'%Y-%m-%d')

echo "🏨 Instalando Base de Datos - Hoteles Decameron"
echo "================================================"

DB_NAME=${1:-hoteles_decameron}

# Verificar que PostgreSQL está corriendo
if ! sudo systemctl is-active --quiet postgresql; then
    echo "❌ Error: PostgreSQL no está corriendo"
    echo "   Solución: sudo systemctl start postgresql"
    exit 1
fi

# Crear base de datos
echo "1. Creando base de datos '$DB_NAME'..."
if sudo -u postgres createdb "$DB_NAME" 2>/dev/null; then
    echo "   ✅ Base de datos creada exitosamente"
else
    echo "   ⚠️  Base de datos ya existe, continuando..."
fi

# Instalar dump
echo "2. Instalando estructura y datos..."
if sudo -u postgres psql -d "$DB_NAME" -f hoteles_decameron_install.sql >/dev/null 2>&1; then
    echo "   ✅ Estructura y datos instalados"
else
    echo "   ❌ Error al instalar el dump"
    exit 1
fi

# Verificar instalación
echo "3. Verificando instalación..."
HOTELS=$(sudo -u postgres psql -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM hotels;" 2>/dev/null | xargs)
HABITACIONES=$(sudo -u postgres psql -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM habitacions;" 2>/dev/null | xargs)

if [[ "$HOTELS" -gt 0 ]] && [[ "$HABITACIONES" -gt 0 ]]; then
    echo "   ✅ Verificación exitosa"
    echo "   📊 Hoteles instalados: $HOTELS"
    echo "   🏠 Configuraciones de habitaciones: $HABITACIONES"
else
    echo "   ❌ Error en la verificación"
    exit 1
fi

echo ""
echo "🎉 ¡Instalación completada exitosamente!"
echo ""
echo "📝 Para conectar a la base de datos:"
echo "   sudo -u postgres psql -d $DB_NAME"
echo ""
echo "🧪 Para probar la aplicación:"
echo "   cd ../hoteles-backend"
echo "   php artisan serve"
echo "   curl http://127.0.0.1:8000/api/hotels"
echo ""
echo "🔧 Para configurar Laravel (.env):"
echo "   DB_DATABASE=$DB_NAME"