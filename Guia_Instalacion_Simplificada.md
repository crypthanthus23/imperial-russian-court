# Guía de Instalación Simplificada para Second Life
## Instrucciones para usuarios sin conocimientos de programación

### Paso 1: Descargar los archivos
1. Descarga el archivo ZIP con todos los scripts: [Imperial_Court_Complete_System.zip](https://79c2ae41-1999-4095-9d63-41091a860a04-00-3vays7p8hu12k.spock.replit.dev/Imperial_Court_Complete_System.zip)
2. Extrae el ZIP en tu computadora

### Paso 2: Preparar objetos en Second Life
1. Entra a Second Life con tu avatar
2. Crea objetos simples (como esferas o cubos) para cada componente:
   - Un objeto para el HUD principal
   - Un objeto para el Meter (que mostrará las estadísticas)
   - Objetos para cada elemento interactivo (candelabro, sable, etc.)
   - Objetos para cada NPC
3. Nombra cada objeto de forma clara para no confundirte

### Paso 3: Colocar los scripts en sus objetos
1. Abre el inventario de Second Life
2. Arrastra cada archivo .lsl desde tu computadora al inventario
3. Selecciona cada objeto que creaste en Second Life
4. Haz clic derecho en el script correspondiente en tu inventario
5. Selecciona "Copiar al contenido del objeto"

**Nota:** Cada script debe ir en su objeto correspondiente:
- "Imperial_Russian_Court_Core_HUD.lsl" va en el objeto HUD principal
- "Imperial_Court_Meter_Updated.lsl" va en el objeto Meter
- "Imperial_Tsar_HUD.lsl" va en el HUD especial para el Tsar
- Y así sucesivamente...

### Paso 4: Adjuntar los HUDs a los avatares
1. Para usar un HUD, haz clic derecho en el objeto y selecciona "Adjuntar"
2. Selecciona "HUD - Arriba derecha" (o la posición que prefieras)
3. El HUD se adjuntará a tu pantalla

### Paso 5: Usar el sistema (instrucciones básicas)
1. Toca el HUD para abrir el menú principal
2. Selecciona las opciones según lo que quieras hacer
3. Para interactuar con objetos o NPCs, simplemente acércate y tócalos

### Para crear un objeto dispensador de HUDs:
1. Crea un objeto simple en Second Life
2. Coloca copias de todos los HUDs en su contenido
3. Añade un script básico que entregue los HUDs cuando alguien lo toque
   (Este script ya está incluido: "Imperial_HUD_Giver.lsl")

### Resolución de problemas comunes:
- Si un HUD no responde: Quítalo y vuélvelo a adjuntar
- Si dos componentes no se comunican: Asegúrate de que estén en la misma región
- Si aparecen errores de script: Consulta con alguien familiarizado con LSL para ayudarte

### Recursos adicionales:
- Incluye el "Manual_Completo.txt" como una notecard en el objeto dispensador
- Añade una notecard con instrucciones básicas para los jugadores

---

**Recuerda:** Si necesitas ayuda con aspectos técnicos, considera buscar a alguien con experiencia en scripts de Second Life para que te ayude con la instalación inicial.