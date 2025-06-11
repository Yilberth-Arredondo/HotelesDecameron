import {
  BuildingOfficeIcon,
  MagnifyingGlassIcon,
  MapPinIcon,
  PencilIcon,
  PlusIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';
import Modal from '../../components/ui/Modal';
import { hotelService } from '../../services/HotelService';

const HotelsList = () => {
  const navigate = useNavigate();
  const [hoteles, setHoteles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingHotel, setEditingHotel] = useState(null);
  const [formData, setFormData] = useState({
    nombre: '',
    direccion: '',
    ciudad: '',
    nit: '',
    numero_habitaciones: '',
  });

  useEffect(() => {
    loadHoteles();
  }, []);

  const loadHoteles = async () => {
    try {
      setLoading(true);
      const response = await hotelService.getHoteles();
      setHoteles(response.data || []);
    } catch (error) {
      toast.error('Error al cargar hoteles');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      if (editingHotel) {
        await hotelService.updateHotel(editingHotel.id, formData);
        toast.success('Hotel actualizado correctamente');
      } else {
        await hotelService.createHotel(formData);
        toast.success('Hotel creado correctamente');
      }

      setShowModal(false);
      resetForm();
      loadHoteles();
    } catch (error) {
      if (error.response?.data?.message) {
        toast.error(error.response.data.message);
      } else {
        toast.error('Error al guardar hotel');
      }
      console.error(error);
    }
  };

  const handleEdit = (hotel) => {
    setEditingHotel(hotel);
    setFormData({
      nombre: hotel.nombre,
      direccion: hotel.direccion,
      ciudad: hotel.ciudad,
      nit: hotel.nit,
      numero_habitaciones: hotel.numero_max_habitaciones,
    });
    setShowModal(true);
  };

  const handleDelete = async (hotelId) => {
    if (
      !confirm(
        '¿Está seguro de eliminar este hotel? Se eliminarán también todas sus habitaciones.'
      )
    ) {
      return;
    }

    try {
      await hotelService.deleteHotel(hotelId);
      toast.success('Hotel eliminado correctamente');
      loadHoteles();
    } catch (error) {
      toast.error('Error al eliminar hotel');
      console.error(error);
    }
  };

  const resetForm = () => {
    setFormData({
      nombre: '',
      direccion: '',
      ciudad: '',
      nit: '',
      numero_habitaciones: '',
    });
    setEditingHotel(null);
  };

  const filteredHoteles = hoteles.filter(
    (hotel) =>
      hotel.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
      hotel.ciudad.toLowerCase().includes(searchTerm.toLowerCase()) ||
      hotel.nit.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className='flex justify-center items-center h-64'>
        <div className='animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600'></div>
      </div>
    );
  }

  return (
    <div className='space-y-6'>
      {/* Header */}
      <div className='flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4'>
        <h1 className='text-3xl font-bold text-gray-900'>Hoteles</h1>
        <Button
          onClick={() => {
            resetForm();
            setShowModal(true);
          }}>
          <PlusIcon className='h-5 w-5 mr-2' />
          Nuevo Hotel
        </Button>
      </div>

      {/* Search */}
      <div className='bg-white p-4 rounded-lg shadow'>
        <div className='relative'>
          <MagnifyingGlassIcon className='absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400' />
          <input
            type='text'
            placeholder='Buscar por nombre, ciudad o NIT...'
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className='w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500'
          />
        </div>
      </div>

      {/* Hotels Grid */}
      {filteredHoteles.length === 0 ? (
        <div className='bg-white rounded-lg shadow p-8 text-center'>
          <BuildingOfficeIcon className='mx-auto h-12 w-12 text-gray-400' />
          <p className='mt-2 text-gray-500'>
            {searchTerm
              ? 'No se encontraron hoteles'
              : 'No hay hoteles registrados'}
          </p>
        </div>
      ) : (
        <div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6'>
          {filteredHoteles.map((hotel) => (
            <div
              key={hotel.id}
              className='bg-white rounded-lg shadow hover:shadow-lg transition-shadow cursor-pointer'
              onClick={() => navigate(`/hotels/${hotel.id}`)}>
              <div className='p-6'>
                <div className='flex justify-between items-start mb-4'>
                  <h3 className='text-lg font-semibold text-gray-900 flex-1'>
                    {hotel.nombre}
                  </h3>
                  <div className='flex space-x-2 ml-2'>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleEdit(hotel);
                      }}
                      className='text-gray-400 hover:text-blue-600 transition-colors'>
                      <PencilIcon className='h-5 w-5' />
                    </button>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleDelete(hotel.id);
                      }}
                      className='text-gray-400 hover:text-red-600 transition-colors'>
                      <TrashIcon className='h-5 w-5' />
                    </button>
                  </div>
                </div>

                <div className='space-y-2 text-sm'>
                  <div className='flex items-center text-gray-600'>
                    <MapPinIcon className='h-4 w-4 mr-2 flex-shrink-0' />
                    <span className='truncate'>{hotel.direccion}</span>
                  </div>
                  <div className='flex items-center text-gray-600'>
                    <BuildingOfficeIcon className='h-4 w-4 mr-2 flex-shrink-0' />
                    <span>{hotel.ciudad}</span>
                  </div>
                  <div className='flex justify-between items-center pt-2 border-t'>
                    <span className='text-gray-500'>NIT: {hotel.nit}</span>
                    <span className='text-blue-600 font-medium'>
                      {hotel.numero_max_habitaciones} hab.
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal para agregar/editar hotel */}
      <Modal
        isOpen={showModal}
        onClose={() => {
          setShowModal(false);
          resetForm();
        }}
        title={editingHotel ? 'Editar Hotel' : 'Nuevo Hotel'}>
        <form
          onSubmit={handleSubmit}
          className='space-y-4'>
          <Input
            label='Nombre del Hotel'
            value={formData.nombre}
            onChange={(e) =>
              setFormData({ ...formData, nombre: e.target.value })
            }
            required
            placeholder='Ej: DECAMERON CARTAGENA'
          />

          <Input
            label='Dirección'
            value={formData.direccion}
            onChange={(e) =>
              setFormData({ ...formData, direccion: e.target.value })
            }
            required
            placeholder='Ej: CALLE 23 58-25'
          />

          <Input
            label='Ciudad'
            value={formData.ciudad}
            onChange={(e) =>
              setFormData({ ...formData, ciudad: e.target.value })
            }
            required
            placeholder='Ej: CARTAGENA'
          />

          <Input
            label='NIT'
            value={formData.nit}
            onChange={(e) => setFormData({ ...formData, nit: e.target.value })}
            required
            placeholder='Ej: 12345678-9'
          />

          <Input
            label='Número de Habitaciones'
            type='number'
            min='1'
            value={formData.numero_max_habitaciones}
            onChange={(e) =>
              setFormData({ ...formData, numero_max_habitaciones: e.target.value })
            }
            required
            placeholder='Ej: 42'
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
              {editingHotel ? 'Actualizar' : 'Crear Hotel'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

export default HotelsList;
