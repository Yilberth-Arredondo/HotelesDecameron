<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateHabitacionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'tipo_habitacion' => 'required|string',
            'acomodacion' => 'required|string',
            'cantidad' => 'required|integer|min:1'
        ];
    }
}
