import {
  BuildingOfficeIcon,
  ChartBarIcon,
  HomeIcon,
} from '@heroicons/react/24/outline';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { Link } from 'react-router-dom';
import { hotelService } from '../services/HotelService';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalHoteles: 0,
    totalHabitaciones: 0,
    ocupacion: 0,
    loading: true,
  });

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const response = await hotelService.getHoteles();

      if (response.success && response.data) {
        const hoteles = response.data;
        const totalHoteles = hoteles.length;

        // Calcular habitaciones configuradas correctamente
        let totalHabitacionesConfiguradas = 0;
        let capacidadTotal = 0;

        for (const hotel of hoteles) {
          try {
            const habitacionesResponse =
              await hotelService.getHabitacionesByHotel(hotel.id);
            if (habitacionesResponse.success && habitacionesResponse.data) {
              // Sumar la cantidad de todas las habitaciones configuradas
              const habitacionesHotel = habitacionesResponse.data.reduce(
                (sum, habitacion) => sum + habitacion.cantidad,
                0
              );
              totalHabitacionesConfiguradas += habitacionesHotel;
            }
          } catch (error) {
            console.warn(
              `Error al cargar habitaciones del hotel ${hotel.id}:`,
              error
            );
          }

          // Sumar la capacidad máxima del hotel
          capacidadTotal += hotel.numero_max_habitaciones || 0;
        }

        const ocupacion =
          capacidadTotal > 0
            ? (totalHabitacionesConfiguradas / capacidadTotal) * 100
            : 0;

        setStats({
          totalHoteles,
          totalHabitaciones: totalHabitacionesConfiguradas,
          ocupacion: Math.round(ocupacion * 10) / 10, // Redondear a 1 decimal
          loading: false,
        });
      }
    } catch (error) {
      console.error('Error loading stats:', error);
      toast.error('Error al cargar estadísticas');
      setStats((prev) => ({ ...prev, loading: false }));
    }
  };

  const statCards = [
    {
      name: 'Total Hoteles',
      value: stats.totalHoteles,
      icon: BuildingOfficeIcon,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100',
    },
    {
      name: 'Habitaciones Configuradas',
      value: stats.totalHabitaciones,
      icon: HomeIcon,
      color: 'text-green-600',
      bgColor: 'bg-green-100',
    },
    {
      name: 'Ocupación Promedio',
      value: `${stats.ocupacion}%`,
      icon: ChartBarIcon,
      color: 'text-purple-600',
      bgColor: 'bg-purple-100',
    },
  ];

  return (
    <div className='space-y-6'>
      {/* Header */}
      <div>
        <h1 className='text-2xl font-bold text-gray-900'>Dashboard</h1>
        <p className='mt-1 text-sm text-gray-500'>
          Resumen del sistema de gestión hotelera
        </p>
      </div>

      {/* Stats Cards */}
      <div className='grid grid-cols-1 md:grid-cols-3 gap-6'>
        {statCards.map((stat) => (
          <div
            key={stat.name}
            className='card'>
            <div className='card-body'>
              <div className='flex items-center'>
                <div className={`p-3 rounded-lg ${stat.bgColor}`}>
                  <stat.icon className={`h-6 w-6 ${stat.color}`} />
                </div>
                <div className='ml-4'>
                  <p className='text-sm font-medium text-gray-500'>
                    {stat.name}
                  </p>
                  <p className='text-2xl font-semibold text-gray-900'>
                    {stats.loading ? '...' : stat.value}
                  </p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className='card'>
        <div className='card-header'>
          <h2 className='text-lg font-medium text-gray-900'>
            Acciones Rápidas
          </h2>
        </div>
        <div className='card-body'>
          <div className='grid grid-cols-1 sm:grid-cols-2 gap-4'>
            <Link
              to='/hotels'
              className='flex items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors duration-200'>
              <BuildingOfficeIcon className='h-8 w-8 text-blue-600' />
              <div className='ml-3'>
                <p className='text-sm font-medium text-gray-900'>
                  Gestionar Hoteles
                </p>
                <p className='text-sm text-gray-500'>
                  Ver, crear y editar hoteles
                </p>
              </div>
            </Link>

            <Link
              to='/hotels'
              className='flex items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors duration-200'>
              <HomeIcon className='h-8 w-8 text-green-600' />
              <div className='ml-3'>
                <p className='text-sm font-medium text-gray-900'>
                  Configurar Habitaciones
                </p>
                <p className='text-sm text-gray-500'>
                  Gestionar tipos y acomodaciones
                </p>
              </div>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
