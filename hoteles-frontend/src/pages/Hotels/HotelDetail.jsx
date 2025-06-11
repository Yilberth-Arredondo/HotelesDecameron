import {
  ArrowLeftIcon,
  BuildingOfficeIcon,
  HomeIcon,
  IdentificationIcon,
  MapPinIcon,
  PencilIcon,
  PlusIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { useNavigate, useParams } from 'react-router-dom';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';
import Modal from '../../components/ui/Modal';
import { hotelService } from '../../services/HotelService';

const HotelDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [hotel, setHotel] = useState(null);
  const [habitaciones, setHabitaciones] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingHabitacion, setEditingHabitacion] = useState(null);
  const [showHotelModal, setShowHotelModal] = useState(false);
  const [hotelFormData, setHotelFormData] = useState({
    nombre: '',
    direccion: '',
    ciudad: '',
    nit: '',
    numero_max_habitaciones: '',
  });
  const [formData, setFormData] = useState({
    tipo: 'ESTANDAR',
    acomodacion: 'SENCILLA',
    cantidad: 1,
  });

  useEffect(() => {
    loadHotelData();
  }, [id]);

  const loadHotelData = async () => {
    try {
      setLoading(true);
      const [hotelResponse, habitacionesResponse] = await Promise.all([
        hotelService.getHotel(id),
        hotelService.getHabitacionesByHotel(id),
      ]);

      setHotel(hotelResponse.data);
      setHabitaciones(habitacionesResponse.data || []);
    } catch (error) {
      toast.error('Error al cargar datos del hotel');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleTipoChange = (tipo) => {
    console.log('Tipo seleccionado:', tipo);
    const acomodacionesValidas = hotelService.getAcomodacionesByTipo(tipo);
    setFormData({
      ...formData,
      tipo,
      acomodacion: acomodacionesValidas[0] || '',
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Validar según reglas de negocio
    const validacion = hotelService.validateHabitacion(
      formData.tipo,
      formData.acomodacion
    );
    if (!validacion.valid) {
      toast.error(validacion.message);
      return;
    }

    // NUEVA VALIDACIÓN: Verificar duplicados tipo+acomodación
    const existeCombinaciom = habitaciones.find(
      (hab) =>
        hab.tipo_habitacion === formData.tipo &&
        hab.acomodacion === formData.acomodacion &&
        (!editingHabitacion || hab.id !== editingHabitacion.id)
    );

    if (existeCombinaciom) {
      toast.error(
        `Ya existe una configuración de habitación ${formData.tipo} con acomodación ${formData.acomodacion} en este hotel`
      );
      return;
    }

    // Validar límite total de habitaciones
    const totalActual = habitaciones.reduce(
      (sum, hab) => sum + hab.cantidad,
      0
    );
    const nuevaCantidad = editingHabitacion
      ? totalActual - editingHabitacion.cantidad + parseInt(formData.cantidad)
      : totalActual + parseInt(formData.cantidad);

    if (nuevaCantidad > hotel.numero_max_habitaciones) {
      toast.error(
        `La cantidad total de habitaciones (${nuevaCantidad}) excede el máximo permitido para este hotel (${hotel.numero_max_habitaciones})`
      );
      return;
    }

    try {
      const dataToSend = {
        tipo_habitacion: formData.tipo,
        acomodacion: formData.acomodacion,
        cantidad: parseInt(formData.cantidad),
        hotel_id: parseInt(id),
      };

      if (editingHabitacion) {
        await hotelService.updateHabitacion(editingHabitacion.id, dataToSend);
        toast.success('Habitación actualizada correctamente');
      } else {
        await hotelService.createHabitacion(dataToSend);
        toast.success('Habitación creada correctamente');
      }

      setShowModal(false);
      resetForm();
      loadHotelData();
    } catch (error) {
      if (error.response?.data?.errors?.acomodacion) {
        toast.error(error.response.data.errors.acomodacion[0]);
      } else if (error.response?.data?.message) {
        toast.error(error.response.data.message);
      } else {
        toast.error('Error al guardar habitación');
      }
      console.error(error);
    }
  };

  const handleEdit = (habitacion) => {
    setEditingHabitacion(habitacion);
    setFormData({
      tipo: habitacion.tipo_habitacion,
      acomodacion: habitacion.acomodacion,
      cantidad: habitacion.cantidad,
    });
    setShowModal(true);
  };

  const handleDelete = async (habitacionId) => {
    if (!confirm('¿Está seguro de eliminar esta habitación?')) return;

    try {
      await hotelService.deleteHabitacion(habitacionId);
      toast.success('Habitación eliminada correctamente');
      loadHotelData();
    } catch (error) {
      toast.error('Error al eliminar habitación');
      console.error(error);
    }
  };

  const resetForm = () => {
    setFormData({
      tipo: 'ESTANDAR',
      acomodacion: 'SENCILLA',
      cantidad: 1,
    });
    setEditingHabitacion(null);
  };

  const getTotalHabitaciones = () => {
    return habitaciones.reduce((sum, hab) => sum + hab.cantidad, 0);
  };

  const handleEditHotel = async () => {
    setShowHotelModal(true);
    setHotelFormData({
      nombre: hotel.nombre,
      direccion: hotel.direccion,
      ciudad: hotel.ciudad,
      nit: hotel.nit,
      numero_max_habitaciones: hotel.numero_max_habitaciones,
    });
  };

  const handleSubmitHotel = async (e) => {
    e.preventDefault();

    try {
      await hotelService.updateHotel(id, hotelFormData);
      toast.success('Hotel actualizado correctamente');
      setShowHotelModal(false);
      loadHotelData();
    } catch (error) {
      toast.error('Error al actualizar hotel');
      console.error(error);
    }
  };

  if (loading) {
    return (
      <div className='flex justify-center items-center h-64'>
        <div className='animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600'></div>
      </div>
    );
  }

  if (!hotel) {
    return (
      <div className='text-center py-8'>
        <p className='text-gray-500'>Hotel no encontrado</p>
        <Button
          onClick={() => navigate('/hotels')}
          className='mt-4'>
          Volver a hoteles
        </Button>
      </div>
    );
  }

  return (
    <div className='space-y-6'>
      {/* Header */}
      <div className='bg-white shadow rounded-lg p-6'>
        <div className='flex justify-between items-start mb-6'>
          <div>
            <button
              onClick={() => navigate('/hotels')}
              className='flex items-center text-gray-600 hover:text-gray-900 mb-4'>
              <ArrowLeftIcon className='h-5 w-5 mr-1' />
              Volver a hoteles
            </button>
            <div className='flex items-center gap-4'>
              <h1 className='text-3xl font-bold text-gray-900'>
                {hotel.nombre}
              </h1>
              <Button
                variant='secondary'
                size='sm'
                onClick={handleEditHotel}>
                <PencilIcon className='h-4 w-4 mr-1' />
                Editar
              </Button>
            </div>
          </div>
          <div className='text-right'>
            <p className='text-sm text-gray-500'>Capacidad total</p>
            <p className='text-2xl font-bold text-blue-600'>
              {getTotalHabitaciones()} / {hotel.numero_max_habitaciones}
            </p>
            <p className='text-sm text-gray-500'>habitaciones</p>
          </div>
        </div>

        <div className='grid grid-cols-1 md:grid-cols-3 gap-4'>
          <div className='flex items-center space-x-3'>
            <MapPinIcon className='h-5 w-5 text-gray-400' />
            <div>
              <p className='text-sm text-gray-500'>Dirección</p>
              <p className='font-medium'>{hotel.direccion}</p>
            </div>
          </div>
          <div className='flex items-center space-x-3'>
            <BuildingOfficeIcon className='h-5 w-5 text-gray-400' />
            <div>
              <p className='text-sm text-gray-500'>Ciudad</p>
              <p className='font-medium'>{hotel.ciudad}</p>
            </div>
          </div>
          <div className='flex items-center space-x-3'>
            <IdentificationIcon className='h-5 w-5 text-gray-400' />
            <div>
              <p className='text-sm text-gray-500'>NIT</p>
              <p className='font-medium'>{hotel.nit}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Habitaciones */}
      <div className='bg-white shadow rounded-lg p-6'>
        <div className='flex justify-between items-center mb-6'>
          <h2 className='text-xl font-semibold text-gray-900'>Habitaciones</h2>
          <Button
            onClick={() => {
              resetForm();
              setShowModal(true);
            }}
            disabled={getTotalHabitaciones() >= hotel.numero_max_habitaciones}>
            <PlusIcon className='h-5 w-5 mr-2' />
            Agregar Habitación
          </Button>
        </div>

        {habitaciones.length === 0 ? (
          <div className='text-center py-8'>
            <HomeIcon className='mx-auto h-12 w-12 text-gray-400' />
            <p className='mt-2 text-gray-500'>
              No hay habitaciones registradas
            </p>
          </div>
        ) : (
          <div className='overflow-x-auto'>
            <table className='min-w-full divide-y divide-gray-200'>
              <thead className='bg-gray-50'>
                <tr>
                  <th className='px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider'>
                    Cantidad
                  </th>
                  <th className='px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider'>
                    Tipo de Habitación
                  </th>
                  <th className='px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider'>
                    Acomodación
                  </th>
                  <th className='px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider'>
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody className='bg-white divide-y divide-gray-200'>
                {habitaciones.map((habitacion) => (
                  <tr key={habitacion.id}>
                    <td className='px-6 py-4 whitespace-nowrap'>
                      <span className='text-lg font-semibold text-gray-900'>
                        {habitacion.cantidad}
                      </span>
                    </td>
                    <td className='px-6 py-4 whitespace-nowrap'>
                      <span className='px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800'>
                        {habitacion.tipo_habitacion}
                      </span>
                    </td>
                    <td className='px-6 py-4 whitespace-nowrap text-sm text-gray-900'>
                      {habitacion.acomodacion}
                    </td>
                    <td className='px-6 py-4 whitespace-nowrap text-right text-sm font-medium'>
                      <button
                        onClick={() => handleEdit(habitacion)}
                        className='text-indigo-600 hover:text-indigo-900 mr-4'>
                        <PencilIcon className='h-5 w-5' />
                      </button>
                      <button
                        onClick={() => handleDelete(habitacion.id)}
                        className='text-red-600 hover:text-red-900'>
                        <TrashIcon className='h-5 w-5' />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modal para agregar/editar habitación */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          resetForm();
        }}
        title={editingHabitacion ? 'Editar Habitación' : 'Agregar Habitación'}>
        <form
          onSubmit={handleSubmit}
          className='space-y-4'>
          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Tipo de Habitación
            </label>
            <select
              value={formData.tipo}
              onChange={(e) => handleTipoChange(e.target.value)}
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required>
              {hotelService.getTiposHabitacion().map((tipo) => (
                <option
                  key={tipo}
                  value={tipo}>
                  {tipo}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Acomodación
            </label>
            <select
              value={formData.acomodacion}
              onChange={(e) =>
                setFormData({ ...formData, acomodacion: e.target.value })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required>
              {hotelService
                .getAcomodacionesByTipo(formData.tipo)
                .map((acomodacion) => (
                  <option
                    key={acomodacion}
                    value={acomodacion}>
                    {acomodacion}
                  </option>
                ))}
            </select>
          </div>

          <Input
            label='Cantidad'
            type='number'
            min='1'
            value={formData.cantidad}
            onChange={(e) =>
              setFormData({
                ...formData,
                cantidad: parseInt(e.target.value) || 1,
              })
            }
            required
          />

          <div className='flex justify-end space-x-3 pt-4'>
            <Button
              type='button'
              variant='secondary'
              onClick={() => {
                setShowModal(false);
                resetForm();
              }}>
              Cancelar
            </Button>
            <Button type='submit'>
              {editingHabitacion ? 'Actualizar' : 'Agregar'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Modal para editar hotel */}
      <Modal
        isOpen={showHotelModal}
        onClose={() => setShowHotelModal(false)}
        title='Editar Hotel'>
        <form
          onSubmit={handleSubmitHotel}
          className='space-y-4'>
          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Nombre
            </label>
            <input
              type='text'
              value={hotelFormData.nombre}
              onChange={(e) =>
                setHotelFormData({ ...hotelFormData, nombre: e.target.value })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required
            />
          </div>

          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Dirección
            </label>
            <input
              type='text'
              value={hotelFormData.direccion}
              onChange={(e) =>
                setHotelFormData({
                  ...hotelFormData,
                  direccion: e.target.value,
                })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required
            />
          </div>

          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Ciudad
            </label>
            <input
              type='text'
              value={hotelFormData.ciudad}
              onChange={(e) =>
                setHotelFormData({ ...hotelFormData, ciudad: e.target.value })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required
            />
          </div>

          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              NIT
            </label>
            <input
              type='text'
              value={hotelFormData.nit}
              onChange={(e) =>
                setHotelFormData({ ...hotelFormData, nit: e.target.value })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required
            />
          </div>

          <div>
            <label className='block text-sm font-medium text-gray-700 mb-1'>
              Número máximo de habitaciones
            </label>
            <input
              type='number'
              value={hotelFormData.numero_max_habitaciones}
              onChange={(e) =>
                setHotelFormData({
                  ...hotelFormData,
                  numero_max_habitaciones: parseInt(e.target.value) || 0,
                })
              }
              className='w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500'
              required
            />
          </div>

          <div className='flex justify-end space-x-3 pt-4'>
            <Button
              type='button'
              variant='secondary'
              onClick={() => setShowHotelModal(false)}>
              Cancelar
            </Button>
            <Button type='submit'>Actualizar</Button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

export default HotelDetail;
