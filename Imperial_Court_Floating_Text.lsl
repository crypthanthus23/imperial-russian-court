// Imperial Court Floating Text - Display Script
// Este script muestra información del personaje como texto flotante visible a otros jugadores
// Propietario: Zar Nicolai II Romanov

// Configuración
integer STATS_CHANNEL = -987654321; // Canal para comunicación con el HUD
float TEXT_UPDATE_RATE = 0.5; // Velocidad de actualización del texto (en segundos)
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Color ámbar/dorado para el texto
float TEXT_ALPHA = 1.0; // Opacidad del texto (1.0 = totalmente opaco)

// Variables de información del personaje
string playerFirstName = "";
string playerLastName = "";
string familyName = "";
string rankName = "";
string russianTitle = "";
string courtPosition = "";
integer playerGender = 0; // 0=masculino, 1=femenino

// Variables de estadísticas
integer health = 100;
integer charm = 10;
integer influence = 10;
integer imperialFavor = 10; // Popularidad
integer rubles = 100;
integer experience = 0;
integer faith = 10;
string wealthCategory = "";

// Flags
integer textVisible = TRUE;
integer isLinked = FALSE;
key hudOwnerID = NULL_KEY;
integer isOOCMode = FALSE;

// Función para actualizar y mostrar el texto flotante
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    // Si estamos en modo OOC, mostrar un texto simplificado
    if (isOOCMode) {
        llSetText("[ OOC - Fuera de Personaje ]", <0.7, 0.7, 0.7>, 0.7);
        return;
    }
    
    string displayText = "";
    
    // Añadir encabezado con nombre del jugador y rango si está disponible
    if (playerFirstName != "" && playerLastName != "") {
        displayText += playerFirstName + " " + playerLastName + "\n";
        
        if (rankName != "") {
            displayText += rankName;
            
            if (russianTitle != "") {
                displayText += " (" + russianTitle + ")";
            }
            
            displayText += "\n";
        }
        
        // Añadir posición en la corte si existe
        if (courtPosition != "") {
            displayText += courtPosition + "\n";
        }
        
        // Añadir línea horizontal
        displayText += "---------------------\n";
        
        // Añadir identificador de género (opcional)
        if (playerGender == 0) {
            displayText += "♂ ";
        } else {
            displayText += "♀ ";
        }
        
        // Añadir estadísticas principales
        displayText += "Salud: " + (string)health + " • ";
        displayText += "Encanto: " + (string)charm + "\n";
        
        // Añadir influencia y favor imperial
        displayText += "Influencia: " + (string)influence + " • ";
        displayText += "Popularidad: " + (string)imperialFavor + "\n";
        
        // Añadir información de riqueza con categoría
        displayText += "Rublos: " + (string)rubles + " • ";
        displayText += "Estado: " + wealthCategory + "\n";
        
        // Añadir estadística de fe
        displayText += "Fe: " + (string)faith + "\n";
        
        // Añadir experiencia opcionalmente
        displayText += "Experiencia: " + (string)experience;
    }
    else {
        displayText = "Medidor de Estadísticas de la Corte Imperial\n";
        displayText += "(Conectar al HUD para mostrar datos)";
    }
    
    // Mostrar el texto
    llSetText(displayText, TEXT_COLOR, TEXT_ALPHA);
}

// Función para solicitar actualización de estadísticas desde el HUD
requestStatsUpdate() {
    if (isLinked && hudOwnerID != NULL_KEY) {
        // Enviar una solicitud en el canal de estadísticas
        llRegionSay(STATS_CHANNEL, "REQUEST_STATS_UPDATE");
    }
}

// Función para procesar los datos de estadísticas recibidos
processStatsData(string data) {
    // Mensaje de depuración en modo verboso
    llOwnerSay("Procesando datos: " + data);
    
    // Dividir la cadena de datos por el separador
    list dataParts = llParseString2List(data, ["||"], []);
    
    integer numParts = llGetListLength(dataParts);
    llOwnerSay("Número de partes recibidas: " + (string)numParts);
    
    if (numParts < 10) {
        llOwnerSay("Error: Datos de estadísticas incompletos recibidos. Partes: " + (string)numParts);
        return;
    }
    
    // Comprobar si estamos en modo OOC
    if (llList2String(dataParts, 0) == "OOC" && llList2String(dataParts, 1) == "OOC") {
        llOwnerSay("Modo OOC detectado");
        isOOCMode = TRUE;
        updateFloatingText();
        return;
    } else {
        isOOCMode = FALSE;
    }
    
    // Extraer datos de la lista
    playerFirstName = llList2String(dataParts, 0);
    playerLastName = llList2String(dataParts, 1);
    rankName = llList2String(dataParts, 2);    // Clase social
    russianTitle = llList2String(dataParts, 3); // Familia
    courtPosition = llList2String(dataParts, 4); // Profesión
    health = (integer)llList2String(dataParts, 5);
    charm = (integer)llList2String(dataParts, 6);
    influence = (integer)llList2String(dataParts, 7);
    experience = (integer)llList2String(dataParts, 8);
    rubles = (integer)llList2String(dataParts, 9);
    imperialFavor = (integer)llList2String(dataParts, 10);
    wealthCategory = llList2String(dataParts, 11);
    
    // Comprobar si se incluyen datos de género
    if (numParts >= 13) {
        playerGender = (integer)llList2String(dataParts, 12);
    }
    
    // Comprobar si se incluyen datos de fe
    if (numParts >= 14) {
        faith = (integer)llList2String(dataParts, 13);
    }
    
    llOwnerSay("Datos del personaje: " + playerFirstName + " " + playerLastName);
    llOwnerSay("Estadísticas: Salud=" + (string)health + ", Influencia=" + (string)influence);
    
    // Actualizar el texto flotante con los nuevos datos
    updateFloatingText();
}

default {
    state_entry() {
        // Inicializar el medidor con más información de depuración
        llOwnerSay("¡MEDIDOR INICIADO! Imperial Russian Court Stats Meter");
        llSetText("Medidor de Estadísticas de la Corte Imperial\n(Conectar al HUD para mostrar datos)", TEXT_COLOR, TEXT_ALPHA);
        
        // Escuchar comunicaciones en el canal de estadísticas
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        llOwnerSay("Escuchando en canal de estadísticas: " + (string)STATS_CHANNEL);
        
        // Mostrar información de configuración
        llOwnerSay("ID del propietario del medidor: " + (string)llGetOwner());
        
        // Iniciar un temporizador para actualizaciones periódicas
        llSetTimerEvent(TEXT_UPDATE_RATE);
        
        // Mensaje final
        llOwnerSay("--- MEDIDOR LISTO PARA CONEXIÓN ---");
    }
    
    touch_start(integer total_number) {
        // Alternar la visibilidad del texto al tocar
        textVisible = !textVisible;
        updateFloatingText();
        
        string visibilityStatus;
        if (textVisible) {
            visibilityStatus = "visible";
        } else {
            visibilityStatus = "oculta";
        }
        llOwnerSay("Visualización de estadísticas " + visibilityStatus);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Mostrar información de depuración para cualquier mensaje recibido
        llOwnerSay("Mensaje recibido en canal " + (string)channel + ": " + message);
        
        if (channel == STATS_CHANNEL) {
            // Comprobar solicitud de conexión
            if (llSubStringIndex(message, "CONNECT_METER:") == 0) {
                // Extraer ID del propietario del mensaje
                string ownerIDString = llGetSubString(message, 14, -1);
                key ownerKey = (key)ownerIDString;
                
                llOwnerSay("Solicitud de conexión recibida de ID: " + ownerIDString);
                llOwnerSay("Mi ID: " + (string)llGetOwner());
                
                // Si este medidor pertenece al solicitante, establecer conexión
                if (ownerKey == llGetOwner()) {
                    hudOwnerID = id;
                    isLinked = TRUE;
                    llOwnerSay("Conectado al HUD de la Corte Imperial.");
                    
                    // Enviar confirmación al HUD
                    llRegionSay(STATS_CHANNEL, "HUD_CONNECTED");
                    llOwnerSay("Enviada confirmación de conexión al HUD");
                    
                    // Solicitar estadísticas iniciales
                    requestStatsUpdate();
                } else {
                    llOwnerSay("ADVERTENCIA: ID de propietario no coincide, se ignora la solicitud");
                }
            }
            // Comprobar datos de estadísticas
            else if (llSubStringIndex(message, "STATS_DATA:") == 0) {
                // Extraer parte de datos del mensaje
                string data = llGetSubString(message, 11, -1);
                
                llOwnerSay("Datos de estadísticas recibidos");
                
                // Procesar los datos de estadísticas
                processStatsData(data);
                
                // Almacenar el ID del propietario del HUD para comunicación futura
                hudOwnerID = id;
                isLinked = TRUE;
            }
            // Comprobar confirmación de conexión
            else if (message == "HUD_CONNECTED") {
                hudOwnerID = id;
                isLinked = TRUE;
                llOwnerSay("HUD de la Corte Imperial conectado correctamente.");
                
                requestStatsUpdate();
            }
            // Comprobar mensaje de desconexión
            else if (message == "HUD_DISCONNECTED" && id == hudOwnerID) {
                hudOwnerID = NULL_KEY;
                isLinked = FALSE;
                llOwnerSay("HUD de la Corte Imperial desconectado.");
            } else {
                llOwnerSay("Mensaje desconocido en el canal de estadísticas: " + message);
            }
        } else {
            llOwnerSay("Mensaje recibido en canal desconocido: " + (string)channel);
        }
    }
    
    timer() {
        // Si estamos vinculados a un HUD, solicitar actualizaciones periódicamente
        if (isLinked && hudOwnerID != NULL_KEY) {
            requestStatsUpdate();
        }
    }
}