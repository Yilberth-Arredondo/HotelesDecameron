<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreHotelRequest;
use App\Http\Requests\UpdateHotelRequest;
use App\Http\Resources\HotelResource;
use App\Models\Hotel;
use Illuminate\Http\JsonResponse;

class HotelController extends Controller
{
    public function index(): JsonResponse
    {
        $hotels = Hotel::with('habitaciones')->get();

        return response()->json([
            'success' => true,
            'data' => $hotels
        ]);
    }

    public function store(StoreHotelRequest $request): JsonResponse
    {
        $request->validate([
            'nombre' => 'required|string|unique:hotels',
            'direccion' => 'required|string',
            'ciudad' => 'required|string',
            'nit' => 'required|string|unique:hotels',
            'numero_max_habitaciones' => 'required|integer|min:1'
        ]);

        $hotel = Hotel::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Hotel creado exitosamente',
            'data' => $hotel
        ], 201);
    }

    public function show(Hotel $hotel): JsonResponse
    {
        $hotel->load('habitaciones');

        return response()->json([
            'success' => true,
            'data' => $hotel
        ]);
    }

    public function update(UpdateHotelRequest $request, Hotel $hotel): JsonResponse
    {
        $request->validate([
            'nombre' => 'required|string|unique:hotels,nombre,' . $hotel->id,
            'direccion' => 'required|string',
            'ciudad' => 'required|string',
            'nit' => 'required|string|unique:hotels,nit,' . $hotel->id,
            'numero_max_habitaciones' => 'required|integer|min:1'
        ]);

        $hotel->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Hotel actualizado exitosamente',
            'data' => $hotel
        ]);
    }

    public function destroy(Hotel $hotel): JsonResponse
    {
        $hotel->delete();

        return response()->json([
            'success' => true,
            'message' => 'Hotel eliminado exitosamente'
        ], 204);
    }
}
