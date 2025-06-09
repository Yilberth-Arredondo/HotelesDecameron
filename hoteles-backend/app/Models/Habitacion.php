<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Habitacion extends Model
{
    use HasFactory;
    protected $table = 'rooms';

    protected $fillable = [
        'hotel_id',
        'tipo_habitacion',
        'acomodacion',
        'cantidad'
    ];

    protected $casts = [
        'cantidad' => 'integer',
        'hotel_id' => 'integer'
    ];

    // Constantes para validación
    public const TIPOS_HABITACION = ['ESTANDAR', 'JUNIOR', 'SUITE'];
    public const ACOMODACIONES = ['SENCILLA', 'DOBLE', 'TRIPLE', 'CUADRUPLE'];

    public const ACOMODACIONES_PERMITIDAS = [
        'ESTANDAR' => ['SENCILLA', 'DOBLE'],
        'JUNIOR' => ['TRIPLE', 'CUADRUPLE'],
        'SUITE' => ['SENCILLA', 'DOBLE', 'TRIPLE']
    ];

    // Relaciones
    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    // Métodos de validación
    public static function getAcomodacionesPermitidas(string $tipo): array
    {
        return self::ACOMODACIONES_PERMITIDAS[$tipo] ?? [];
    }

    public function esAcomodacionValida(): bool
    {
        $permitidas = self::getAcomodacionesPermitidas($this->tipo_habitacion);
        return in_array($this->acomodacion, $permitidas);
    }
}
