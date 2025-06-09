<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Hotel extends Model
{
    use HasFactory;

    protected $fillable = [
        'nombre',
        'direccion',
        'ciudad',
        'nit',
        'numero_max_habitaciones'
    ];

    protected $casts = [
        'numero_max_habitaciones' => 'integer',
    ];

    // Relaciones
    public function habitaciones(): HasMany
    {
        return $this->hasMany(Habitacion::class);
    }

    // Métodos auxiliares
    public function getTotalHabitacionesConfiguradas(): int
    {
        return $this->habitaciones()->sum('cantidad');
    }

    public function getHabitacionesDisponibles(): int
    {
        return $this->numero_max_habitaciones - $this->getTotalHabitacionesConfiguradas();
    }

    // Scopes
    public function scopeConHabitaciones($query)
    {
        return $query->with('habitaciones');
    }
}
