# DOCUMENTACIÓN COMPLETA DEL SISTEMA DE ROLEPLAY DE LA CORTE IMPERIAL RUSA

## Índice
1. [Introducción al Sistema](#introducción)
2. [Arquitectura del Sistema](#arquitectura)
3. [Componentes Principales](#componentes)
4. [Módulos del Sistema](#módulos)
5. [Scripts y Código](#scripts)
6. [Guía de Instalación](#instalación)
7. [Guía de Uso](#uso)
8. [Solución de Problemas](#solución-de-problemas)
9. [Referencias Históricas](#referencias)

## Introducción

El Sistema de Roleplay de la Corte Imperial Rusa es un ecosistema completo diseñado para Second Life, ambientado en la Rusia Imperial del año 1905. Este sistema facilita una experiencia inmersiva de roleplay histórico, permitiendo a los usuarios interpretar diversos roles dentro de la estructura social, política y cultural de la Rusia zarista.

### Objetivo del Sistema

El objetivo principal es proporcionar una plataforma interactiva y históricamente precisa para que los jugadores puedan:

- Crear personajes históricos o ficticios dentro del contexto de la Rusia de 1905
- Interactuar con otros jugadores siguiendo las normas sociales y protocolos de la época
- Participar en eventos históricos, intrigas de la corte y actividades sociales
- Experimentar las dinámicas de poder, influencia y estatus características de la época
- Desarrollar narrativas personales dentro del marco histórico establecido

### Contexto Histórico

El sistema está ambientado específicamente en 1905, un año crucial para la historia rusa marcado por:

- El reinado del Zar Nicolás II Romanov
- Tensiones previas a la Revolución Rusa de 1905
- La guerra Ruso-Japonesa
- Cambios sociales y políticos significativos
- La existencia de diversas facciones políticas (monárquicos, liberales, socialistas, etc.)

## Arquitectura

El sistema implementa una arquitectura cliente-servidor, utilizando:

1. **Backend en Replit**: Aplicación Flask con base de datos PostgreSQL que almacena todos los datos de jugadores y estado del sistema
2. **Scripts LSL en Second Life**: HUDs y objetos interactivos que se comunican con el backend
3. **Sistema de comunicación**: Protocolo para sincronizar datos entre el backend y los componentes en Second Life

### Flujo de Datos

El flujo de información en el sistema sigue esta estructura:

```
Base de Datos (PostgreSQL) ↔ API (Flask) ↔ API Connector (LSL) ↔ Core HUD (LSL) ↔ Stats Meter (LSL)
```

Esta arquitectura permite:
- Almacenamiento persistente de datos del jugador
- Actualización en tiempo real de estadísticas y estado
- Comunicación entre distintos componentes del sistema
- Superar las limitaciones de memoria y procesamiento de LSL

## Componentes

### 1. Backend (Servidor)

El backend del sistema está desarrollado en Python utilizando Flask como framework web y PostgreSQL como base de datos. Este componente se encarga de:

- Almacenar los datos de los jugadores
- Procesar las solicitudes de actualización de estadísticas
- Gestionar eventos del sistema
- Proporcionar datos históricos precisos
- Implementar la lógica de negocio del sistema

#### Estructura de la Base de Datos

La base de datos contiene las siguientes tablas principales:

- **Players**: Información básica de los jugadores y sus estadísticas
- **Families**: Familias históricas disponibles para los personajes
- **SocialClasses**: Clases sociales del sistema
- **Professions**: Profesiones disponibles por clase social
- **PoliticalFactions**: Facciones políticas del periodo histórico
- **HistoricalEvents**: Eventos relevantes del contexto histórico

### 2. API Connector (Second Life)

Script LSL que actúa como intermediario entre el backend y los componentes en Second Life. Sus funciones son:

- Enviar solicitudes HTTP al backend
- Recibir y procesar respuestas del servidor
- Formatear y distribuir los datos a otros componentes
- Mantener la autenticación con el backend
- Manejar la reconexión en caso de fallos

### 3. Core HUD

Componente principal que el jugador usa en Second Life. Se encarga de:

- Mostrar la interfaz de usuario
- Gestionar la creación de personajes
- Proporcionar acceso a los distintos módulos del sistema
- Enviar comandos al API Connector
- Sincronizar datos con el Stats Meter

### 4. Stats Meter

Componente que muestra las estadísticas del personaje a otros jugadores mediante texto flotante. Sus funciones:

- Mostrar información básica del personaje
- Visualizar las estadísticas actuales
- Indicar el estado del personaje (salud, condición, etc.)
- Actualizar la información en tiempo real
- Aplicar formato según el rango y posición social

## Módulos

El sistema está organizado en módulos funcionales que pueden activarse independientemente:

### Módulo de Personajes

Gestiona la creación y personalización de personajes, incluyendo:

- Selección de nombre y apellido
- Elección de familia noble o histórica
- Asignación de clase social y rango
- Selección de profesión según clase social
- Afiliación a una facción política
- Configuración de género y ajustes personales

### Módulo de Estadísticas

Controla las estadísticas vitales y sociales del personaje:

- **Salud**: Estado físico del personaje (0-100)
- **Experiencia**: Puntos de experiencia acumulados
- **Influencia**: Capacidad para influir en otros personajes
- **Riqueza**: Nivel económico del personaje
- **Rublos**: Moneda del sistema
- **Encanto**: Atractivo social del personaje
- **Popularidad**: Reconocimiento en la sociedad
- **Puntos de Amor**: Capacidad para relaciones románticas
- **Lealtad**: Fidelidad a una causa o persona
- **Fe**: Devoción religiosa

### Módulo de Consecuencias

Implementa efectos basados en los niveles de estadísticas:

- **Salud a 0**: Estado de coma
- **Coma prolongado**: Posibilidad de muerte
- **Resurrección**: Posible con artefacto religioso si Fe > 90
- **Niveles críticos**: Efectos visuales y limitaciones a los personajes

### Módulo de Etiqueta

Sistema que regula las normas sociales y protocolos de la corte:

- Formas correctas de tratamiento según rango
- Precedencia en eventos sociales
- Normas de comportamiento en la corte
- Consecuencias por violación del protocolo
- Reconocimiento de rangos y títulos

### Módulo de Familias

Gestiona las relaciones familiares y dinásticas:

- Pertenencia a familias históricas
- Creación de nuevos lazos familiares
- Herencia de prestigio y riqueza
- Disputas y alianzas familiares
- Matrimonios estratégicos

### Módulo de Política

Controla las facciones políticas y su influencia:

- Afiliación a corrientes políticas de la época
- Eventos políticos históricos
- Consecuencias de posicionamientos políticos
- Cambios de facciones y lealtades
- Influencia política en la corte

### Módulo de Religión

Sistema para la dimensión religiosa del roleplay:

- Prácticas religiosas ortodoxas
- Influencia del clero en la sociedad
- Festividades y ceremonias religiosas
- Niveles de devoción y sus efectos
- Blasfemia y sus consecuencias

### Módulo de Cultura

Proporciona contexto cultural para el roleplay:

- Arte (pintura, música, literatura)
- Bailes y protocolos sociales
- Tradiciones rusas de la época
- Influencias europeas y asiáticas
- Educación y conocimientos de la época

## Scripts y Código

A continuación se detallan los principales scripts del sistema y sus funcionalidades:

### Scripts de Backend

#### 1. app.py

Script principal del backend Flask que implementa:

- Rutas API para interactuar con la base de datos
- Lógica para la creación y actualización de personajes
- Sistema de daño y curación para los personajes
- Endpoints para consultar datos históricos
- Gestión de familias nobles y clases sociales

```python
# Fragmento de código relevante:
@app.route('/api/player/<player_id>', methods=['GET'])
def get_player(player_id):
    """Obtiene un jugador por ID"""
    player = Player.query.get(player_id)
    if player is None:
        return jsonify({'error': 'Jugador no encontrado'}), 404
    return jsonify(player.to_dict())
```

#### 2. historical_data.py

Contiene los datos históricos para el sistema:

- Clases sociales de la Rusia Imperial
- Profesiones disponibles por clase social
- Familias nobles históricas
- Facciones políticas de la época
- Eventos históricos relevantes de 1905

#### 3. initialize_database.py

Script para inicializar la base de datos con datos predefinidos:

- Crear tablas necesarias
- Cargar datos históricos iniciales
- Configurar relaciones entre entidades
- Establecer valores predeterminados

### Scripts LSL para Second Life

#### 1. Imperial_Court_HUD_API_Connector.lsl

Script que conecta el HUD con la API del backend:

- Gestiona las solicitudes HTTP
- Procesa las respuestas de la API
- Distribuye los datos a otros componentes
- Maneja errores de conexión
- Implementa autenticación básica

```lsl
// Fragmento de código relevante:
string makeAPIRequest(string endpoint, string method, string data) {
    string url = API_BASE_URL + endpoint;
    key requestID = llHTTPRequest(url, [HTTP_METHOD, method, HTTP_MIMETYPE, 
        "application/json"], data);
    pendingRequests += [requestID];
    return "REQUEST_SENT";
}
```

#### 2. Imperial_Russian_Court_Core_HUD.lsl

HUD principal del sistema que implementa:

- Interfaz de usuario mediante menús
- Comunicación con el API Connector
- Gestión de estado del personaje
- Interacción con otros componentes
- Opciones de personalización

```lsl
// Fragmento de código relevante:
showMainMenu() {
    list buttons = ["Estadísticas", "Habilidades", "Social", "OOC"];
    if (isAdmin) {
        buttons += ["Admin"];
    }
    llDialog(llGetOwner(), "Bienvenido al Sistema de la Corte Imperial\n" +
        "Seleccione una opción:", buttons, MENU_CHANNEL);
}
```

#### 3. Imperial_Court_Core_Meter.lsl

Script que muestra las estadísticas del personaje mediante texto flotante:

- Formato visual de estadísticas
- Actualización en tiempo real
- Visibilidad configurable
- Comunicación con el Core HUD
- Indicadores de estado especial

```lsl
// Fragmento de código relevante:
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    string displayText = playerName + " " + familyName + "\n";
    
    // Añadir clase social y rango
    if (rankName != "") {
        displayText += rankName + "\n";
    }
    
    // Mostrar estadísticas principales
    displayText += "❤ Salud: " + (string)health + "/100\n";
    displayText += "⚜ Influencia: " + (string)influence + "\n";
    displayText += "💰 Riqueza: " + llList2String(WEALTH_RANKS, wealth) + "\n";
    
    // Indicadores de estado
    if (isDead) {
        displayText += "☦ FALLECIDO ☦\n";
    }
    else if (health <= 20) {
        displayText += "⚠ Salud crítica ⚠\n";
    }
    
    // Modo OOC
    if (isOOC) {
        displayText += "[FUERA DE PERSONAJE]";
    }
    
    llSetText(displayText, TEXT_COLOR, TEXT_ALPHA);
}
```

#### 4. Imperial_Court_Meter_Fixed.lsl

Versión mejorada del Stats Meter con correcciones y optimizaciones:

- Errores de sintaxis corregidos
- Mejor manejo de memoria
- Comunicación más robusta
- Formato visual mejorado
- Indicadores adicionales

#### 5. Imperial_Court_Etiquette_Module.lsl

Script que implementa el sistema de etiqueta de la corte:

- Reconocimiento de rangos
- Validación de formas de tratamiento
- Verificación de protocolos
- Penalizaciones por incumplimiento
- Referencias históricas de etiqueta

```lsl
// Fragmento de código relevante:
integer checkAddressing(string message, integer speakerRank, integer targetRank) {
    if (speakerRank < targetRank) {
        // Si el hablante tiene rango inferior al objetivo
        if (llSubStringIndex(message, "Excelencia") == -1 && 
            llSubStringIndex(message, "Su Alteza") == -1) {
            return FALSE; // Falta forma de tratamiento adecuada
        }
    }
    return TRUE; // Forma de tratamiento correcta
}
```

## Guía de Instalación

### Requisitos Previos

- Cuenta en Second Life
- Permisos de creación de scripts en la región
- Acceso al servidor backend (Replit)

### Instalación del Backend

1. Acceder al proyecto Replit
2. Asegurarse de que todas las dependencias están instaladas:
   - Flask
   - Flask-SQLAlchemy
   - Psycopg2
   - Requests
   - SQLAlchemy
3. Verificar la configuración de la base de datos PostgreSQL
4. Ejecutar el script de inicialización de la base de datos:
   ```
   python initialize_database.py
   ```
5. Iniciar el servidor Flask:
   ```
   python app.py
   ```

### Instalación del Sistema en Second Life

#### 1. HUD Principal

1. Crear un nuevo objeto en Second Life
2. Añadir el script `Imperial_Russian_Court_Core_HUD.lsl`
3. Configurar el objeto como HUD (botón derecho → Adjuntar a HUD)
4. Verificar permisos de script (debe tener permisos para HTTP Requests)

#### 2. API Connector

1. Crear un nuevo prim en el HUD principal
2. Añadir el script `Imperial_Court_HUD_API_Connector.lsl`
3. Editar la URL base en el script para apuntar al servidor correcto
4. Verificar la clave de autenticación (ImperialCourtAuth1905)

#### 3. Stats Meter

1. Crear un nuevo objeto en Second Life
2. Añadir el script `Imperial_Court_Core_Meter.lsl`
3. Configurar el objeto para que flote sobre la cabeza del avatar
4. Verificar que el canal de comunicación coincide con el HUD (-987654321)

#### 4. Módulos Adicionales

Para cada módulo adicional:

1. Crear un nuevo prim en el HUD principal o un objeto separado
2. Añadir el script correspondiente al módulo
3. Verificar que los canales de comunicación coinciden
4. Configurar permisos según sea necesario

## Guía de Uso

### Creación de Personaje

1. Ponerse el HUD principal
2. Seleccionar la opción "Crear Personaje" en el menú principal
3. Seguir el asistente para configurar:
   - Nombre y apellido
   - Familia (histórica o nueva)
   - Clase social y rango
   - Profesión
   - Facción política
   - Género
4. Confirmar la creación del personaje

### Uso del HUD

El HUD principal ofrece las siguientes opciones:

- **Estadísticas**: Ver y gestionar estadísticas del personaje
- **Social**: Interactuar con otros personajes (saludos, presentaciones)
- **Etiqueta**: Consultar normas de protocolo según el contexto
- **Política**: Gestionar afiliaciones políticas
- **Eventos**: Participar en eventos de la corte
- **OOC**: Activar/desactivar modo fuera de personaje

### Gestión de Estadísticas

Las estadísticas pueden cambiar por:

- Interacción social positiva (aumenta Charm, Popularity)
- Eventos políticos (afecta Influence, Loyalty)
- Actividades religiosas (aumenta Faith)
- Transacciones económicas (modifica Wealth, Rubles)
- Daño en combate o enfermedad (reduce Health)

### Sistema de Daño y Curación

- El daño reduce la salud del personaje
- Al llegar a 0 de salud, el personaje entra en coma
- Después de un tiempo en coma, puede morir
- La curación restaura puntos de salud
- Un personaje muerto puede revivir si tenía alta Fe

## Solución de Problemas

### Problemas Comunes y Soluciones

#### 1. Falta de Comunicación entre Componentes

**Problema**: El Core HUD no se comunica con el Stats Meter.

**Solución**:
- Verificar que ambos componentes utilizan el mismo canal (-987654321)
- Comprobar que el formato de los mensajes es correcto
- Reiniciar ambos scripts
- Verificar que no hay variables con nombres reservados (como "key")

#### 2. Errores de Conexión con el Backend

**Problema**: No se puede conectar con el servidor.

**Solución**:
- Verificar que la URL del backend es correcta
- Comprobar que el servidor está en funcionamiento
- Verificar permisos de HTTP Request en Second Life
- Revisar la clave de autenticación

#### 3. Datos Incorrectos o Incompletos

**Problema**: Las estadísticas o información del personaje son incorrectas.

**Solución**:
- Solicitar actualización manual de datos
- Verificar la sincronización con el backend
- Reiniciar el HUD
- Comprobar el formato de los datos en la base de datos

#### 4. Errores de Sintaxis en Scripts

**Problema**: El script muestra errores o no funciona correctamente.

**Solución**:
- Evitar estructuras no soportadas en LSL (ternarios, void, break)
- Declarar todas las variables al inicio de las funciones
- No usar nombres reservados como "key"
- Verificar que todos los vectores usan decimales (1.0 en lugar de 1)

## Referencias

### Fuentes Históricas

- **La Corte del Zar Nicolás II**: Estructura y protocolos
- **Rusia en 1905**: Contexto político y social
- **Tabla de Rangos Imperial Rusa**: Sistema de clases y rangos
- **Familias Nobles Rusas**: Genealogía y relaciones
- **Protocolo y Etiqueta en la Corte Imperial**: Normas sociales de la época

### Recursos Técnicos

- **LSL Wiki**: Referencia del lenguaje LSL
- **Flask Documentation**: Documentación de Flask
- **PostgreSQL Documentation**: Manual de PostgreSQL
- **Second Life Developer Portal**: Recursos para desarrolladores SL

---

*Este documento es parte del Sistema de Roleplay de la Corte Imperial Rusa, desarrollado específicamente para Second Life. Todos los derechos reservados.*