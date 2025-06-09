<?php

use Illuminate\Support\Str;

// Parsear DATABASE_URL si existe
$DATABASE_URL = env('DATABASE_URL') ? parse_url(env('DATABASE_URL')) : null;

return [

    'default' => env('DB_CONNECTION', 'pgsql'),

    'connections' => [

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DATABASE_URL'),
            'host' => env('DB_HOST', $DATABASE_URL['host'] ?? '127.0.0.1'),
            'port' => env('DB_PORT', $DATABASE_URL['port'] ?? '5432'),
            'database' => env('DB_DATABASE', isset($DATABASE_URL['path']) ? ltrim($DATABASE_URL['path'], '/') : 'forge'),
            'username' => env('DB_USERNAME', $DATABASE_URL['user'] ?? 'forge'),
            'password' => env('DB_PASSWORD', $DATABASE_URL['pass'] ?? ''),
            'charset' => 'utf8',
            'prefix' => '',
            'prefix_indexes' => true,
            'search_path' => 'public',
            'sslmode' => 'prefer',
        ],

        // ... resto de conexiones
    ],

    // ... resto del archivo
];