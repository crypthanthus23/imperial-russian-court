// Imperial Court HUD - Versión para depurar problemas de toque
// Esta versión se enfoca específicamente en la detección correcta de toques

// Configuración
integer DEBUG_CHANNEL = 1; // Canal para depuración
vector TEXT_COLOR = <1.0, 0.8, 0.2>; // Color dorado para el texto

// Función para mostrar depuración
showDebug(string message) {
    // Mostrar texto sobre el objeto
    llSetText("DEBUG: " + message, TEXT_COLOR, 1.0);
    // También enviar al chat
    llOwnerSay("DEBUG: " + message);
}

// Estado predeterminado
default {
    // Al iniciar script
    state_entry() {
        // Mostrar mensaje de inicio
        llOwnerSay("==============================");
        llOwnerSay("    HUD IMPERIAL - PRUEBA DE TOQUE    ");
        llOwnerSay("==============================");
        
        // Habilitar escucha para comandos
        llListen(0, "", llGetOwner(), "");
        llListen(DEBUG_CHANNEL, "", llGetOwner(), "");
        
        // Instrucciones
        llOwnerSay("Este HUD es para diagnosticar problemas de toque:");
        llOwnerSay("1. TOQUE para ver el menú");
        llOwnerSay("2. Escriba '/1debug' para activar mensajes");
        llOwnerSay("3. Escriba '/1reset' para reiniciar script");
        
        // Mostrar texto para recordar que el HUD está activo
        llSetText("HUD IMPERIAL\nTOQUE AQUÍ", TEXT_COLOR, 1.0);
        
        // Para evitar problemas de inicialización, ir a estado de espera
        llSleep(1.0);
        state touch_ready;
    }
}

// Estado especial para manejo de toques
state touch_ready {
    state_entry() {
        showDebug("Estado ready activado - listo para recibir toques");
    }
    
    // Al tocar objeto
    touch_start(integer total_number) {
        // Registrar qué avatar tocó
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Mostrar información
        showDebug("¡TOQUE DETECTADO! por " + toucherName);
        
        // Si es el propietario, mostrar menú
        if (toucherKey == llGetOwner()) {
            llOwnerSay("*** MENÚ PRINCIPAL ***");
            
            // Mostrar un menú de diálogo básico
            llDialog(llGetOwner(), 
                "HUD Imperial - Menú", 
                ["Información", "Conectar", "Reiniciar", "Salir"], 
                DEBUG_CHANNEL);
        }
    }
    
    // Al soltar después de tocar
    touch_end(integer num) {
        showDebug("Toque liberado");
    }
    
    // Al escuchar mensajes
    listen(integer channel, string name, key id, string message) {
        // Solo procesar mensajes del propietario
        if (id == llGetOwner()) {
            // Comandos en chat público
            if (channel == 0) {
                if (message == "/1debug") {
                    showDebug("Comando de depuración activado");
                }
                else if (message == "/1reset") {
                    llOwnerSay("Reiniciando script...");
                    llResetScript();
                }
            }
            // Respuestas de menú
            else if (channel == DEBUG_CHANNEL) {
                // Procesar respuestas del menú de diálogo
                llOwnerSay("Opción seleccionada: " + message);
                
                if (message == "Información") {
                    llOwnerSay("HUD Imperial - Versión de depuración");
                    llOwnerSay("Este es un script de diagnóstico para resolver problemas de detección de toques.");
                }
                else if (message == "Reiniciar") {
                    llOwnerSay("Reiniciando script...");
                    llResetScript();
                }
                else if (message == "Salir") {
                    llOwnerSay("Cerrando menú");
                }
            }
        }
    }
    
    // Otros eventos para depuración
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            showDebug("Cambio de propietario detectado");
        }
        if (change & CHANGED_INVENTORY) {
            showDebug("Cambio de inventario detectado");
        }
        if (change & CHANGED_LINK) {
            showDebug("Cambio de enlace detectado");
        }
    }
}