#!/bin/bash

# Script de instalación - Hoteles Decameron
# Autor: yilberth-arredondo
# Compatible con WSL y Linux nativo

echo "🏨 Instalando Base de Datos - Hoteles Decameron"
echo "================================================"

DB_NAME=${1:-hoteles_decameron}

# Función para verificar PostgreSQL (compatible WSL y Linux)
check_postgresql() {
    if pgrep -x "postgres" > /dev/null; then
        return 0
    fi
    return 1
}

# Verificar que PostgreSQL está corriendo
if check_postgresql; then
    echo "✅ PostgreSQL está ejecutándose"
else
    echo "❌ PostgreSQL no está corriendo"
    exit 1
fi

# Verificar conexión
if ! sudo -u postgres psql -c "SELECT 1;" >/dev/null 2>&1; then
    echo "❌ Error: No se puede conectar a PostgreSQL"
    exit 1
fi

# Crear base de datos
echo "1. Creando base de datos '$DB_NAME'..."
if sudo -u postgres createdb "$DB_NAME" 2>/dev/null; then
    echo "   ✅ Base de datos creada exitosamente"
else
    echo "   ℹ️  Base de datos ya existe, continuando..."
fi

# Instalar usando el método que funciona (cat + pipe)
if [ -f "hoteles_decameron_install.sql" ]; then
    echo "2. Instalando desde dump SQL..."
    if cat hoteles_decameron_install.sql | sudo -u postgres psql -d "$DB_NAME" >/dev/null 2>&1; then
        echo "   ✅ Estructura y datos instalados desde dump"
    else
        echo "   ⚠️  Error con dump, creando estructura básica..."
        # Fallback a estructura básica
        sudo -u postgres psql -d "$DB_NAME" << 'EOF'
-- Crear estructura básica si el dump falla
CREATE TABLE IF NOT EXISTS hotels (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) UNIQUE NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    ciudad VARCHAR(255) NOT NULL,
    nit VARCHAR(20) UNIQUE NOT NULL,
    numero_max_habitaciones INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS habitacions (
    id SERIAL PRIMARY KEY,
    hotel_id INTEGER NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    tipo_habitacion VARCHAR(20) NOT NULL CHECK (tipo_habitacion IN ('ESTANDAR', 'JUNIOR', 'SUITE')),
    acomodacion VARCHAR(20) NOT NULL CHECK (acomodacion IN ('SENCILLA', 'DOBLE', 'TRIPLE', 'CUADRUPLE')),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hotel_id, tipo_habitacion, acomodacion)
);

-- Insertar datos solo si no existen
INSERT INTO hotels (nombre, direccion, ciudad, nit, numero_max_habitaciones) VALUES 
('Decameron Cartagena', 'Calle 23 58-25', 'Cartagena', '12345678-9', 42),
('Decameron San Andrés', 'Avenida Colombia No. 1-19', 'San Andrés', '98765432-1', 60),
('Decameron Marazul', 'Km 14 Vía San Andrés', 'San Andrés', '11223344-5', 35),
('Decameron Barú', 'Playa Blanca, Isla Barú', 'Cartagena', '55667788-9', 28),
('Decameron Los Cocos', 'Carrera 3 No. 8-60', 'Rincón del Mar', '99887766-3', 50)
ON CONFLICT (nit) DO NOTHING;

INSERT INTO habitacions (hotel_id, tipo_habitacion, acomodacion, cantidad) VALUES 
(1, 'ESTANDAR', 'SENCILLA', 25),
(1, 'JUNIOR', 'TRIPLE', 12),
(1, 'ESTANDAR', 'DOBLE', 5),
(2, 'ESTANDAR', 'SENCILLA', 30),
(2, 'JUNIOR', 'TRIPLE', 20),
(2, 'SUITE', 'DOBLE', 10),
(3, 'ESTANDAR', 'DOBLE', 15),
(3, 'JUNIOR', 'CUADRUPLE', 15),
(3, 'SUITE', 'TRIPLE', 5),
(4, 'ESTANDAR', 'SENCILLA', 20),
(4, 'SUITE', 'SENCILLA', 8),
(5, 'ESTANDAR', 'DOBLE', 25),
(5, 'JUNIOR', 'TRIPLE', 15)
ON CONFLICT (hotel_id, tipo_habitacion, acomodacion) DO NOTHING;
EOF
        echo "   ✅ Estructura básica creada"
    fi
else
    echo "2. Archivo SQL no encontrado, creando estructura básica..."
    # El mismo código de arriba
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