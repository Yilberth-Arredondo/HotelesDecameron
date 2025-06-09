import { EyeIcon, EyeSlashIcon } from '@heroicons/react/24/outline';
import { useState } from 'react';
import toast from 'react-hot-toast';
import Button from '../components/ui/Button';
import Input from '../components/ui/Input';
import { useAuth } from '../context/AuthContext';

const LoginPage = () => {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const { login } = useAuth();

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.username || !formData.password) {
      toast.error('Por favor complete todos los campos');
      return;
    }

    setIsLoading(true);

    try {
      const result = await login(formData.username, formData.password);

      if (result.success) {
        toast.success('¡Bienvenido al Dashboard!');
      } else {
        toast.error(result.error);
      }
    } catch (error) {
      toast.error('Error al iniciar sesión');
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div className='min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8'>
      <div className='max-w-md w-full space-y-8'>
        {/* Header */}
        <div className='text-center'>
          <div className='mx-auto h-16 w-16 bg-blue-600 rounded-full flex items-center justify-center'>
            <svg
              className='h-10 w-10 text-white'
              fill='none'
              viewBox='0 0 24 24'
              stroke='currentColor'>
              <path
                strokeLinecap='round'
                strokeLinejoin='round'
                strokeWidth={2}
                d='M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m11 0a2 2 0 01-2 2H5a2 2 0 01-2-2m0 0V9a2 2 0 012-2h2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10M7 10h10M7 13h10M7 16h10'
              />
            </svg>
          </div>
          <h2 className='mt-6 text-3xl font-extrabold text-gray-900'>
            Hoteles Decameron
          </h2>
          <p className='mt-2 text-sm text-gray-600'>
            Ingrese sus credenciales para acceder al dashboard
          </p>
        </div>

        {/* Formulario */}
        <div className='bg-white py-8 px-6 shadow-xl rounded-lg'>
          <form
            className='space-y-6'
            onSubmit={handleSubmit}>
            <div>
              <Input
                label='Usuario'
                type='text'
                name='username'
                value={formData.username}
                onChange={handleChange}
                placeholder='Ingrese su usuario'
                className='text-center'
                disabled={isLoading}
              />
            </div>

            <div className='relative'>
              <Input
                label='Contraseña'
                type={showPassword ? 'text' : 'password'}
                name='password'
                value={formData.password}
                onChange={handleChange}
                placeholder='Ingrese su contraseña'
                className='text-center pr-10'
                disabled={isLoading}
              />
              <button
                type='button'
                className='absolute inset-y-0 right-0 top-6 pr-3 flex items-center'
                onClick={() => setShowPassword(!showPassword)}>
                {showPassword ? (
                  <EyeSlashIcon className='h-5 w-5 text-gray-400' />
                ) : (
                  <EyeIcon className='h-5 w-5 text-gray-400' />
                )}
              </button>
            </div>

            <div>
              <Button
                type='submit'
                variant='primary'
                size='lg'
                loading={isLoading}
                disabled={isLoading}
                className='w-full'>
                {isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
              </Button>
            </div>
          </form>

          {/* Credenciales de prueba */}
          <div className='mt-6 p-4 bg-blue-50 rounded-lg'>
            <h4 className='text-sm font-medium text-blue-900 mb-2'>
              Credenciales de prueba:
            </h4>
            <div className='text-sm text-blue-700 space-y-1'>
              <p>
                <strong>Usuario:</strong> admin
              </p>
              <p>
                <strong>Contraseña:</strong> admin123
              </p>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className='text-center text-sm text-gray-500'>
          <p>Sistema de Gestión Hotelera</p>
          <p className='mt-1'>© 2025 Hoteles Decameron</p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
