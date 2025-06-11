# 🏨 Hoteles Decameron - Plataforma de Gestión Hotelera

Sistema de gestión hotelera desarrollado con arquitectura desacoplada, permitiendo la administración de hoteles y configuración de habitaciones con validaciones de negocio robustas.

## 🚀 Tecnologías

### Backend

- **Framework**: Laravel (PHP 8.1+)
- **Base de Datos**: PostgreSQL
- **Arquitectura**: API REST
- **Validaciones**: Reglas de negocio integradas

### Frontend

- **Framework**: React 18+ con Vite
- **Estilos**: Tailwind CSS + HeadlessUI
- **Arquitectura**: SCREAMING (componentes organizados por funcionalidad)
- **Estado**: Context API + Services

## 📋 Requisitos del Sistema

- **PHP**: 8.1 o superior
- **Composer**: 2.0+
- **Node.js**: 16+ y npm
- **PostgreSQL**: 12+
- **Sistema**: Linux/WSL compatible

## ⚡ Instalación Rápida

### 👀 Consideraciones iniciales
- El despliegue local está pensado para trabajar correctamente con bash de unix SO Ubuntu22.04, los comandos para la CLI de windows pueden ser diferentes
- Si tiene un Sistema windows se recomienda el uso de wsl para el correcto despliegue del proyecto
- Se recomienda el uso del siguiente comando para iniciar el servicio correctamente sudo apt install -y php8.4-xml php8.4-curl php8.4-mbstring php8.4-zip php8.4-gd php8.4-bcmath php8.4-intl


### Instalación Automática (Recomendada)

```bash
# Clonar el repositorio
git clone git@github.com:Yilberth-Arredondo/HotelesDecameron.git
cd HotelesDecameron

# Ejecutar instalación automática
chmod +x run.sh
./run.sh
```

El script `run.sh` ejecutará automáticamente:

- Configuración de la base de datos PostgreSQL
- Instalación y configuración del backend (Laravel)
- Instalación y configuración del frontend (React)
- Carga de datos iniciales
- Inicio de ambos servidores

### URLs de Acceso

Una vez completada la instalación:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api
- **Health Check**: http://localhost:8080/api/health

## 🏗️ Estructura del Proyecto

### Back-end

```
hoteles-decameron/
├── hoteles-backend/          # API Laravel
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/  # HotelController, HabitacionController
│   │   │   ├── Requests/     # Validaciones de entrada
│   │   │   └── Resources/    # Transformadores de respuesta
│   │   ├── Models/           # Hotel, Habitacion, User
│   │   └── Providers/        # Configuración de servicios
│   ├── database/
│   │   ├── migrations/       # Estructura de BD
│   │   ├── seeders/          # Datos iniciales
│   │   └── hoteles_decameron_install.sql
│   ├── routes/
│   │   ├── api.php          # Rutas de la API
│   │   └── web.php          # Rutas web
│   ├── config/              # Configuración (CORS, DB, etc.)
│   ├── public/              # Punto de entrada (health.php)
│   └── run-backend.sh       # Script de instalación backend
├── hoteles-frontend/        # Aplicación React
│   ├── src/
│   │   ├── components/      # Componentes UI organizados por tipo
│   │   │   ├── auth/        # ProtectedRoute
│   │   │   ├── layout/      # Layout, Navbar
│   │   │   └── ui/          # Button, Modal, Input, Dropdown
│   │   ├── pages/           # Dashboard, Hotels/, LoginPage
│   │   ├── services/        # HotelService, api.js
│   │   └── context/         # AuthContext
│   ├── public/              # Archivos estáticos
│   └── run-frontend.sh      # Script de instalación frontend
├── database/
│   └── hoteles_decameron_install.sql  # Dump completo con datos
└── run.sh                   # Script principal de instalación
```

### Front-end

```
├── README.md
├── eslint.config.js
├── index.html
├── package-lock.json
├── package.json
├── postcss.config.js
├── procfile
├── public
│   └── vite.svg
├── railway.json
├── src
│   ├── App.css
│   ├── App.jsx
│   ├── assets
│   │   └── react.svg
│   ├── components
│   │   ├── auth
│   │   │   └── ProtectedRoute.jsx
│   │   ├── layout
│   │   │   ├── Layout.jsx
│   │   │   └── Navbar.jsx
│   │   └── ui
│   │       ├── Button.jsx
│   │       ├── Dropdown.jsx
│   │       ├── Input.jsx
│   │       └── Modal.jsx
│   ├── context
│   │   └── AuthContext.jsx
│   ├── index.css
│   ├── main.jsx
│   ├── pages
│   │   ├── Dashboard.jsx
│   │   ├── Hotels
│   │   │   ├── HotelDetail.jsx
│   │   │   └── HotelsList.jsx
│   │   └── LoginPage.jsx
│   └── services
│       ├── HotelService.js
│       └── api.js
├── tailwind.config.js
└── vite.config.js
```

## 🔧 Instalación Manual

Si prefieres instalar manualmente cada componente:

### 1. Base de Datos

```bash
# Iniciar PostgreSQL
sudo service postgresql start

# Crear base de datos
sudo -u postgres createdb hoteles_decameron

# Cargar datos iniciales (ubicado en hoteles-backend)
sudo -u postgres psql -d hoteles_decameron < hoteles-backend/database/hoteles_decameron_install.sql
```

### 2. Backend (Laravel)

```bash
cd hoteles-backend

# Instalar dependencias
composer install

# Configurar entorno
cp .env.example .env
php artisan key:generate

# Configurar base de datos en .env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=hoteles_decameron
DB_USERNAME=postgres
DB_PASSWORD=password

# Ejecutar migraciones
php artisan migrate

# Iniciar servidor
php artisan serve --port=8080
```

### 3. Frontend (React)

```bash
cd ../hoteles-frontend

# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm run dev
```

## 🏨 Funcionalidades Principales

### Gestión de Hoteles

- Registro y edición de hoteles
- Validación de hoteles únicos por NIT y por nombre
- Control de capacidad máxima de habitaciones

### Gestión de Habitaciones

- Tipos: ESTÁNDAR, JUNIOR, SUITE
- Acomodaciones: SENCILLA, DOBLE, TRIPLE, CUÁDRUPLE
- Validación de configuraciones únicas por hotel
- Control de límites por hotel

### Arquitectura Backend

- **Controladores**: `HotelController`, `HabitacionController` con operaciones CRUD
- **Modelos**: `Hotel`, `Habitacion` con relaciones y validaciones
- **Requests**: Validaciones específicas para Store/Update operations
- **Resources**: Transformadores de datos para respuestas JSON consistentes
- **Migraciones**: Estructura de BD con constraints y índices optimizados
- **Seeders**: Datos iniciales para testing y desarrollo

### Reglas de Negocio

- **Capacidad**: Las habitaciones configuradas no pueden superar el máximo del hotel
- **Unicidad de Hoteles**: No se permiten hoteles duplicados (validación por NIT y por nombre)
- **Configuraciones Únicas**: No se permiten combinaciones repetidas de tipo-acomodación por hotel

## 🧪 Testing

### Verificar Backend

```bash
# Health check
curl http://localhost:8080/api/health

# Listar hoteles
curl http://localhost:8080/api/hotels

# Obtener hotel específico
curl http://localhost:8080/api/hotels/1

# Obtener habitaciones de un hotel
curl http://localhost:8080/api/hotels/1/habitaciones

# Crear nuevo hotel (POST)
curl -X POST http://localhost:8080/api/hotels \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Hotel Test",
    "direccion": "Calle Test 123",
    "ciudad": "Ciudad Test",
    "nit": "123456789-0",
    "numero_max_habitaciones": 30
  }'

# Crear configuración de habitaciones (POST)
curl -X POST http://localhost:8080/api/hotels/1/habitaciones \
  -H "Content-Type: application/json" \
  -d '{
    "tipo_habitacion": "ESTANDAR",
    "acomodacion": "DOBLE",
    "cantidad": 10
  }'
```

### Endpoints Disponibles

#### Hoteles

- `GET /api/hotels` - Listar todos los hoteles
- `POST /api/hotels` - Crear nuevo hotel
- `GET /api/hotels/{id}` - Obtener hotel específico
- `PUT /api/hotels/{id}` - Actualizar hotel
- `DELETE /api/hotels/{id}` - Eliminar hotel

#### Habitaciones

- `GET /api/hotels/{hotel_id}/rooms` - Listar habitaciones de un hotel
- `POST /api/hotels/{hotel_id}/rooms` - Crear configuración de habitaciones
- `PUT /api/rooms/{id}` - Actualizar configuración
- `DELETE /api/rooms/{id}` - Eliminar configuración

#### Sistema

- `GET /api/health` - Health check de la aplicación
- `GET /api/` - Información general de la API con endpoints disponibles

### Verificar Frontend

- Navegar a http://localhost:3000
- Verificar carga de hoteles
- Probar navegación entre secciones

## 🗄️ Modelo de Base de Datos

El sistema utiliza PostgreSQL con las siguientes entidades principales:

### Entidades Core del Negocio

#### Hotels (hoteles)

- **id**: Identificador único (BigInt, PK, Auto-increment)
- **nombre**: Nombre del hotel (VARCHAR(255), UNIQUE, NOT NULL, INDEXED)
- **direccion**: Dirección física (VARCHAR(255), NOT NULL)
- **ciudad**: Ciudad donde se ubica (VARCHAR(255), NOT NULL, INDEXED)
- **nit**: Número de identificación tributaria (VARCHAR(255), UNIQUE, NOT NULL)
- **numero_max_habitaciones**: Capacidad máxima de habitaciones (INTEGER, NOT NULL)
- **created_at / updated_at**: Timestamps de auditoría

#### Rooms (habitaciones)

- **id**: Identificador único (BigInt, PK, Auto-increment)
- **hotel_id**: Referencia al hotel (BigInt, FK, NOT NULL)
- **tipo_habitacion**: Tipo de habitación (VARCHAR, CHECK: ESTANDAR|JUNIOR|SUITE)
- **acomodacion**: Tipo de acomodación (VARCHAR, CHECK: SENCILLA|DOBLE|TRIPLE|CUADRUPLE)
- **cantidad**: Número de habitaciones de este tipo (INTEGER, NOT NULL, CHECK > 0)
- **created_at / updated_at**: Timestamps de auditoría

### Constraints y Validaciones

#### Integridad Referencial

- `rooms.hotel_id` → `hotels.id` (CASCADE DELETE)

#### Constraints de Unicidad

- `hotels.nombre` - No puede haber hoteles con el mismo nombre
- `hotels.nit` - NIT único por hotel
- `rooms(hotel_id, tipo_habitacion, acomodacion)` - Combinación única por hotel

#### Validaciones de Negocio

- **Tipos de habitación**: Solo ESTANDAR, JUNIOR, SUITE
- **Acomodaciones**: Solo SENCILLA, DOBLE, TRIPLE, CUADRUPLE
- **Cantidad**: Debe ser mayor a 0
- **Capacidad total**: La suma de habitaciones no puede exceder `numero_max_habitaciones`

### Índices para Performance

- `hotels.nombre` - Búsquedas por nombre
- `hotels.ciudad` - Filtros por ubicación
- `rooms.hotel_id` - Consultas de habitaciones por hotel

## 🔍 Datos de Prueba

El sistema incluye datos iniciales de 5 hoteles Decameron:

1. **Decameron Cartagena** - 42 habitaciones máximo
2. **Decameron San Andrés** - 60 habitaciones máximo
3. **Decameron Marazul** - 35 habitaciones máximo
4. **Decameron Barú** - 28 habitaciones máximo
5. **Decameron Los Cocos** - 50 habitaciones máximo

## 🛠️ Desarrollo

### Comandos Útiles

```bash
# Backend - Limpiar caché
cd hoteles-backend
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Frontend - Build para producción
cd hoteles-frontend
npm run build

# Reiniciar base de datos
sudo -u postgres psql -c "DROP DATABASE IF EXISTS hoteles_decameron;"
./run.sh
```

### Arquitectura Frontend (SCREAMING)

```
src/
├── components/
│   ├── auth/           # Componentes de autenticación
│   ├── layout/         # Layout y navegación
│   └── ui/             # Componentes UI reutilizables
├── pages/              # Páginas organizadas por funcionalidad
│   └── Hotels/         # Gestión de hoteles
├── services/           # Comunicación con API
└── context/            # Estado global de la aplicación
```

## 📝 Notas de Desarrollo

- **Backend**: Utiliza validaciones a nivel de modelo y request
- **Frontend**: Considera implementar custom hooks para gestión de estado en proyectos más grandes
- **Base de Datos**: Incluye constraints y triggers para integridad de datos
- **CORS**: Configurado para desarrollo local (localhost:3000)

## 🚀 Despliegue

Para despliegue en producción, revisar configuraciones de:

- Variables de entorno (.env)
- Configuración de CORS
- Configuración de base de datos
- Build de producción del frontend

## 📞 Soporte

Para problemas durante la instalación:

1. Verificar que PostgreSQL esté corriendo
2. Confirmar versiones de PHP y Node.js
3. Revisar permisos de archivos .sh
4. Consultar logs en `hoteles-backend/storage/logs/`
