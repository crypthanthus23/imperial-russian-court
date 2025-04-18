# Sistema de Juego de Rol de la Corte Imperial Rusa
## Manual Completo de Usuario

*Versión 2.0 - Abril 2025*

---

## Índice de Contenidos

1. [Introducción](#introducción)
2. [Instalación del Sistema](#instalación-del-sistema)
3. [Sistema de HUD Principal](#sistema-de-hud-principal)
   - [HUD Core para Nobles Comunes](#hud-core-para-nobles-comunes)
   - [Menús y Comandos Básicos](#menús-y-comandos-básicos)
4. [HUDs Especiales](#huds-especiales)
   - [Tsar Nikolai II HUD](#tsar-nikolai-ii-hud)
   - [Tsarina Alexandra HUD](#tsarina-alexandra-hud)
   - [Tsarevich Alexei HUD](#tsarevich-alexei-hud)
   - [HUDs para las Grandes Duquesas](#huds-para-las-grandes-duquesas)
   - [Dowager Empress HUD](#dowager-empress-hud)
   - [Rasputin HUD](#rasputin-hud)
   - [Otros Miembros de la Familia Romanov](#otros-miembros-de-la-familia-romanov)
5. [Sistema de Estadísticas (Meter)](#sistema-de-estadísticas-meter)
   - [Estadísticas Básicas](#estadísticas-básicas)
   - [Configuración del Meter](#configuración-del-meter)
   - [Modo Silencioso](#modo-silencioso)
6. [Módulos del Sistema](#módulos-del-sistema)
   - [Módulo de Política y Facciones](#módulo-de-política-y-facciones)
   - [Módulo de Matrimonio](#módulo-de-matrimonio)
   - [Módulo de Educación y Academia](#módulo-de-educación-y-academia)
   - [Módulo de Banquete](#módulo-de-banquete)
   - [Módulo de Etiqueta](#módulo-de-etiqueta)
   - [Módulo de Religión](#módulo-de-religión)
   - [Módulo de Reputación](#módulo-de-reputación)
   - [Módulo de Romance](#módulo-de-romance)
   - [Módulo de Relaciones](#módulo-de-relaciones)
   - [Módulo de Visitantes Extranjeros](#módulo-de-visitantes-extranjeros)
   - [Módulo de Artes y Cultura](#módulo-de-artes-y-cultura)
   - [Módulo de Gran Duque](#módulo-de-gran-duque)
7. [Objetos Interactivos](#objetos-interactivos)
   - [Sable Ceremonial](#sable-ceremonial)
   - [Candelabro Reactivo](#candelabro-reactivo)
   - [Sistema de Banquete](#sistema-de-banquete)
   - [Íconos Religiosos](#íconos-religiosos)
   - [Samovar](#samovar)
   - [Otros Objetos](#otros-objetos)
8. [NPCs](#npcs)
   - [Guardias Imperiales](#guardias-imperiales)
   - [Sirvientes de la Corte](#sirvientes-de-la-corte)
   - [Baba Yaga](#baba-yaga)
   - [Fantasma de Ekaterina](#fantasma-de-ekaterina)
9. [Sistema de Combate](#sistema-de-combate)
10. [Registro y Resolución de Problemas](#registro-y-resolución-de-problemas)
11. [Créditos y Contacto](#créditos-y-contacto)

---

<a name="introducción"></a>
## 1. Introducción

Bienvenido al Sistema de Juego de Rol de la Corte Imperial Rusa, un sistema completo diseñado para Second Life que recrea la vida en la corte del Tsar Nikolai II alrededor de 1905. Este sistema ha sido creado para proporcionar una experiencia de juego de rol inmersiva y detallada que refleja con precisión histórica la complejidad de la vida en la corte imperial rusa.

### Objetivos del Sistema

- Recrear con precisión histórica la Corte Imperial Rusa de 1905
- Proporcionar mecánicas de juego de rol detalladas para interacciones sociales
- Ofrecer experiencias únicas para diferentes rangos y roles sociales
- Facilitar eventos dinámicos y tramas narrativas en el entorno del roleplay

### Características Principales

- HUDs especializados para cada rol importante en la corte
- Sistema detallado de estadísticas visibles (meters)
- Módulos temáticos para diferentes aspectos de la vida cortesana
- Objetos interactivos que responden a la presencia de personajes
- NPCs con reconocimiento específico de personajes imperiales
- Sistema de política, facciones e intrigas cortesanas

---

<a name="instalación-del-sistema"></a>
## 2. Instalación del Sistema

### Requisitos Previos

- Una cuenta activa en Second Life
- Permisos necesarios para usar attachments y scripts
- Un avatar configurado apropiadamente para la época histórica (1905)

### Pasos de Instalación

1. **HUD Básico**:
   - Usar el objeto "Imperial Russian Court HUD Giver" para obtener el HUD básico
   - Adjuntar el HUD a la posición recomendada (típicamente la parte superior derecha de la pantalla)
   - Esperar a que el HUD se inicialice completamente (~5 segundos)

2. **Meter de Estadísticas**:
   - Obtener el objeto "Imperial Court Meter" del mismo dispensador
   - Adjuntar el meter (generalmente se coloca automáticamente sobre la cabeza)
   - Verificar que el HUD y el meter estén comunicándose correctamente

3. **HUDs Especiales** (si corresponde a tu rol):
   - Los HUDs especiales para miembros de la familia imperial están restringidos y requieren autorización previa
   - Los administradores del roleplay proporcionarán el HUD específico según tu rol asignado
   - Sigue las instrucciones específicas para cada HUD especializado

4. **Módulos Adicionales**:
   - Varios módulos funcionales están disponibles según tu rol y posición
   - Usa el menú de configuración en el HUD principal para activar los módulos autorizados
   - Algunos módulos requieren permiso del administrador del roleplay

---

<a name="sistema-de-hud-principal"></a>
## 3. Sistema de HUD Principal

<a name="hud-core-para-nobles-comunes"></a>
### HUD Core para Nobles Comunes

El HUD principal (Imperial_Russian_Court_Core_HUD.lsl) es el centro de control para todos los jugadores y contiene las funcionalidades básicas compartidas por todos los participantes del roleplay.

#### Características Principales

- **Gestión de Identidad**: Almacenamiento y configuración de tu nombre completo, título y rango
- **Estadísticas Básicas**: Control de tus atributos principales (salud, energía, influencia, etc.)
- **Coordinación de Módulos**: Interfaz central para activar y gestionar módulos adicionales
- **Canal de Comunicación**: Sistema que conecta el HUD con el meter y los objetos interactivos
- **Sistema de Notificaciones**: Alertas sobre eventos y cambios importantes en el juego

#### Inicialización y Configuración

Al usar el HUD por primera vez, deberás configurar tu identidad:

1. Toca el HUD para abrir el menú principal
2. Selecciona "Configuración Inicial"
3. Ingresa tu nombre completo cuando se te solicite
4. Selecciona tu título nobiliario (si corresponde)
5. Confirma tus datos para guardarlos en el sistema

<a name="menús-y-comandos-básicos"></a>
### Menús y Comandos Básicos

#### Menú Principal
Al tocar el HUD, aparecerá el menú principal con las siguientes opciones:

- **Perfil**: Muestra y permite editar tu información personal
- **Estadísticas**: Muestra tus atributos actuales y te permite ajustar la visualización
- **Módulos**: Acceso a los módulos adicionales activados
- **Social**: Opciones para interacciones sociales básicas
- **Ayuda**: Información sobre comandos y funciones
- **Admin**: (Solo para administradores) Funciones de gestión del sistema

#### Comandos de Chat
Los siguientes comandos pueden ser utilizados en el chat local:

- `/icr status` - Muestra tu estado actual y estadísticas
- `/icr help` - Muestra lista de comandos disponibles
- `/icr quiet` - Alterna el modo silencioso (menos notificaciones)
- `/icr ooc` - Activa/desactiva el modo fuera de personaje
- `/icr version` - Muestra la versión actual del sistema

#### Interacción con Otros Jugadores
Para interactuar con otros jugadores:

1. Haz clic en el avatar del otro jugador para seleccionarlo
2. Toca tu HUD para abrir el menú
3. Selecciona "Social" para ver opciones de interacción
4. Elige la acción deseada del menú contextual

---

<a name="huds-especiales"></a>
## 4. HUDs Especiales

<a name="tsar-nikolai-ii-hud"></a>
### Tsar Nikolai II HUD

El HUD del Tsar (Imperial_Tsar_HUD.lsl) contiene funcionalidades únicas reservadas para el gobernante del Imperio Ruso.

#### Características Exclusivas

- **Autoridad Imperial**: Capacidad para emitir decretos imperiales vinculantes
- **Gestión de la Corte**: Herramientas para otorgar títulos, medallas y reconocimientos
- **Reconocimiento Automático**: Los NPCs y objetos reconocen automáticamente al Tsar
- **Protocolo Imperial**: Notificaciones cuando alguien no cumple con el protocolo
- **Control de Facciones**: Supervisión de todas las facciones políticas

#### Menú del Tsar
El menú principal del Tsar incluye estas opciones únicas:

- **Decretos**: Emitir declaraciones oficiales y órdenes
- **Honores**: Otorgar títulos, medallas y reconocimientos
- **Audiencias**: Gestionar solicitudes de audiencia imperial
- **Política Imperial**: Supervisar ministerios y facciones
- **Familia Imperial**: Interacción especial con miembros de la familia

#### Uso del Sistema de Decretos

1. Selecciona "Decretos" en el menú principal
2. Elige el tipo de decreto a emitir
3. Redacta el contenido del decreto cuando se te solicite
4. Selecciona el alcance del decreto (público, limitado, privado)
5. Confirma para emitir el decreto oficial

<a name="tsarina-alexandra-hud"></a>
### Tsarina Alexandra HUD

El HUD de la Tsarina (Imperial_Tsarina_HUD.lsl) está diseñado específicamente para la consorte imperial con funciones únicas.

#### Características Exclusivas

- **Patronazgo Social**: Capacidad para patrocinar obras benéficas y eventos
- **Influencia Social**: Mayor impacto en interacciones sociales y reputación
- **Gestión de la Familia Imperial**: Herramientas específicas para supervisar a los hijos
- **Audiencias Privadas**: Sistema para organizar reuniones privadas
- **Supervisión del Palacio**: Control sobre el personal y protocolos del palacio

#### Menú de la Tsarina
El menú específico incluye:

- **Patronazgo**: Gestionar obras benéficas y proyectos sociales
- **Familia Imperial**: Interacciones especiales con los hijos y familiares
- **Eventos Sociales**: Organizar y gestionar eventos de la corte
- **Palacio Imperial**: Administrar el personal y protocolo
- **Audiencias**: Gestionar solicitudes de audiencia privada

<a name="tsarevich-alexei-hud"></a>
### Tsarevich Alexei HUD

El HUD del Tsarevich (Imperial_Tsarevich_HUD.lsl) incorpora elementos relacionados con su condición de hemofilia y su rol como heredero.

#### Características Exclusivas

- **Sistema de Hemofilia**: Simulación de la condición médica del heredero
- **Episodios de Sangrado**: Eventos aleatorios que requieren atención médica
- **Educación Imperial**: Sistema para su educación como futuro emperador
- **Interacción con Tutores**: Mecánicas para lecciones y desarrollo educativo
- **Vínculo con Rasputin**: Conexión especial con el sanador cuando está presente

#### Sistema de Hemofilia
El sistema de hemofilia funciona de la siguiente manera:

1. **Episodios Aleatorios**: Ocasionalmente ocurren episodios de sangrado
2. **Niveles de Severidad**: Los episodios pueden ser leves, moderados o severos
3. **Tratamiento**: Requiere asistencia médica o intervención de Rasputin
4. **Recuperación**: Período de convalecencia después de un episodio
5. **Notificaciones**: Alertas críticas que no pueden ser silenciadas con el modo silencioso

#### Gestión de Episodios

1. Durante un episodio, aparecerá una alerta en el HUD
2. El meter mostrará un color rojo parpadeante
3. Busca asistencia médica o a Rasputin
4. Los íconos religiosos pueden proporcionar alivio temporal
5. Sigue las instrucciones para el período de recuperación

<a name="huds-para-las-grandes-duquesas"></a>
### HUDs para las Grandes Duquesas

Las cuatro hijas del Tsar (Olga, Tatiana, Maria y Anastasia) tienen HUDs especiales con características únicas.

#### Características Compartidas

- **Educación de Duquesa**: Sistema para aprendizaje de habilidades cortesanas
- **Obras de Caridad**: Capacidad para organizar y participar en obras benéficas
- **Vínculos Familiares**: Interacciones especiales entre las hermanas
- **Eventos Sociales**: Participación destacada en eventos de la corte
- **Títulos Dinámicos**: Visualización específica de títulos en el meter

#### Características Específicas

**Olga (Imperial_Grand_Duchess_Olga_Alex_HUD.lsl)**
- Mayor influencia en decisiones familiares como hermana mayor
- Habilidades especiales en literatura y música
- Sistema de tutoría para sus hermanas menores

**Tatiana (Imperial_Tatiana_HUD.lsl)**
- Coordinación de enfermería y obras benéficas
- Mayor eficiencia en la gestión del personal del palacio
- Habilidades especiales de organización

**Maria (Imperial_Maria_HUD.lsl)**
- Mayores habilidades sociales y diplomáticas
- Bonificación en interacciones con visitantes extranjeros
- Aptitudes artísticas mejoradas

**Anastasia (Imperial_Anastasia_HUD.lsl)**
- Sistema de bromas y travesuras
- Mayor movilidad y energía
- Habilidades para evadir protocolos estrictos

<a name="dowager-empress-hud"></a>
### Dowager Empress HUD

El HUD de la Emperatriz Viuda (Imperial_Dowager_Empress_HUD.lsl) proporciona funcionalidades específicas para la madre del Tsar.

#### Características Exclusivas

- **Influencia Histórica**: Mayor peso en decisiones tradicionales
- **Autoridad Moral**: Capacidad para intervenir en conflictos familiares
- **Protocolo Antiguo**: Conocimiento y aplicación del protocolo tradicional
- **Precedencia Especial**: Estatus ceremonial único en eventos oficiales
- **Residencia Propia**: Control sobre el Palacio Anichkov

#### Menú de la Emperatriz Viuda
El menú incluye opciones especiales como:

- **Tradición Imperial**: Invocar costumbres y protocolos antiguos
- **Consejo Imperial**: Ofrecer consejo con gran peso al Tsar
- **Mecenazgo Cultural**: Patrocinio de artes tradicionales rusas
- **Residencia**: Gestión del Palacio Anichkov y su personal
- **Memoria Histórica**: Compartir eventos históricos con bonificaciones a la influencia

<a name="rasputin-hud"></a>
### Rasputin HUD

El HUD de Rasputin (Imperial_Rasputin_HUD.lsl) incorpora habilidades místicas y curativas únicas.

#### Características Exclusivas

- **Curación Mística**: Capacidad para tratar la hemofilia del Tsarevich
- **Profecías**: Habilidad para predecir eventos futuros
- **Influencia Espiritual**: Efectos sobre la religiosidad y espiritualidad
- **Controversia**: Sistema de reputación dual (venerado/despreciado)
- **Conexión con la Tsarina**: Vínculo especial con Alexandra

#### Sistema de Curación
El proceso de curación funciona así:

1. Selecciona "Curación" en el menú principal
2. Escoge el tipo de curación (física, espiritual, específica)
3. Si el Tsarevich está presente, aparecerá una opción especial para su hemofilia
4. Realiza el ritual siguiendo las instrucciones
5. Los efectos se aplican automáticamente a los objetivos

#### Sistema de Profecías

1. Selecciona "Profecía" en el menú
2. Elige entre profecía personal, general o imperial
3. Sigue el proceso de revelación mística
4. La profecía se comunicará a los presentes
5. Las profecías pueden tener efectos reales en eventos futuros

<a name="otros-miembros-de-la-familia-romanov"></a>
### Otros Miembros de la Familia Romanov

Varios miembros extendidos de la familia Romanov tienen HUDs especializados.

#### Gran Duque Michael (Imperial_Grand_Duke_Michael_HUD.lsl)
- Estatus como heredero temporal al trono
- Comandos militares especiales
- Posibilidad de regencia

#### Gran Duque Dmitri (Imperial_Grand_Duke_Dmitri_HUD.lsl)
- Habilidades sociales de alto nivel
- Conexiones con la nobleza europea
- Sistema de patrocinio artístico

#### Gran Duquesa Xenia (Imperial_Grand_Duchess_Xenia_HUD.lsl)
- Funciones de patronazgo social
- Gestión de obras benéficas
- Vínculos familiares fortalecidos

#### Gran Duque Nicholas Nikolaevich (Imperial_GD_Nicholas_Nikolaevich_HUD.lsl)
- Comando militar supremo
- Gestión de facciones militares
- Capacidades estratégicas

---

<a name="sistema-de-estadísticas-meter"></a>
## 5. Sistema de Estadísticas (Meter)

<a name="estadísticas-básicas"></a>
### Estadísticas Básicas

El sistema de meter (Imperial_Court_Meter_Updated.lsl) muestra visualmente las estadísticas y estado del personaje.

#### Estadísticas Principales

- **Salud**: Condición física general (0-100)
- **Energía**: Capacidad para realizar acciones (0-100)
- **Influencia**: Poder político y social (0-100)
- **Reputación**: Cómo es percibido por la sociedad (0-100)
- **Riqueza**: Recursos económicos disponibles (0-100)
- **Piedad**: Devoción religiosa (0-100)

#### Estadísticas Derivadas

- **Conexiones**: Red de contactos útiles
- **Educación**: Nivel de formación académica
- **Elegancia**: Dominio del protocolo y etiqueta
- **Favor Imperial**: Beneplácito del Tsar
- **Honor Familiar**: Reputación de tu linaje

#### Visualización de Estados

El meter también muestra estados especiales:

- **Enfermedad**: Cuando el personaje está enfermo
- **Fatiga**: Cuando la energía está muy baja
- **Desgracia**: Cuando has caído en desgracia ante el Tsar
- **Duelo**: Cuando estás participando en un duelo
- **OOC**: Cuando estás en modo fuera de personaje

<a name="configuración-del-meter"></a>
### Configuración del Meter

#### Ajuste de Visualización

1. Toca el meter para acceder a su menú
2. Selecciona "Configuración"
3. Ajusta la altura, tamaño de texto y opacidad
4. Selecciona qué estadísticas deseas mostrar u ocultar
5. Elige entre diferentes estilos visuales disponibles

#### Colores y Estilo

El meter puede personalizarse con diferentes esquemas de color:

- **Imperial**: Dorado y negro (estilo oficial)
- **Noble**: Azul y plata
- **Militar**: Verde y dorado
- **Eclesiástico**: Morado y oro
- **Personalizado**: Define tus propios colores

Para cambiar el estilo:
1. Selecciona "Estilos" en el menú de configuración
2. Elige el esquema de color deseado
3. Ajusta los colores personalizados si es necesario

<a name="modo-silencioso"></a>
### Modo Silencioso

El modo silencioso reduce la cantidad de notificaciones y actualizaciones visibles.

#### Activación

- Método 1: Selecciona "Modo Silencioso" en el menú del meter
- Método 2: Doble clic en el meter para alternar el modo
- Método 3: Usa el comando `/icr quiet` en el chat

#### Características

- Reduce notificaciones de cambios pequeños en estadísticas
- Elimina mensajes de actividades rutinarias
- Muestra solo cambios significativos y alertas importantes
- Las notificaciones críticas (como episodios de sangrado del Tsarevich) no se silencian

---

<a name="módulos-del-sistema"></a>
## 6. Módulos del Sistema

<a name="módulo-de-política-y-facciones"></a>
### Módulo de Política y Facciones

El módulo de política (Imperial_Politics_Factions_Module.lsl) permite participar en el complejo juego de intrigas políticas de la corte imperial.

#### Facciones Principales

- **Conservadores**: Tradicionalistas que apoyan el poder autocrático
- **Liberales**: Partidarios de reformas políticas y constitucionales
- **Militaristas**: Centrados en el poderío militar y expansión
- **Eslavófilos**: Defensores de la identidad y valores rusos tradicionales
- **Occidentalistas**: Favorecen la modernización siguiendo modelos occidentales

#### Unirse a una Facción

1. Abre el menú de módulos y selecciona "Política"
2. Selecciona "Facciones" y luego "Unirse"
3. Revisa las descripciones de cada facción
4. Selecciona la facción deseada
5. Completa el proceso de iniciación (puede requerir aprobación)

#### Actividades Políticas

El módulo permite:

- **Intrigas**: Conspiraciones para aumentar tu influencia
- **Cabildeo**: Intentos de influir en decisiones imperiales
- **Alianzas**: Formación de pactos con otros jugadores
- **Debates**: Confrontaciones ideológicas con otras facciones
- **Publicaciones**: Difusión de ideas políticas

#### Sistema de Lealtad

Tu lealtad a una facción se mide de 0-100:

- **0-25**: Simpatizante (beneficios mínimos)
- **26-50**: Miembro reconocido (beneficios estándar)
- **51-75**: Miembro destacado (beneficios importantes)
- **76-100**: Líder faccional (beneficios máximos)

Las acciones favorables a tu facción aumentan lealtad, mientras que las contrarias la reducen.

<a name="módulo-de-matrimonio"></a>
### Módulo de Matrimonio

El módulo de matrimonio (Imperial_Marriage_Module.lsl) gestiona el cortejo, compromiso y matrimonio en la sociedad imperial.

#### Fases de Relación

1. **Presentación Formal**: Requisito inicial para el cortejo
2. **Cortejo**: Período de interacción romántica supervisada
3. **Compromiso**: Anuncio oficial de la intención de matrimonio
4. **Matrimonio**: Ceremonia y nuevo estatus social

#### Proceso de Cortejo

1. Solicita una presentación formal (requiere un padrino)
2. Una vez presentados, inicia el cortejo seleccionando "Cortejo" en el módulo
3. Envía propuestas de actividades románticas (paseos, bailes, conversaciones)
4. Aumenta el nivel de afinidad mediante interacciones exitosas
5. Cuando la afinidad es suficiente, solicita el compromiso

#### Matrimonio y Beneficios

El matrimonio proporciona:

- Compartir apellido (según opciones elegidas)
- Acceso a residencias compartidas
- Bonificaciones de influencia y reputación
- Posibilidad de tener hijos (mediante el Módulo Familiar)
- Participación conjunta en eventos sociales

#### Restricciones Sociales

El sistema incluye:

- Requisitos de aprobación familiar para matrimonios importantes
- Diferencias de estatus social que afectan la viabilidad del matrimonio
- Restricciones religiosas sobre ciertos tipos de uniones
- Períodos de duelo que impiden nuevos cortejos

<a name="módulo-de-educación-y-academia"></a>
### Módulo de Educación y Academia

El módulo de educación (Imperial_Education_Academia_Module.lsl) permite desarrollar conocimientos académicos y participar en la vida intelectual.

#### Áreas de Estudio

- **Ciencias**: Matemáticas, física, química, biología
- **Humanidades**: Historia, literatura, filosofía, arte
- **Idiomas**: Francés, inglés, alemán, otros idiomas europeos
- **Militar**: Estrategia, táctica, logística
- **Gobierno**: Política, economía, diplomacia

#### Sistema de Aprendizaje

1. Selecciona "Educación" en el menú de módulos
2. Elige un área de estudio y una disciplina específica
3. Participa en actividades educativas (lecciones, debates, investigación)
4. Aumenta tu nivel de conocimiento (1-10 para cada disciplina)
5. Desbloquea roles académicos con niveles altos

#### Roles Académicos

- **Estudiante**: Nivel básico, disponible para todos
- **Académico**: Requiere nivel 7+ en al menos tres disciplinas
- **Profesor**: Requiere nivel 9+ en una disciplina específica
- **Rector**: Rol administrativo de alto nivel (asignado por administradores)

#### Actividades Académicas

- **Lecciones**: Enseñar o asistir a clases formales
- **Investigación**: Trabajo académico para aumentar conocimiento
- **Debates**: Discusiones intelectuales con otros académicos
- **Publicaciones**: Crear y compartir trabajos académicos
- **Conferencias**: Eventos educativos formales

<a name="módulo-de-banquete"></a>
### Módulo de Banquete

El módulo de banquete (Imperial_Banquet_System.lsl) gestiona eventos gastronómicos formales con protocolo estricto.

#### Tipos de Eventos

- **Banquete Imperial**: Máxima formalidad, presidido por el Tsar
- **Cena Formal**: Alta formalidad, puede ser presidida por nobles importantes
- **Almuerzo Aristocrático**: Formalidad media, eventos sociales diurnos
- **Té Social**: Menor formalidad, enfocado en conversación

#### Organización de Banquetes

1. Selecciona "Banquete" en el menú de módulos
2. Elige "Organizar" y selecciona el tipo de evento
3. Define la lista de invitados y el nivel de protocolo
4. Asigna asientos según precedencia (automático o manual)
5. Inicia el evento cuando los preparativos estén completos

#### Roles en Banquetes

- **Anfitrión**: Organizador y gestor del evento
- **Invitado de Honor**: Posición destacada en la mesa
- **Mayordomo**: Supervisa el servicio (NPC o jugador)
- **Maestro de Ceremonias**: Anuncia platos y brindis

#### Protocolo de Mesa

El sistema controla:

- **Precedencia**: Asignación de asientos según rango
- **Servicio**: Orden y presentación de platos
- **Brindis**: Momento y protocolo para brindis formales
- **Conversación**: Temas apropiados y turnos de habla
- **Reputación**: Bonificaciones o penalizaciones según comportamiento

<a name="módulo-de-etiqueta"></a>
### Módulo de Etiqueta

El módulo de etiqueta (Imperial_Court_Etiquette_Module.lsl) gestiona el complejo sistema de normas sociales de la corte.

#### Componentes de Etiqueta

El sistema está compuesto por varios scripts interconectados:

- **Etiquette_Core**: Funcionalidades básicas (Imperial_Court_Etiquette_Core.lsl)
- **Etiquette_Forms**: Formas de tratamiento y saludo (Imperial_Court_Etiquette_Forms.lsl)
- **Etiquette_Precedence**: Reglas de precedencia (Imperial_Court_Etiquette_Precedence.lsl)
- **Etiquette_Customs**: Costumbres específicas rusas (Imperial_Court_Etiquette_Customs.lsl)
- **Etiquette_Connector**: Integración con el HUD principal (Imperial_Court_Etiquette_Connector.lsl)

#### Formas de Tratamiento

El sistema proporciona las formas correctas de dirigirse a cada rango:

1. Selecciona "Etiqueta" en el menú de módulos
2. Elige "Formas de Tratamiento"
3. Selecciona el rango de la persona (o eligela directamente)
4. El sistema mostrará la forma correcta de dirigirse a ella
5. Opciones para copiar el tratamiento al chat

#### Evaluación de Etiqueta

Tu dominio de la etiqueta se evalúa constantemente:

- Uso correcto de formas de tratamiento
- Respeto a la precedencia en eventos
- Vestimenta apropiada para cada ocasión
- Comportamiento acorde a las normas sociales

El nivel de elegancia en el meter refleja tu dominio de la etiqueta.

<a name="módulo-de-religión"></a>
### Módulo de Religión

El módulo de religión (Imperial_Court_Religion_Module.lsl) gestiona aspectos de la fe ortodoxa rusa.

#### Actividades Religiosas

- **Oración**: Individual o colectiva, aumenta piedad
- **Confesión**: Reduce penalizaciones morales
- **Liturgia**: Ceremonias religiosas formales
- **Peregrinación**: Viajes a lugares santos
- **Caridad**: Obras benéficas por motivos religiosos

#### Sistema de Piedad

La piedad se mide de 0-100 y afecta:

- Influencia con facciones religiosas
- Reputación en círculos tradicionales
- Resistencia a ciertos eventos negativos
- Acceso a roles religiosos especiales

#### Calendario Religioso

El sistema incluye:

- Festividades ortodoxas principales
- Días de santos importantes
- Períodos de ayuno
- Celebraciones especiales de la corte

Las actividades religiosas en fechas significativas proporcionan mayores bonificaciones.

<a name="módulo-de-reputación"></a>
### Módulo de Reputación

El módulo de reputación (Imperial_Court_Reputation_Module.lsl) gestiona cómo eres percibido por diferentes grupos sociales.

#### Facetas de Reputación

La reputación se divide en varias facetas:

- **Corte Imperial**: Percepción entre los más cercanos al Tsar
- **Aristocracia**: Estatus entre la nobleza tradicional
- **Militares**: Respeto entre oficiales y personal militar
- **Clero**: Consideración en círculos religiosos
- **Extranjeros**: Impresión entre diplomáticos y visitantes

#### Gestión de Reputación

1. Selecciona "Reputación" en el menú de módulos
2. Revisa tus niveles actuales en cada faceta
3. Identifica áreas para mejorar
4. Realiza acciones específicas que aumenten esa faceta
5. Evita escándalos que puedan dañar tu reputación

#### Escándalos y Rehabilitación

Los escándalos ocurren cuando:

- Rompes gravemente las normas de etiqueta
- Te involucras en intrigas descubiertas
- Ofendes a personajes importantes
- Actúas contra los intereses imperiales

La rehabilitación requiere:
1. Admitir la falta (públicamente o en privado)
2. Realizar acciones compensatorias
3. Obtener el perdón de las partes ofendidas
4. Demostrar lealtad renovada

<a name="módulo-de-romance"></a>
### Módulo de Romance

El módulo de romance (Imperial_Court_Romance_Module.lsl) permite relaciones sentimentales fuera del sistema formal de matrimonio.

#### Tipos de Relaciones

- **Admiración**: Interés romántico unilateral
- **Amistad Cercana**: Relación platónica especial
- **Flirteo**: Interacción romántica casual
- **Affaire**: Relación discreta (posiblemente escandalosa)
- **Amor Verdadero**: Conexión emocional profunda

#### Desarrollo de Relaciones

1. Inicia una interacción romántica con otro jugador
2. Establece el tipo de relación deseada (con consentimiento mutuo)
3. Desarrolla la relación mediante interacciones regulares
4. Gestiona la discreción según el tipo de relación
5. Navega las consecuencias sociales potenciales

#### Restricciones Sociales

El sistema incorpora:

- Diferencias de estatus que afectan las posibilidades románticas
- Consecuencias reputacionales según el tipo de relación
- Escándalos potenciales por relaciones inapropiadas
- Conflictos con compromisos matrimoniales existentes

<a name="módulo-de-relaciones"></a>
### Módulo de Relaciones

El módulo de relaciones (Imperial_Court_Relationships_System.lsl) gestiona conexiones sociales no románticas.

#### Tipos de Relaciones

- **Mentor/Protegido**: Relación de tutoría profesional
- **Patrón/Cliente**: Apoyo a cambio de lealtad
- **Aliados**: Cooperación por intereses comunes
- **Rivales**: Competencia social o profesional
- **Enemigos**: Antagonismo declarado

#### Establecimiento de Relaciones

1. Selecciona "Relaciones" en el menú de módulos
2. Elige "Establecer Relación" con otro jugador
3. Propón el tipo de relación deseada
4. Si es aceptada, la relación se registra en ambos perfiles
5. Desarrolla la relación mediante interacciones apropiadas

#### Beneficios de Relaciones

- **Mentores**: Proporcionan bonificaciones educativas
- **Patrones**: Ofrecen acceso a círculos sociales privilegiados
- **Aliados**: Comparten recursos e información
- **Rivales**: Estimulan mejoras competitivas
- **Enemigos**: Proporcionan objetivos para intrigas

<a name="módulo-de-visitantes-extranjeros"></a>
### Módulo de Visitantes Extranjeros

El módulo de visitantes extranjeros (Imperial_Foreign_Visitors_Module.lsl) gestiona las interacciones con personajes no rusos.

#### Nacionalidades Disponibles

- **Británicos**: Enfoque en diplomacia y comercio
- **Franceses**: Enfoque en cultura y alianzas
- **Alemanes**: Enfoque en relaciones dinásticas
- **Japoneses**: Enfoque en relaciones post-guerra
- **Otras Naciones**: Visitantes de otras cortes europeas

#### HUD Especial para Visitantes

El HUD específico (Imperial_Foreign_Visitor_HUD.lsl) incluye:

- Información cultural específica de su nación
- Preferencias diplomáticas predefinidas
- Barreras idiomáticas simuladas
- Intereses comerciales o políticos específicos

#### Protocolo Diplomático

1. Selecciona "Extranjeros" en el menú de módulos
2. Revisa información sobre protocolos específicos
3. Organiza o participa en eventos diplomáticos
4. Establece relaciones oficiales u oficiosas
5. Desarrolla acuerdos o tratados según tus objetivos

<a name="módulo-de-artes-y-cultura"></a>
### Módulo de Artes y Cultura

El módulo de artes y cultura gestiona actividades artísticas y culturales en la corte.

#### Disciplinas Artísticas

Cada disciplina tiene su propio script especializado:

- **Ballet**: Danza clásica rusa (Imperial_Arts_Ballet_Module.lsl)
- **Literatura**: Poesía y prosa (Imperial_Arts_Literature_Module.lsl)
- **Música**: Composición e interpretación (Imperial_Arts_Music_Module.lsl)
- **Pintura**: Artes visuales (Imperial_Arts_Painting_Module.lsl)

Estas se integran mediante el núcleo cultural (Imperial_Arts_Culture_Core.lsl).

#### Participación Cultural

Como participante:
1. Selecciona "Artes" en el menú de módulos
2. Elige la disciplina de interés
3. Participa como aficionado o profesional
4. Desarrolla tus habilidades con la práctica
5. Organiza o asiste a eventos culturales

Como patrón:
1. Elige "Patrocinio" en el menú de artes
2. Selecciona artistas o proyectos para apoyar
3. Financia eventos o comisiones artísticas
4. Obtén prestigio por tus contribuciones culturales

<a name="módulo-de-gran-duque"></a>
### Módulo de Gran Duque

El módulo de Gran Duque proporciona funcionalidades específicas para miembros de la familia imperial con este rango.

#### Componentes del Módulo

- **Core**: Funcionalidades básicas (Imperial_GD_Core_HUD.lsl)
- **Corte**: Gestión de personal propio (Imperial_GD_Court_Module.lsl)
- **Cultura**: Patrocinio artístico (Imperial_GD_Culture_Module.lsl)
- **Familia**: Relaciones familiares imperiales (Imperial_GD_Family_Module.lsl)
- **Joyería**: Gestión de colecciones personales (Imperial_GD_Jewelry_Module.lsl)
- **Residencias**: Control de propiedades (Imperial_GD_Residences_Module.lsl)
- **Eventos**: Organización de eventos sociales (Imperial_GD_Social_Events_Module.lsl)

#### Privilegios Especiales

- **Residencias Múltiples**: Acceso y control de varios palacios
- **Personal Propio**: Administración de servidumbre personal
- **Presupuesto Imperial**: Asignación de fondos especiales
- **Patronazgo**: Capacidad ampliada de patrocinio
- **Influencia Militar**: Rangos y comandos militares honoríficos

---

<a name="objetos-interactivos"></a>
## 7. Objetos Interactivos

<a name="sable-ceremonial"></a>
### Sable Ceremonial

El Sable Ceremonial (Imperial_Ceremonial_Saber.lsl) es un símbolo de autoridad militar y ceremonial.

#### Funcionalidades

- **Saludo Militar**: Animación especial para saludos formales
- **Nombramiento**: Utilizado en ceremonias de nombramiento militar
- **Duelos de Honor**: Protocolo para duelos formales
- **Reconocimiento**: Identificación automática del portador

#### Comandos y Uso

1. Toca el sable para acceder al menú principal
2. Selecciona la función deseada del menú
3. Para duelos, ambas partes deben aceptar el protocolo
4. En ceremonias, sigue las instrucciones específicas
5. El sable responde de manera especial ante el Tsar y altos mandos militares

<a name="candelabro-reactivo"></a>
### Candelabro Reactivo

El Candelabro Reactivo (Imperial_Candelabra_Reactive.lsl) responde a la presencia de diferentes personajes.

#### Comportamiento Adaptativo

- **Presencia Imperial**: Llamas más brillantes y doradas
- **Nobles Importantes**: Iluminación mejorada
- **Visitantes Extranjeros**: Ligero parpadeo de reconocimiento
- **Intrigas Cercanas**: Oscilación sutil durante conspiraciones
- **Momentos Religiosos**: Llama estable durante oraciones

#### Funcionalidades Prácticas

- **Iluminación**: Control de nivel de luz en el entorno
- **Ambientación**: Efectos visuales según la ocasión
- **Señalización**: Puede usarse para comunicación discreta
- **Ceremonial**: Encendido especial en eventos importantes

<a name="sistema-de-banquete"></a>
### Sistema de Banquete

Los objetos de banquete gestionan eventos gastronómicos formales.

#### Componentes Interactivos

- **Mesa Imperial**: Gestiona la disposición de asientos
- **Platería**: Diferentes servicios según la ocasión
- **Samovar**: Servicio de té con beneficios sociales
- **Alimentos**: Ítems consumibles con efectos de estatus

#### Sistema Gastronómico

1. Los anfitriones configuran el evento a través del HUD
2. Los objetos de mesa responden mostrando asignaciones
3. Los alimentos proporcionan bonificaciones temporales
4. El sistema monitorea el protocolo y comportamiento
5. Al finalizar, se conceden bonificaciones según la formalidad

<a name="íconos-religiosos"></a>
### Íconos Religiosos

Los íconos ortodoxos proporcionan beneficios espirituales y prácticos.

#### Funcionalidades

- **Oración**: Permite oraciones con aumento de piedad
- **Curación**: Proporciona bonificaciones de salud
- **Protección**: Beneficios defensivos temporales
- **Bendición**: Efectos positivos generales
- **Consuelo**: Reducción de efectos negativos emocionales

#### Íconos Especiales para el Tsarevich

Ciertos íconos tienen funcionalidades específicas para el Tsarevich:

- Mayor efecto curativo durante episodios de hemofilia
- Duración prolongada de los efectos de protección
- Notificaciones automáticas al Tsarevich durante crisis

<a name="samovar"></a>
### Samovar

El samovar (parte del Imperial_Food_Item.lsl) es un elemento central de la sociabilidad rusa.

#### Funcionalidades

- **Servicio de Té**: Ritual social con beneficios de sociabilidad
- **Conversación**: Bonificaciones a interacciones sociales cercanas
- **Calidez**: Efectos positivos en ambientes fríos
- **Tradición**: Actividades culturales rusas tradicionales
- **Reconocimiento**: Comportamiento especial ante la familia imperial

#### Uso del Samovar

1. Toca el samovar para activarlo
2. Selecciona el tipo de té a preparar
3. Invita a otros a unirse a la ceremonia del té
4. Participa en conversaciones con bonificaciones sociales
5. Recibe efectos temporales positivos

<a name="otros-objetos"></a>
### Otros Objetos

#### Trono Imperial (Imperial_Throne_Interactive.lsl)
- Accesible solo por el Tsar y la Tsarina
- Proporciona bonificaciones de autoridad
- Permite decretos formales con mayor impacto
- Reacciona negativamente a usuarios no autorizados

#### Iconostasio (Imperial_Iconostasis_Interactive.lsl)
- Centro de actividades religiosas
- Aumenta significativamente la piedad
- Permite ceremonias religiosas formales
- Reacciona a la presencia de clérigos

#### Piano de Concierto (Imperial_Concert_Piano.lsl)
- Permite actuaciones musicales
- Diferentes estilos de música con efectos variados
- Bonificaciones para músicos entrenados
- Efectos de prestigio cultural

#### Escritorio Diplomático (Imperial_Diplomatic_Desk.lsl)
- Facilita la redacción de documentos oficiales
- Bonificaciones en actividades diplomáticas
- Almacenamiento de tratados y acuerdos
- Acceso a información internacional

---

<a name="npcs"></a>
## 8. NPCs

<a name="guardias-imperiales"></a>
### Guardias Imperiales

Los guardias imperiales (Imperial_Guard_NPC_Tsar_Recognition.lsl) proporcionan seguridad y protocolo.

#### Funcionalidades

- **Reconocimiento del Tsar**: Identificación automática del monarca
- **Saludos Formales**: Diferentes saludos según rango del visitante
- **Control de Acceso**: Restricción de áreas según autorización
- **Alerta de Seguridad**: Respuesta a amenazas potenciales
- **Escolta**: Acompañamiento protocolario para dignatarios

#### Interacción con Guardias

1. Acércate al guardia para ser reconocido
2. Presenta credenciales o identificación si se solicita
3. Solicita acceso o información si es necesario
4. Para la familia imperial, los guardias responden automáticamente
5. Oficiales militares reciben saludos según su rango

<a name="sirvientes-de-la-corte"></a>
### Sirvientes de la Corte

Los sirvientes (Imperial_Servant_NPC_Tsar_Recognition.lsl) facilitan la vida cortesana.

#### Funcionalidades

- **Servicio Personalizado**: Reconocimiento de preferencias
- **Mensajería**: Transmisión de mensajes entre jugadores
- **Asistencia**: Ayuda con tareas prácticas y protocolo
- **Información**: Conocimiento sobre eventos y personajes
- **Discreción**: Gestión de asuntos privados

#### Tipos de Sirvientes

- **Mayordomos**: Administración doméstica y protocolo
- **Ayudas de Cámara**: Asistencia personal
- **Doncellas**: Servicio para damas de la corte
- **Lacayos**: Tareas generales y mensajería
- **Cocineros**: Preparación de alimentos especiales

<a name="baba-yaga"></a>
### Baba Yaga

Baba Yaga (Imperial_Baba_Yaga_NPC.lsl) representa elementos folclóricos rusos.

#### Funcionalidades

- **Profecías**: Predicciones con efectos en el juego
- **Pociones**: Brebajes con efectos temporales
- **Sabiduría Popular**: Consejos y conocimiento tradicional
- **Pruebas**: Desafíos para ganar su favor
- **Maldiciones**: Efectos negativos para quienes la ofenden

#### Interacción con Baba Yaga

1. Aproximarse con respeto (inclinación o reverencia)
2. Ofrecer un regalo (alimento o objeto simbólico)
3. Solicitar su asistencia específica
4. Completar la tarea o prueba asignada
5. Recibir la recompensa o castigo según corresponda

<a name="fantasma-de-ekaterina"></a>
### Fantasma de Ekaterina

El fantasma de Catalina la Grande (Imperial_Ekaterina_Phantom_NPC.lsl) aparece en ocasiones especiales.

#### Apariciones

- Durante crisis políticas importantes
- En aniversarios históricos significativos
- Cuando el trono está en peligro
- Al invocarla mediante ritual específico

#### Funcionalidades

- **Consejo Imperial**: Sabiduría política para el Tsar
- **Advertencias**: Alertas sobre peligros para la dinastía
- **Historia Viva**: Relatos de eventos históricos reales
- **Bendición Imperial**: Bonificaciones para descendientes Romanov
- **Juicio Histórico**: Evaluación de decisiones políticas actuales

---

<a name="sistema-de-combate"></a>
## 9. Sistema de Combate

El sistema de combate (Imperial_Combat_System.lsl) simula enfrentamientos físicos, desde duelos formales hasta altercados.

### Tipos de Combate

- **Duelos Formales**: Enfrentamientos ritualizados por honor
- **Ejercicios Militares**: Prácticas y demostraciones
- **Defensa Personal**: Protección ante amenazas
- **Revolución**: Enfrentamientos políticos violentos (eventos especiales)

### Mecánica de Duelos

1. **Desafío**: Un participante desafía formalmente a otro
2. **Aceptación**: El desafiado debe aceptar o rechazar (con consecuencias)
3. **Padrinos**: Cada parte designa un testigo
4. **Elección de Armas**: Sables, pistolas o manos desnudas
5. **Resolución**: Sistema automatizado considerando habilidades y azar

### Habilidades de Combate

- **Esgrima**: Habilidad con sables y espadas
- **Puntería**: Precisión con armas de fuego
- **Combate Cuerpo a Cuerpo**: Lucha sin armas
- **Estrategia**: Planificación y anticipación
- **Resistencia**: Capacidad para soportar daño

### Sistema de Daño y Recuperación

- El daño se aplica a la estadística de Salud
- Las heridas pueden tener efectos persistentes
- La recuperación requiere tiempo y posiblemente atención médica
- La muerte ocurre al llegar a 0 de salud (con opción de revivir después de una semana)

---

<a name="registro-y-resolución-de-problemas"></a>
## 10. Registro y Resolución de Problemas

### Problemas Comunes

#### Desincronización HUD-Meter
**Síntomas**: El meter no muestra las estadísticas actualizadas del HUD
**Solución**: 
1. Desactivar y reactivar el HUD (desatacher y volver a atacher)
2. Usar comando `/icr reset` para reiniciar comunicación
3. Verificar que estén en el mismo canal de comunicación

#### Modo OOC No Funciona
**Síntomas**: El estado OOC no se activa correctamente
**Solución**:
1. Usar comando `/icr ooc` dos veces (desactivar y reactivar)
2. Verificar que no haya eventos críticos activos
3. Reiniciar el HUD si persiste el problema

#### Episodios de Hemofilia Continuos
**Síntomas**: Tsarevich sufre episodios sin recuperación
**Solución**:
1. Buscar atención de Rasputin o médico
2. Usar íconos religiosos para alivio temporal
3. Verificar que no haya daño físico adicional (caídas recientes)

#### Módulos No Disponibles
**Síntomas**: Ciertos módulos aparecen bloqueados
**Solución**:
1. Verificar que cumples los requisitos de ese módulo
2. Solicitar acceso a administradores si corresponde
3. Comprobar que el módulo está instalado correctamente

### Contacto para Soporte

Si experimentas problemas no listados aquí:

1. Contacta a los administradores del roleplay en el juego
2. Envía un mensaje a support@imperialrussianroleplay.sl
3. Consulta el foro oficial para soluciones comunitarias

---

<a name="créditos-y-contacto"></a>
## 11. Créditos y Contacto

### Equipo de Desarrollo

- **Dirección Histórica**: [Nombre del Consultor Histórico]
- **Programación Principal**: [Programador Principal]
- **Diseño del Sistema**: [Diseñador del Sistema]
- **Pruebas y Balance**: [Equipo de Probadores]

### Recursos Históricos

Este sistema ha sido desarrollado con consulta a las siguientes fuentes:

- "La Corte del Último Zar" por Greg King
- "Nicolás y Alejandra" por Robert K. Massie
- Archivos del Palacio de Invierno, San Petersburgo
- Memorias de la Condesa Sophie Buxhoeveden
- Diarios del Barón Fredericks

### Contacto

Para información, sugerencias o reportes de problemas:

- **Email**: imperialcourt@slroleplay.com
- **Discord**: Imperial Court Roleplay #support
- **Inworld**: Visite el Centro de Ayuda en el Palacio de Invierno

---

*Este manual está sujeto a actualizaciones. Última revisión: Abril 2025*