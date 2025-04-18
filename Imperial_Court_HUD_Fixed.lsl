// Imperial Court HUD - Fixed Touch Version
// Este script tiene una versión simplificada para garantizar que responda a los toques
// Usa estado único y minimiza variables para evitar problemas de memoria

// Configuración básica
string VERSION = "1.0";
integer DEBUG = TRUE;
integer DIALOG_CHANNEL;
integer LISTEN_HANDLE;

// Función para generar un canal aleatorio para diálogos
integer getRandomChannel() {
    return -1 * (integer)llFrand(16777216) - 1000; // Genera un canal negativo aleatorio
}

// Función para mostrar debug si está activado
sayDebug(string message) {
    if (DEBUG) {
        llOwnerSay("DEBUG: " + message);
    }
}

// Estado por defecto - Todo mantenido en un solo estado para evitar problemas
default {
    state_entry() {
        // Mensajes de bienvenida
        llOwnerSay("============================================");
        llOwnerSay("Imperial Court HUD v" + VERSION + " - Iniciando");
        llOwnerSay("TOQUE este objeto para ver el menú de opciones");
        llOwnerSay("============================================");
        
        // Asignar un canal aleatorio para diálogos
        DIALOG_CHANNEL = getRandomChannel();
        
        // Iniciar escucha en este canal
        LISTEN_HANDLE = llListen(DIALOG_CHANNEL, "", NULL_KEY, "");
        
        // Establecer texto flotante informativo
        llSetText("Imperial Court HUD\nTOQUE PARA OPCIONES", <1.0, 0.8, 0.2>, 1.0);
        
        // Confirmar inicialización completa
        sayDebug("Inicialización completa. Canal de diálogos: " + (string)DIALOG_CHANNEL);
    }
    
    // Evento de toque - VERSIÓN SIMPLIFICADA PARA ASEGURAR FUNCIONALIDAD
    touch_start(integer num_detected) {
        // Identificar quién tocó
        key toucher = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Mensaje de confirmación
        llOwnerSay("HUD tocado por: " + toucherName);
        sayDebug("Evento touch_start activado");
        
        // Mostrar menú básico - Mantener simple para evitar problemas
        list buttons = ["Refrescar", "Opciones", "Conectar", "Salir"];
        
        // Enviar el diálogo DIRECTAMENTE usando el canal aleatorio
        llDialog(toucher, 
                "Seleccione una opción:\n\n" +
                "• Refrescar: Actualiza los datos del jugador\n" +
                "• Opciones: Muestra opciones adicionales\n" +
                "• Conectar: Busca medidores para conectar\n" +
                "• Salir: Cierra este menú", 
                buttons, DIALOG_CHANNEL);
        
        // Cambiar color temporalmente para confirmar visualmente la detección del toque
        llSetColor(<0.0, 1.0, 0.0>, ALL_SIDES); // Verde = toque detectado
        llSetTimerEvent(0.5); // Restaurar color original después de medio segundo
    }
    
    // Escuchar respuestas del diálogo
    listen(integer channel, string name, key id, string message) {
        if (channel == DIALOG_CHANNEL) {
            // Solo procesar si es el propietario
            if (id == llGetOwner()) {
                sayDebug("Opción seleccionada: " + message);
                
                // Procesar la opción seleccionada
                if (message == "Refrescar") {
                    llOwnerSay("Actualizando datos del jugador...");
                    // Aquí iría la lógica para refrescar datos
                }
                else if (message == "Opciones") {
                    // Mostrar menú de opciones secundario
                    list options = ["Debug ON/OFF", "Idioma ES/EN", "Volver"];
                    llDialog(id, "Opciones avanzadas:", options, DIALOG_CHANNEL);
                }
                else if (message == "Conectar") {
                    llOwnerSay("Buscando medidores cercanos...");
                    // Aquí iría la lógica para buscar medidores
                }
                else if (message == "Debug ON/OFF") {
                    DEBUG = !DEBUG;
                    llOwnerSay("Modo debug: " + (DEBUG ? "ACTIVADO" : "DESACTIVADO"));
                }
                else if (message == "Idioma ES/EN") {
                    llOwnerSay("Cambiando idioma...");
                    // Aquí iría la lógica para cambiar idioma
                }
            }
        }
    }
    
    // Timer para efectos visuales
    timer() {
        // Restaurar color original
        llSetColor(<1.0, 1.0, 1.0>, ALL_SIDES);
        llSetTimerEvent(0.0); // Detener timer
    }
    
    // Evento cuando el script es cambiado o reiniciado
    on_rez(integer start_param) {
        llResetScript();
    }
    
    // Evento cuando cambia algo en el objeto
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            llResetScript();
        }
    }
}