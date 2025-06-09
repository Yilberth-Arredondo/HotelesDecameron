#!/bin/bash

echo "=== DIAGNÓSTICO RAILWAY ==="
echo "Fecha: $(date)"
echo ""

echo "=== VARIABLES DE ENTORNO ==="
echo "PORT: ${PORT:-NO DEFINIDO}"
echo "APP_URL: ${APP_URL:-NO DEFINIDO}"
echo "DB_HOST: ${DB_HOST:-NO DEFINIDO}"
echo "DB_CONNECTION: ${DB_CONNECTION:-NO DEFINIDO}"
echo ""

echo "=== VERSIONES ==="
php -v | head -1
nginx -v 2>&1
echo ""

echo "=== ESTRUCTURA DE ARCHIVOS ==="
echo "Contenido de /app:"
ls -la /app/ | head -10
echo ""
echo "Contenido de /app/public:"
ls -la /app/public/ | head -10
echo ""

echo "=== TEST DE PHP ==="
php -r "echo 'PHP CLI funciona correctamente\n';"
echo ""

echo "=== TEST DE COMPOSER ==="
cd /app && composer --version
echo ""

echo "=== TEST DE LARAVEL ==="
cd /app && php artisan --version 2>&1 || echo "Error ejecutando artisan"
echo ""

echo "=== TEST DE BASE DE DATOS ==="
cd /app && php artisan tinker --execute="try { \DB::select('SELECT 1'); echo 'DB OK'; } catch (\Exception \$e) { echo 'DB ERROR: ' . \$e->getMessage(); }" 2>&1 || echo "No se pudo probar DB"
echo ""

echo "=== CREANDO SERVIDOR DE PRUEBA ==="
echo "<?php echo 'Servidor PHP funcionando en puerto ' . ($_SERVER['SERVER_PORT'] ?? 'desconocido');" > /tmp/test.php

echo "Iniciando servidor PHP built-in en puerto ${PORT:-8080}..."
cd /tmp && php -S 0.0.0.0:${PORT:-8080} test.php