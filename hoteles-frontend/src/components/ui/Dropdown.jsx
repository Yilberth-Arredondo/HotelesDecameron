import { Fragment } from 'react';
import { Menu, Transition } from '@headlessui/react';
import { ChevronDownIcon } from '@heroicons/react/20/solid';

const Dropdown = ({ trigger, children, align = 'right', className = '' }) => {
  const alignmentClasses = {
    left: 'left-0',
    right: 'right-0',
  };

  return (
    <Menu
      as='div'
      className={`relative inline-block text-left ${className}`}>
      <div>
        <Menu.Button className='inline-flex w-full justify-center items-center'>
          {trigger}
        </Menu.Button>
      </div>

      <Transition
        as={Fragment}
        enter='transition ease-out duration-100'
        enterFrom='transform opacity-0 scale-95'
        enterTo='transform opacity-100 scale-100'
        leave='transition ease-in duration-75'
        leaveFrom='transform opacity-100 scale-100'
        leaveTo='transform opacity-0 scale-95'>
        <Menu.Items
          className={`absolute z-10 mt-2 w-56 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none ${alignmentClasses[align]}`}>
          <div className='py-1'>{children}</div>
        </Menu.Items>
      </Transition>
    </Menu>
  );
};

const DropdownItem = ({ children, onClick, className = '' }) => {
  return (
    <Menu.Item>
      {({ active }) => (
        <button
          onClick={onClick}
          className={`${
            active ? 'bg-gray-100 text-gray-900' : 'text-gray-700'
          } group flex w-full items-center px-4 py-2 text-sm ${className}`}>
          {children}
        </button>
      )}
    </Menu.Item>
  );
};

Dropdown.Item = DropdownItem;

export default Dropdown;
