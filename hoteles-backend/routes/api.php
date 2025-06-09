<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\HabitacionController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
*/

// Ruta de prueba para verificar que la API funciona
Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API funcionando correctamente',
        'timestamp' => now()->toISOString(),
        'environment' => app()->environment(),
        'laravel_version' => app()->version(),
        'php_version' => PHP_VERSION,
        'database' => [
            'connected' => DB::connection()->getPdo() ? true : false,
            'driver' => config('database.default')
        ]
    ]);
});

// Rutas para hoteles
Route::apiResource('hoteles', HotelController::class);

// Rutas para habitaciones
Route::apiResource('hoteles.habitaciones', HabitacionController::class)->shallow();

// Ruta adicional de información
Route::get('/', function () {
    return response()->json([
        'message' => 'API de Hoteles Decameron',
        'version' => '1.0',
        'endpoints' => [
            'hoteles' => '/api/hoteles',
            'habitaciones' => '/api/hoteles/{hotel}/habitaciones',
            'health' => '/api/health'
        ]
    ]);
});