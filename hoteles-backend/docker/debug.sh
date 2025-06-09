#!/bin/bash
set -e

echo "🔍 DEBUG: Script iniciado correctamente - $(date)"
echo "🔍 DEBUG: PORT = ${PORT:-NO DEFINIDO}"
echo "🔍 DEBUG: Directorio actual = $(pwd)"
echo "🔍 DEBUG: Usuario = $(whoami)"

# Crear un archivo PHP simple para probar
echo "🔍 DEBUG: Creando archivo de prueba..."
mkdir -p /app/public
cat > /app/public/test.php << 'EOF'
<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'ok',
    'message' => 'Servidor funcionando',
    'port' => $_SERVER['SERVER_PORT'] ?? 'unknown',
    'time' => date('Y-m-d H:i:s')
]);
EOF

echo "🔍 DEBUG: Contenido de /app/public:"
ls -la /app/public/

# Intentar con servidor PHP simple primero
echo "🔍 DEBUG: Iniciando servidor PHP simple en puerto ${PORT:-8080}..."
cd /app/public
php -S 0.0.0.0:${PORT:-8080} -t .

# Si llegamos aquí, algo salió mal
echo "🔍 DEBUG: El servidor PHP se detuvo inesperadamente"