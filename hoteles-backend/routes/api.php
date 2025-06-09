<?php

use App\Http\Controllers\HotelController;
use App\Http\Controllers\HabitacionController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Rutas de hoteles
Route::apiResource('hotels', HotelController::class);

// Rutas de habitaciones por hotel
Route::apiResource('hotels.habitaciones', HabitacionController::class)
    ->except(['show']);

// Rutas independientes de habitaciones
Route::apiResource('habitaciones', HabitacionController::class)
    ->only(['show', 'update', 'destroy']);

// Endpoint para configuración de habitaciones
Route::get('configuracion/habitaciones', [HabitacionController::class, 'getConfiguracion']);
