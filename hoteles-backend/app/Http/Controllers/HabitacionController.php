<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreHabitacionRequest;
use App\Http\Requests\UpdateHabitacionRequest;
use App\Http\Resources\HabitacionResource;
use App\Models\Habitacion;
use App\Models\Hotel;
use Illuminate\Http\JsonResponse;

class HabitacionController extends Controller
{
    public function index(Hotel $hotel): JsonResponse
    {
        $habitaciones = $hotel->habitaciones;

        return response()->json([
            'success' => true,
            'data' => HabitacionResource::collection($habitaciones)
        ]);
    }

    public function store(StoreHabitacionRequest $request, Hotel $hotel): JsonResponse
    {
        $habitacion = $hotel->habitaciones()->create($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Habitación agregada exitosamente',
            'data' => new HabitacionResource($habitacion)
        ], 201);
    }

    public function show(Habitacion $habitacion): JsonResponse
    {
        $habitacion->load('hotel');

        return response()->json([
            'success' => true,
            'data' => new HabitacionResource($habitacion)
        ]);
    }

    public function update(UpdateHabitacionRequest $request, Habitacion $habitacion): JsonResponse
    {
        $habitacion->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Habitación actualizada exitosamente',
            'data' => new HabitacionResource($habitacion)
        ]);
    }

    public function destroy(Habitacion $habitacion): JsonResponse
    {
        $habitacion->delete();

        return response()->json([
            'success' => true,
            'message' => 'Habitación eliminada exitosamente'
        ], 204);
    }

    // Endpoint para obtener configuración de tipos y acomodaciones
    public function getConfiguracion(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'tipos_habitacion' => Habitacion::TIPOS_HABITACION,
                'acomodaciones_permitidas' => Habitacion::ACOMODACIONES_PERMITIDAS,
                'todas_acomodaciones' => Habitacion::ACOMODACIONES
            ]
        ]);
    }
}
