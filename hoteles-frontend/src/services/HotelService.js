import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

// Configuración de axios
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Interceptor para agregar token si existe
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar errores
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const hotelService = {
  // ========== HOTELES ==========
  
  /**
   * Obtener todos los hoteles
   */
  async getHoteles() {
    try {
      const response = await apiClient.get('/hotels');
      return response.data;
    } catch (error) {
      console.error('Error al obtener hoteles:', error);
      throw error;
    }
  },

  /**
   * Obtener un hotel por ID
   */
  async getHotel(id) {
    try {
      const response = await apiClient.get(`/hotels/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error al obtener hotel:', error);
      throw error;
    }
  },

  /**
   * Crear un nuevo hotel
   */
  async createHotel(hotelData) {
    try {
      const response = await apiClient.post('/hotels', hotelData);
      return response.data;
    } catch (error) {
      console.error('Error al crear hotel:', error);
      throw error;
    }
  },

  /**
   * Actualizar un hotel
   */
  async updateHotel(id, hotelData) {
    try {
      const response = await apiClient.put(`/hotels/${id}`, hotelData);
      return response.data;
    } catch (error) {
      console.error('Error al actualizar hotel:', error);
      throw error;
    }
  },

  /**
   * Eliminar un hotel
   */
  async deleteHotel(id) {
    try {
      await apiClient.delete(`/hotels/${id}`);
      return true;
    } catch (error) {
      console.error('Error al eliminar hotel:', error);
      throw error;
    }
  },

  // ========== HABITACIONES ==========
  
  /**
   * Obtener todas las habitaciones
   */
  async getHabitaciones() {
    try {
      const response = await apiClient.get('/habitaciones');
      return response.data;
    } catch (error) {
      console.error('Error al obtener habitaciones:', error);
      throw error;
    }
  },

  /**
   * Obtener habitaciones por hotel
   */
  async getHabitacionesByHotel(hotelId) {
    try {
      const response = await apiClient.get(`/hotels/${hotelId}/habitaciones`);
      return response.data;
    } catch (error) {
      console.error('Error al obtener habitaciones del hotel:', error);
      throw error;
    }
  },

  /**
   * Obtener una habitación por ID
   */
  async getHabitacion(id) {
    try {
      const response = await apiClient.get(`/habitaciones/${id}`);
      return response.data;
    } catch (error) {
      console.error('Error al obtener habitación:', error);
      throw error;
    }
  },

  /**
   * Crear una nueva habitación
   */
  async createHabitacion(habitacionData) {
    try {
      const response = await apiClient.post('/habitaciones', habitacionData);
      return response.data;
    } catch (error) {
      console.error('Error al crear habitación:', error);
      throw error;
    }
  },

  /**
   * Actualizar una habitación
   */
  async updateHabitacion(id, habitacionData) {
    try {
      const response = await apiClient.put(`/habitaciones/${id}`, habitacionData);
      return response.data;
    } catch (error) {
      console.error('Error al actualizar habitación:', error);
      throw error;
    }
  },

  /**
   * Eliminar una habitación
   */
  async deleteHabitacion(id) {
    try {
      await apiClient.delete(`/habitaciones/${id}`);
      return true;
    } catch (error) {
      console.error('Error al eliminar habitación:', error);
      throw error;
    }
  },

  // ========== VALIDACIONES ==========
  
  /**
   * Validar tipo de habitación y acomodación según reglas de negocio
   */
  validateHabitacion(tipo, acomodacion) {
    const validaciones = {
      'ESTANDAR': ['SENCILLA', 'DOBLE'],
      'JUNIOR': ['TRIPLE', 'CUADRUPLE'],
      'SUITE': ['SENCILLA', 'DOBLE', 'TRIPLE']
    };

    const tipoUpper = tipo?.toUpperCase();
    const acomodacionUpper = acomodacion?.toUpperCase();

    if (!validaciones[tipoUpper]) {
      return {
        valid: false,
        message: 'Tipo de habitación no válido'
      };
    }

    if (!validaciones[tipoUpper].includes(acomodacionUpper)) {
      return {
        valid: false,
        message: `Para habitación ${tipo}, las acomodaciones válidas son: ${validaciones[tipoUpper].join(', ')}`
      };
    }

    return { valid: true };
  },

  /**
   * Obtener tipos de habitación disponibles
   */
  getTiposHabitacion() {
    return ['ESTANDAR', 'JUNIOR', 'SUITE'];
  },

  /**
   * Obtener acomodaciones por tipo de habitación
   */
  getAcomodacionesByTipo(tipo) {
    const acomodaciones = {
      'ESTANDAR': ['SENCILLA', 'DOBLE'],
      'JUNIOR': ['TRIPLE', 'CUADRUPLE'],
      'SUITE': ['SENCILLA', 'DOBLE', 'TRIPLE']
    };
    
    return acomodaciones[tipo?.toUpperCase()] || [];
  },

  /**
   * Obtener todas las acomodaciones disponibles
   */
  getAcomodaciones() {
    return ['SENCILLA', 'DOBLE', 'TRIPLE', 'CUADRUPLE'];
  },

  // ========== ESTADÍSTICAS ==========
  
  /**
   * Obtener estadísticas de hoteles y habitaciones
   */
  async getEstadisticas() {
    try {
      const [hoteles, habitaciones] = await Promise.all([
        this.getHoteles(),
        this.getHabitaciones()
      ]);

      const totalHoteles = hoteles.data?.length || 0;
      const totalHabitaciones = habitaciones.data?.length || 0;

      // Contar habitaciones por tipo
      const habitacionesPorTipo = habitaciones.data?.reduce((acc, hab) => {
        acc[hab.tipo] = (acc[hab.tipo] || 0) + hab.cantidad;
        return acc;
      }, {}) || {};

      return {
        totalHoteles,
        totalHabitaciones,
        habitacionesPorTipo,
        hoteles: hoteles.data || [],
        habitaciones: habitaciones.data || []
      };
    } catch (error) {
      console.error('Error al obtener estadísticas:', error);
      throw error;
    }
  }
};

// Export default para compatibilidad
export default hotelService;