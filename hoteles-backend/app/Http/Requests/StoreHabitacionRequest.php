<?php

namespace App\Http\Requests;

use App\Models\Habitacion;
use App\Models\Hotel;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreHabitacionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'tipo_habitacion' => [
                'required',
                Rule::in(Habitacion::TIPOS_HABITACION)
            ],
            'acomodacion' => [
                'required',
                Rule::in(Habitacion::ACOMODACIONES),
                Rule::unique('rooms')->where(function ($query) {
                    return $query->where('hotel_id', $this->hotel_id)
                                 ->where('tipo_habitacion', $this->tipo_habitacion)
                                 ->where('acomodacion', $this->acomodacion);
                })
            ],
            'cantidad' => 'required|integer|min:1|max:200',
            'hotel_id' => 'required|exists:hotels,id'
        ];
    }

    public function messages(): array
    {
        return [
            'tipo_habitacion.required' => 'El tipo de habitación es obligatorio',
            'tipo_habitacion.in' => 'El tipo de habitación no es válido',
            'acomodacion.required' => 'La acomodación es obligatoria',
            'acomodacion.in' => 'La acomodación no es válida',
            'acomodacion.unique' => 'Ya existe una habitación con este tipo y acomodación en el hotel',
            'cantidad.required' => 'La cantidad es obligatoria',
            'cantidad.min' => 'La cantidad debe ser al menos 1',
            'hotel_id.required' => 'El hotel es obligatorio',
            'hotel_id.exists' => 'El hotel seleccionado no existe'
        ];
    }
}
