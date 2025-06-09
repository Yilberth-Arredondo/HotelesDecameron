<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('habitacions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')->constrained('hotels')->onDelete('cascade');
            $table->enum('tipo_habitacion', ['ESTANDAR', 'JUNIOR', 'SUITE']);
            $table->enum('acomodacion', ['SENCILLA', 'DOBLE', 'TRIPLE', 'CUADRUPLE']);
            $table->integer('cantidad');
            $table->timestamps();

            // Constraint de unicidad para evitar duplicados
            $table->unique(['hotel_id', 'tipo_habitacion', 'acomodacion'], 'unique_habitacion_config');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('habitacions');
    }
};

