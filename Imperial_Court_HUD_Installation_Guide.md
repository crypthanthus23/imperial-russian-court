# Guía de Instalación del Sistema Imperial Russian Court HUD

Esta guía te ayudará a instalar y configurar correctamente el sistema completo de HUD de la Corte Imperial Rusa. Este sistema consta de tres componentes principales que trabajan juntos.

## Componentes del Sistema

1. **API Connector**: Se comunica con la base de datos y el servidor.
2. **Core HUD**: Coordina todas las funciones y módulos.
3. **Stats Meter**: Muestra las estadísticas del jugador como texto flotante.

## Requisitos Previos

- Un servidor de Replit con Flask y PostgreSQL.
- Acceso a Second Life y permisos para cargar scripts.

## Pasos de Instalación

### 1. Configuración del Servidor (Replit)

1. Asegúrate de que el servidor Flask esté ejecutándose en Replit.
2. Anota la URL de tu servidor Replit (ej: `https://imperial-russian-court-rp.usuario.repl.co`).

### 2. Configuración del API Connector

1. Abre el script `Imperial_Court_HUD_API_Connector.lsl`.
2. Busca la línea que contiene la URL del API y actualízala con tu URL de Replit:
   ```lsl
   string API_URL = "https://imperial-russian-court-rp.usuario.repl.co"; // URL de la API en Replit
   ```
3. Carga este script en un prim invisible dentro del HUD principal.

### 3. Configuración del Core HUD

1. Carga el script `Imperial_Russian_Court_Core_HUD.lsl` en el prim principal del HUD.
2. Asegúrate de que comparta el mismo valor para la constante `AUTH_KEY` que el API Connector.
3. Configura los canales de comunicación para que coincidan con los otros componentes.

### 4. Configuración del Stats Meter

1. Crea un nuevo objeto para el medidor de estadísticas.
2. Carga el script `Imperial_Court_HUD_Stats_Meter.lsl` en este objeto.
3. Asegúrate de que el canal de comunicación coincida con el definido en el API Connector.

## Flujo de Comunicación

La comunicación entre los componentes sigue este patrón:

```
Servidor de Base de Datos (Replit) <---> API Connector <---> Core HUD <---> Stats Meter
```

1. El API Connector se comunica con el servidor utilizando solicitudes HTTP.
2. El Core HUD y el API Connector se comunican usando mensajes de region en el canal `-76543210`.
3. El Stats Meter y el API Connector se comunican usando mensajes de region en el canal `-987654321`.

## Verificación de la Instalación

1. Adjunta el HUD a tu avatar.
2. Si todo está configurado correctamente, verás mensajes de inicialización.
3. El API Connector buscará tu perfil en la base de datos.
4. Si no tienes un perfil, el HUD te ofrecerá crear uno.
5. El Stats Meter debería conectarse automáticamente y mostrar tus estadísticas.

## Solución de Problemas

- **El HUD no se conecta al servidor**: Verifica que la URL de la API sea correcta y que el servidor esté en funcionamiento.
- **El Core HUD no recibe datos**: Asegúrate de que los canales de comunicación y la clave de autenticación sean idénticos en todos los scripts.
- **El Stats Meter no muestra información**: Verifica que esté escuchando en el canal correcto y que la conexión con el API Connector funcione.

## Actualizaciones y Mantenimiento

Para mantener el sistema funcionando correctamente:

1. Realiza copias de seguridad de la base de datos periódicamente.
2. Asegúrate de que el servidor Replit esté siempre activo.
3. Actualiza la URL de la API si cambia tu servidor Replit.

---

© 2025 Imperial Russian Court RP System - Desarrollado para Second Life