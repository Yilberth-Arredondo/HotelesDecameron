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
                Rule::in(Habitacion::ACOMODACIONES)
            ],
            'cantidad' => 'required|integer|min:1|max:200'
        ];
    }

    public function messages(): array
    {
        return [
            'tipo_habitacion.required' => 'El tipo de habitación es obligatorio',
            'acomodacion.required' => 'La acomodación es obligatoria',
            'cantidad.required' => 'La cantidad es obligatoria',
            'cantidad.min' => 'La cantidad debe ser al menos 1'
        ];
    }
}
