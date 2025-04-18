# Guía de Instalación del Imperial Court Stats Meter

Este documento explica cómo instalar y configurar correctamente el medidor de estadísticas ("Stats Meter") para el sistema de roleplay de la Corte Imperial Rusa.

## ¿Qué es el Stats Meter?

El Stats Meter es un objeto que muestra tus estadísticas de personaje como texto flotante visible para otros jugadores. Esto permite que otros participantes del roleplay vean información relevante sobre tu personaje, como su rango, salud, y diversos atributos.

## Requisitos Previos

- Tener instalado y configurado el HUD principal de la Corte Imperial
- Tener acceso al script `Imperial_Court_HUD_Stats_Meter.lsl`

## Pasos para la Instalación

### 1. Crear el Objeto del Meter

1. En Second Life, crea un nuevo objeto (prim) simple.
   - Se recomienda usar una esfera o cilindro pequeño.
   - Establecer el tamaño a aproximadamente 0.1 x 0.1 x 0.1 metros.

2. Opcional: Haz que el objeto sea parcialmente transparente.
   - Esto permitirá que se vea el texto pero el objeto no será tan notorio.
   - Sugerimos un alfa (transparencia) de al menos 50%.

### 2. Cargar el Script

1. Abre el inventario del objeto recién creado.
2. Arrastra el script `Imperial_Court_HUD_Stats_Meter.lsl` al contenido del objeto.
3. Espera a que el script se compile y comience a ejecutarse.

### 3. Configuración y Uso

1. Adjunta el objeto meter a tu avatar.
   - Se recomienda adjuntarlo a un punto por encima de la cabeza como "Center 2" o "Top".
   - Ajusta la posición para que el texto quede a una altura adecuada.

2. Una vez adjunto, el meter mostrará un mensaje inicial:
   ```
   Imperial Court Stats Meter
   (Connect to HUD for data)
   ```

3. Ponte también el HUD principal de la Corte Imperial.
   - El HUD y el meter se conectarán automáticamente.
   - Verás un mensaje confirmando la conexión.

4. Tras la conexión, el meter comenzará a mostrar tus estadísticas:
   - Nombre y apellido
   - Rango y título ruso
   - Posición en la corte
   - Estadísticas numéricas (salud, encanto, influencia, etc.)
   - Fe y experiencia

## Controles y Personalización

- **Tocar el objeto**: Alternar la visibilidad del texto (mostrar/ocultar).
- **Editar el script**: Si deseas personalizar el medidor, puedes modificar:
  - `TEXT_COLOR`: Para cambiar el color del texto.
  - `TEXT_ALPHA`: Para ajustar la transparencia del texto.
  - `TEXT_UPDATE_RATE`: Para modificar la frecuencia de actualización.

## Características Especiales

1. **Actualización Automática**: El meter solicita actualizaciones periódicamente al HUD.
2. **Sincronización con Base de Datos**: Los datos mostrados se sincronizan con la base de datos central.
3. **Indicadores de Género**: Muestra un símbolo masculino (♂) o femenino (♀) según corresponda.
4. **Categoría de Riqueza**: Además de mostrar los rublos, indica el nivel de riqueza de tu personaje.
5. **Nuevos Atributos**: Incluye estadística de Fe, importante para los aspectos religiosos del roleplay.

## Solución de Problemas

- **El meter no muestra datos**: Asegúrate de que el HUD principal esté adjunto y funcionando.
- **Texto desaparecido**: Toca el objeto para alternar la visibilidad.
- **Datos incorrectos**: Verifica que tu perfil esté correctamente registrado en el sistema.
- **No se actualizan las estadísticas**: Reinicia el medidor quitándolo y volviéndolo a adjuntar.

## Integración con el Sistema Principal

El Stats Meter es parte de una arquitectura de tres componentes:

1. **API Connector**: Se comunica con la base de datos en el servidor Replit.
2. **Core HUD**: Coordina las funciones y sirve como centro de control principal.
3. **Stats Meter**: Muestra las estadísticas visualmente para otros jugadores.

Para un funcionamiento óptimo, todos los componentes deben estar correctamente configurados e instalados.

---

© 2025 Imperial Russian Court RP System - Desarrollado para Second Life