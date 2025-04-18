# Arquitectura del Sistema Imperial Russian Court RP

Este documento detalla la arquitectura técnica del sistema de roleplay de la Corte Imperial Rusa para Second Life.

## Visión General

El sistema de Imperial Russian Court RP está diseñado para superar las limitaciones de almacenamiento y procesamiento de LSL (Linden Scripting Language) mediante el uso de un backend centralizado. La arquitectura se compone de tres capas principales:

1. **Capa de Servidor**: Una base de datos PostgreSQL con API en Flask alojada en Replit.
2. **Capa de Conectividad**: Scripts LSL que conectan Second Life con el servidor.
3. **Capa de Interfaz de Usuario**: HUDs y objetos visibles para los usuarios en Second Life.

## Componentes Principales

### 1. Servidor Backend (Replit)

- **Base de Datos PostgreSQL**: Almacena todos los datos de personajes, familias, y estadísticas.
- **API Flask**: Proporciona endpoints para operaciones CRUD sobre los datos.
- **Histórico de Datos**: Contiene información histórica precisa sobre la Rusia de 1905.

#### Endpoints Principales de la API:

- `/api/player/{id}`: Operaciones GET, POST, PUT para datos de jugadores
- `/api/player/damage/{id}`: POST para aplicar daño a un jugador
- `/api/player/heal/{id}`: POST para curar a un jugador
- `/api/player/revive/{id}`: POST para revivir a un jugador
- `/api/families`: GET para obtener información sobre familias nobles
- `/api/professions`: GET para obtener profesiones disponibles
- `/api/social-classes`: GET para obtener clases sociales

### 2. Conector API (LSL)

El script `Imperial_Court_HUD_API_Connector.lsl` sirve como puente entre Second Life y el servidor:

- Realiza solicitudes HTTP al backend
- Procesa respuestas JSON y extrae datos relevantes
- Comunica datos a otros componentes del sistema mediante mensajes de región
- Maneja la autenticación y seguridad
- Implementa manejo de errores y reconexiones

### 3. HUD Principal (LSL)

El script `Imperial_Russian_Court_Core_HUD.lsl` es el componente central en Second Life:

- Coordina todos los subsistemas y módulos
- Proporciona la interfaz de usuario para creación y gestión de personajes
- Establece comunicación bidireccional con el API Connector
- Gestiona acciones de roleplay como daño, curación, y eventos sociales
- Coordina la actualización del medidor de estadísticas

### 4. Medidor de Estadísticas (LSL)

El script `Imperial_Court_HUD_Stats_Meter.lsl` crea una visualización flotante:

- Muestra datos del personaje visible para otros jugadores
- Se actualiza periódicamente con datos del servidor
- Representa visualmente estadísticas, rangos y atributos
- Proporciona indicación visual del estado de conexión al sistema

## Flujo de Datos

El sistema sigue este flujo de comunicación:

1. **Cliente -> Servidor**:
   - Solicitudes HTTP desde el API Connector al backend
   - Formato de datos: JSON estructurado
   - Método de autenticación: UUID del jugador como identificador único

2. **Servidor -> Cliente**:
   - Respuestas JSON con datos solicitados
   - Confirmaciones de actualizaciones realizadas
   - Mensajes de error en caso de fallos

3. **Entre Componentes LSL**:
   - Comunicación mediante mensajes de región en canales específicos
   - Canal HUD-API: -76543210
   - Canal Stats-Meter: -987654321
   - Formato de mensajes: COMANDO:AUTH_KEY:DATOS

## Modelo de Datos

### Jugador (Player)
Almacena información de personajes con campos como:
- ID (UUID de Second Life)
- Nombre y apellido de RP
- Clase social y profesión
- Facción política
- Estadísticas (salud, encanto, influencia, etc.)
- Estado vital (vivo, en coma, muerto)

### Familia (Family)
Representa familias nobles históricas:
- Nombre de familia
- Descripción e historia
- Influencia y riqueza
- Estado actual

## Consideraciones Técnicas

### Limitaciones de LSL
- Memoria limitada: 64KB por script
- CPU limitada: scripts pueden ser suspendidos si consumen demasiados recursos
- No dispone de almacenamiento persistente adecuado
- No soporta operadores ternarios, void ni break

### Estrategias de Optimización
- División de funcionalidad en múltiples scripts
- Uso de servidor externo para lógica compleja y almacenamiento
- Comunicación asíncrona para evitar bloqueos
- Cache local en LSL para reducir peticiones al servidor

## Seguridad

- Autenticación mediante clave compartida entre componentes
- Verificación de origen de mensajes mediante UUID
- Sin almacenamiento de datos personales reales, solo datos de personajes ficticios
- Comunicación segura mediante HTTPS para solicitudes al servidor

## Mantenimiento y Expansión

El sistema está diseñado para ser modular, permitiendo:
- Adición de nuevos módulos (como módulos de matrimonio, política, o combate)
- Expansión de la base de datos sin modificar scripts existentes
- Actualización del servidor sin afectar a los clientes ya desplegados
- Ajustes balanceados de los parámetros del juego

---

© 2025 Imperial Russian Court RP System - Desarrollado para Second Life