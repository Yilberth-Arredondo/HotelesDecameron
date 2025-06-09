<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return [
        'status' => 'ok',
        'message' => 'API de Hoteles Decameron funcionando',
        'documentation' => '/api/documentation',
        'endpoints' => [
            'hoteles' => '/api/hotels',
            'habitaciones' => '/api/rooms'
        ]
    ];
});
