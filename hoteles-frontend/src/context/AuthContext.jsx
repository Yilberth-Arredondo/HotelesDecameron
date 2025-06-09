import { createContext, useContext, useEffect, useState } from 'react';

const AuthContext = createContext();

// Hook para usar el contexto
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth debe ser usado dentro de AuthProvider');
  }
  return context;
};

// Credenciales por defecto (en producción esto vendría del backend)
const DEFAULT_CREDENTIALS = {
  username: 'admin',
  password: 'admin123',
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Verificar si hay sesión guardada al cargar
  useEffect(() => {
    const savedUser = localStorage.getItem('hotel_admin_user');
    if (savedUser) {
      try {
        setUser(JSON.parse(savedUser));
      } catch (error) {
        localStorage.removeItem('hotel_admin_user');
      }
    }
    setLoading(false);
  }, []);

  const login = async (username, password) => {
    // Simular delay de red
    await new Promise((resolve) => setTimeout(resolve, 1000));

    if (
      username === DEFAULT_CREDENTIALS.username &&
      password === DEFAULT_CREDENTIALS.password
    ) {
      const userData = {
        id: 1,
        username: 'admin',
        name: 'Administrador',
        role: 'admin',
        loginTime: new Date().toISOString(),
      };

      setUser(userData);
      localStorage.setItem('hotel_admin_user', JSON.stringify(userData));
      return { success: true };
    } else {
      return {
        success: false,
        error: 'Credenciales incorrectas. Use admin/admin123',
      };
    }
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('hotel_admin_user');
  };

  const value = {
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
