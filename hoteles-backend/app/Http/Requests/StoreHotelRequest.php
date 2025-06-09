<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreHotelRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nombre' => 'required|string|max:255|unique:hotels,nombre',
            'direccion' => 'required|string|max:255',
            'ciudad' => 'required|string|max:100',
            'nit' => 'required|string|max:20|unique:hotels,nit',
            'numero_max_habitaciones' => 'required|integer|min:1|max:1000'
        ];
    }

    public function messages(): array
    {
        return [
            'nombre.required' => 'El nombre del hotel es obligatorio',
            'nombre.unique' => 'Ya existe un hotel con este nombre',
            'direccion.required' => 'La dirección es obligatoria',
            'ciudad.required' => 'La ciudad es obligatoria',
            'nit.required' => 'El NIT es obligatorio',
            'nit.unique' => 'Ya existe un hotel con este NIT',
            'numero_max_habitaciones.required' => 'El número máximo de habitaciones es obligatorio',
            'numero_max_habitaciones.min' => 'Debe tener al menos 1 habitación',
            'numero_max_habitaciones.max' => 'Máximo 1000 habitaciones permitidas'
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'nombre' => trim($this->nombre ?? ''),
            'direccion' => trim($this->direccion ?? ''),
            'ciudad' => trim($this->ciudad ?? ''),
            'nit' => trim($this->nit ?? '')
        ]);
    }
}
