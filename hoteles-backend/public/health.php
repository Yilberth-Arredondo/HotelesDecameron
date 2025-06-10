<?php
/**
 * Archivo de verificación de salud para Railway
 * Este archivo proporciona información básica sin cargar Laravel
 */

// Configurar headers
header('Content-Type: application/json');
header('Cache-Control: no-cache, no-store, must-revalidate');

// Información del sistema
$health = [
    'status' => 'ok',
    'timestamp' => date('Y-m-d H:i:s'),
    'timezone' => date_default_timezone_get(),
    'php' => [
        'version' => PHP_VERSION,
        'sapi' => PHP_SAPI,
        'memory_limit' => ini_get('memory_limit'),
        'max_execution_time' => ini_get('max_execution_time'),
        'upload_max_filesize' => ini_get('upload_max_filesize'),
        'post_max_size' => ini_get('post_max_size'),
    ],
    'server' => [
        'software' => $_SERVER['SERVER_SOFTWARE'] ?? 'unknown',
        'port' => $_SERVER['SERVER_PORT'] ?? 'unknown',
        'protocol' => $_SERVER['SERVER_PROTOCOL'] ?? 'unknown',
    ],
    'extensions' => [
        'pdo' => extension_loaded('pdo'),
        'pdo_pgsql' => extension_loaded('pdo_pgsql'),
        'mbstring' => extension_loaded('mbstring'),
        'gd' => extension_loaded('gd'),
        'opcache' => extension_loaded('opcache'),
    ]
];

// Verificar OPcache si está disponible
if (function_exists('opcache_get_status')) {
    $opcache_status = opcache_get_status(false);
    if ($opcache_status) {
        $health['opcache'] = [
            'enabled' => $opcache_status['opcache_enabled'] ?? false,
            'memory_usage' => $opcache_status['memory_usage']['used_memory'] ?? 0,
            'hit_rate' => $opcache_status['opcache_statistics']['opcache_hit_rate'] ?? 0,
        ];
    }
}

// Responder con JSON
echo json_encode($health, JSON_PRETTY_PRINT);
?>