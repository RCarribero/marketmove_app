# MarketMove App

**Aplicacion de gestion empresarial para pequenos comercios**

Proyecto de fin de curso - Desarrollo de Aplicaciones Multiplataforma (DAM)

## Descripcion

Aplicacion multiplataforma desarrollada con Flutter que permite a pequenos comercios gestionar su negocio de forma integral:

- Registro y seguimiento de ventas diarias
- Control de gastos por categorias
- Gestion de inventario y productos
- Dashboard con metricas y KPIs en tiempo real
- Reportes avanzados con graficos interactivos
- Asistente IA integrado (Google Gemini)
- Sistema de suscripciones con Stripe
- Panel de administracion para gestionar usuarios

## Tecnologias Utilizadas

| Categoria | Tecnologia |
|-----------|------------|
| Frontend | Flutter 3.x / Dart |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| Pagos | Stripe Checkout |
| IA | Google Gemini API |
| Estado | Provider |
| Navegacion | GoRouter |
| Graficos | FL Chart |
| Reportes | Excel (dart package) |

## Arquitectura del Proyecto

El proyecto sigue una arquitectura modular basada en features, facilitando el mantenimiento y la escalabilidad:

```
lib/
  src/
    core/               # Configuracion global (Supabase, Gemini, etc.)
    features/           # Modulos funcionales de la app
      auth/             # Autenticacion (login, registro)
      ventas/           # Gestion de ventas
      gastos/           # Gestion de gastos
      productos/        # Inventario de productos
      resumen/          # Dashboard con resumen
      reports/          # Reportes basicos y avanzados
      pricing/          # Planes, suscripciones y pagos
      chat/             # Asistente IA con Gemini
      admin/            # Panel de administracion
      home/             # Paginas principales (dashboard)
      profile/          # Perfil de usuario
      splash/           # Pantalla de carga inicial
    shared/             # Codigo compartido entre features
      models/           # Modelos de datos (Product, Sale, Expense, etc.)
      providers/        # State management con Provider
      services/         # Servicios (API calls, reports, analytics)
      widgets/          # Widgets reutilizables
      theme/            # Estilos, colores y animaciones
```

## Funcionalidades Principales

### Dashboard Interactivo
- Metricas de ventas del dia y mes actual
- Comparativas porcentuales con periodos anteriores
- Graficos de barras (ventas semanales)
- Graficos de lineas (tendencia mensual)
- Graficos circulares (gastos por categoria)
- Feed de actividad reciente

### Gestion de Ventas
- Registro de ventas con multiples items
- Asociacion de cliente a cada venta
- Historial completo con busqueda
- Calculo automatico de totales

### Control de Gastos
- Categorias predefinidas (Alquiler, Servicios, Inventario, Marketing, etc.)
- Seguimiento mensual y comparativas
- Analisis visual por tipo de gasto

### Inventario de Productos
- Catalogo completo con precios y stock
- Alertas visuales de stock bajo
- Busqueda y ordenamiento
- Edicion y eliminacion rapida

### Reportes y Exportacion
- Reportes basicos por tipo (ventas, gastos, productos)
- Reportes avanzados combinados
- Exportacion a formato Excel (.xlsx)
- Graficos embebidos en reportes

### Asistente IA (Gemini)
- Chat conversacional integrado
- Contexto de negocio incluido en las respuestas
- Historial de conversaciones persistente

### Sistema de Suscripciones
- Periodo de prueba de 30 dias
- Planes Pro mensuales y anuales
- Integracion completa con Stripe Checkout
- Validacion de suscripcion activa

### Sistema de Roles y Permisos
- **Usuario normal**: Acceso solo a sus propios datos
- **Administrador**: Acceso a datos de todos los usuarios
- Row Level Security (RLS) en base de datos

## Requisitos del Sistema

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Cuenta en Supabase (backend)
- Cuenta en Stripe (pagos - opcional)
- API Key de Google Gemini (IA - opcional)
- Git

## Instalacion y Configuracion

1. **Clonar el repositorio:**
```bash
git clone https://github.com/RCarribero/marketmove_app.git
cd marketmove_app
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Configurar credenciales** en `lib/src/core/config/`:
   - `supabase_config.dart`: URL y anon key de Supabase
   - `gemini_config.dart`: API Key de Gemini
   - Configurar Stripe en el dashboard de Supabase

4. **Configurar base de datos:**
   - Ejecutar scripts SQL para crear tablas
   - Configurar Row Level Security (RLS)
   - Crear trigger para perfiles automaticos

5. **Ejecutar la aplicacion:**
```bash
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Esquema de Base de Datos

### Tablas Principales

| Tabla | Descripcion |
|-------|-------------|
| `profiles` | Perfiles de usuario (id, email, role) |
| `productos` | Catalogo de productos (name, price, stock) |
| `ventas` | Registro de ventas (total, items, customer) |
| `gastos` | Registro de gastos (amount, category, description) |
| `subscriptions` | Suscripciones (plan, status, trial dates) |
| `chat_messages` | Historial del asistente IA |

### Seguridad (RLS)

Todas las tablas implementan Row Level Security:
- Usuarios normales: `auth.uid() = user_id`
- Administradores: `is_admin()` function permite acceso total

## Estructura de Commits

El proyecto sigue conventional commits:
- `feat:` Nueva funcionalidad
- `fix:` Correccion de bugs
- `docs:` Documentacion
- `style:` Estilos y formato
- `refactor:` Refactorizacion de codigo

## Autor

**Ruben Carribero Garcia**
- Ciclo: Desarrollo de Aplicaciones Multiplataforma (DAM)
- Curso: 2024-2025
- Rol: Desarrollador FullStack

## Licencia

Este proyecto es de uso academico y educativo.
Desarrollado como proyecto de fin de curso.