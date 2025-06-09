<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HotelResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'nombre' => $this->nombre,
            'direccion' => $this->direccion,
            'ciudad' => $this->ciudad,
            'nit' => $this->nit,
            'numero_max_habitaciones' => $this->numero_max_habitaciones,
            'total_habitaciones_configuradas' => $this->whenLoaded('habitaciones', function () {
                return $this->habitaciones->sum('cantidad');
            }),
            'habitaciones_disponibles' => $this->whenLoaded('habitaciones', function () {
                return $this->numero_max_habitaciones - $this->habitaciones->sum('cantidad');
            }),
            'habitaciones' => $this->whenLoaded('habitaciones'),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
