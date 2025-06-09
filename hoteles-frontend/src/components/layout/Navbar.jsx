import { Link, useLocation } from 'react-router-dom';
import { BuildingOfficeIcon, HomeIcon } from '@heroicons/react/24/outline';
import { useAuth } from '../../context/AuthContext';
import Dropdown from '../ui/Dropdown';
import Button from '../ui/Button';

const Navbar = () => {
  const location = useLocation();
  const { user, logout } = useAuth();

  const navigation = [
    { name: 'Dashboard', href: '/', icon: HomeIcon },
    { name: 'Hoteles', href: '/hotels', icon: BuildingOfficeIcon },
  ];

  const handleLogout = () => {
    logout();
  };

  return (
    <nav className='bg-white shadow-sm border-b border-gray-200'>
      <div className='max-w-7xl mx-auto px-4 sm:px-6 lg:px-8'>
        <div className='flex justify-between h-16'>
          <div className='flex items-center'>
            <Link
              to='/'
              className='flex items-center'>
              <BuildingOfficeIcon className='h-8 w-8 text-blue-600' />
              <span className='ml-2 text-xl font-bold text-gray-900'>
                Hoteles Decameron
              </span>
            </Link>
          </div>

          <div className='flex items-center space-x-4'>
            {/* Navigation Links */}
            {navigation.map((item) => {
              const isCurrent =
                location.pathname === item.href ||
                (item.href !== '/' && location.pathname.startsWith(item.href));

              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`inline-flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors duration-200 ${
                    isCurrent
                      ? 'bg-blue-100 text-blue-700'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                  }`}>
                  <item.icon className='h-5 w-5 mr-2' />
                  {item.name}
                </Link>
              );
            })}

            {/* User Menu */}
            <div className='flex items-center space-x-3'>
              <span className='text-sm text-gray-500'>
                Bienvenido,{' '}
                <span className='font-medium text-gray-900'>{user?.name}</span>
              </span>

              <Dropdown
                trigger={
                  <div className='flex items-center space-x-2 px-3 py-2 rounded-md hover:bg-gray-100 transition-colors duration-200 cursor-pointer'>
                    <div className='h-8 w-8 bg-blue-600 rounded-full flex items-center justify-center'>
                      <span className='text-white text-sm font-medium'>
                        {user?.name?.charAt(0)}
                      </span>
                    </div>
                    <svg
                      className='h-4 w-4 text-gray-400'
                      fill='none'
                      viewBox='0 0 24 24'
                      stroke='currentColor'>
                      <path
                        strokeLinecap='round'
                        strokeLinejoin='round'
                        strokeWidth={2}
                        d='M19 9l-7 7-7-7'
                      />
                    </svg>
                  </div>
                }
                align='right'>
                <Dropdown.Item onClick={handleLogout}>
                  <svg
                    className='mr-3 h-5 w-5 text-gray-400'
                    fill='none'
                    viewBox='0 0 24 24'
                    stroke='currentColor'>
                    <path
                      strokeLinecap='round'
                      strokeLinejoin='round'
                      strokeWidth={2}
                      d='M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1'
                    />
                  </svg>
                  Cerrar Sesión
                </Dropdown.Item>
              </Dropdown>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
