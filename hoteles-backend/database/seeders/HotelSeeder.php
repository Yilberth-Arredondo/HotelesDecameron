<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Hotel;
use App\Models\Habitacion;

class HotelSeeder extends Seeder
{
    public function run()
    {
        // Datos de hoteles
        $hoteles = [
            [
                'nombre' => 'Decameron Cartagena',
                'direccion' => 'Calle 23 58-25',
                'ciudad' => 'Cartagena',
                'nit' => '12345678-9',
                'numero_habitaciones' => 42
            ],
            [
                'nombre' => 'Decameron San Andrés',
                'direccion' => 'Avenida Colombia No. 1-19',
                'ciudad' => 'San Andrés',
                'nit' => '98765432-1',
                'numero_habitaciones' => 60
            ],
            [
                'nombre' => 'Decameron Marazul',
                'direccion' => 'Km 14 Vía San Andrés',
                'ciudad' => 'San Andrés',
                'nit' => '11223344-5',
                'numero_habitaciones' => 35
            ],
            [
                'nombre' => 'Decameron Barú',
                'direccion' => 'Playa Blanca, Isla Barú',
                'ciudad' => 'Cartagena',
                'nit' => '55667788-9',
                'numero_habitaciones' => 28
            ],
            [
                'nombre' => 'Decameron Los Cocos',
                'direccion' => 'Carrera 3 No. 8-60',
                'ciudad' => 'Rincón del Mar',
                'nit' => '99887766-3',
                'numero_habitaciones' => 50
            ]
        ];

        foreach ($hoteles as $hotelData) {
            $hotel = Hotel::create($hotelData);
            
            switch ($hotel->id) {
                case 1:
                    Habitacion::create([
                        'hotel_id' => $hotel->id, 
                        'tipo_habitacion' => 'ESTANDAR', 
                        'acomodacion' => 'SENCILLA', 
                        'cantidad' => 25
                    ]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'JUNIOR', 'acomodacion' => 'TRIPLE', 'cantidad' => 12]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'ESTANDAR', 'acomodacion' => 'DOBLE', 'cantidad' => 5]);
                    break;
                case 2:
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'ESTANDAR', 'acomodacion' => 'SENCILLA', 'cantidad' => 30]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'JUNIOR', 'acomodacion' => 'TRIPLE', 'cantidad' => 20]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'SUITE', 'acomodacion' => 'DOBLE', 'cantidad' => 10]);
                    break;
                case 3:
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'ESTANDAR', 'acomodacion' => 'DOBLE', 'cantidad' => 15]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'JUNIOR', 'acomodacion' => 'CUADRUPLE', 'cantidad' => 15]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'SUITE', 'acomodacion' => 'TRIPLE', 'cantidad' => 5]);
                    break;
                case 4:
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'ESTANDAR', 'acomodacion' => 'SENCILLA', 'cantidad' => 20]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'SUITE', 'acomodacion' => 'SENCILLA', 'cantidad' => 8]);
                    break;
                case 5:
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'ESTANDAR', 'acomodacion' => 'DOBLE', 'cantidad' => 25]);
                    Habitacion::create(['hotel_id' => $hotel->id, 'tipo_habitacion' => 'JUNIOR', 'acomodacion' => 'TRIPLE', 'cantidad' => 15]);
                    break;
            }
        }
    }
}