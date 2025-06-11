<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
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
Route::apiResource('hotels', HotelController::class);

// Rutas para habitaciones
Route::apiResource('hotels.rooms', HabitacionController::class, ['parameters' => ['rooms' => 'habitacion']])->shallow();

// Ruta adicional de información
Route::get('/', function () {
    return response()->json([
        'message' => 'API de Hoteles Decameron',
        'version' => '1.0',
        'endpoints' => [
            'hotels' => '/api/hotels',
            'rooms' => '/api/hotels/{hotel}/rooms',
            'health' => '/api/health'
        ]
    ]);
});