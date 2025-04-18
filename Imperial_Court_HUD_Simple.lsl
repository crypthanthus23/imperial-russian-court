// Imperial Court HUD - Versión Simplicada
// Esta versión solo incluye lo básico para verificar la comunicación

// Configuración
integer STATS_CHANNEL = -987654321; // Canal para comunicación con el medidor flotante
integer MENU_CHANNEL; // Canal para menús

// Variables de estado
key meterID = NULL_KEY;
integer isMeterConnected = FALSE;

// Función para conectar con un medidor de estadísticas flotante
connectMeter() {
    llOwnerSay("Buscando medidor de estadísticas...");
    llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + (string)llGetOwner());
}

// Función para enviar datos de prueba al medidor
sendTestData() {
    if (isMeterConnected) {
        llOwnerSay("Enviando datos de prueba al medidor...");
        string testData = "STATS_DATA:Nombre||Apellido||Noble||Familia||Posición||100||75||50||25||1000||80||Rico||0||50";
        llRegionSay(STATS_CHANNEL, testData);
    } else {
        llOwnerSay("Error: El medidor no está conectado. Use 'Conectar' primero.");
    }
}

default {
    state_entry() {
        llOwnerSay("===================================");
        llOwnerSay("     IMPERIAL COURT HUD SIMPLE     ");
        llOwnerSay("===================================");
        
        // Generar un canal de menú basado en el ID del avatar
        string ownerID = (string)llGetOwner();
        MENU_CHANNEL = ((integer)("0x" + llGetSubString(ownerID, 0, 8))) & 0x7FFFFFFF;
        
        // Configurar escucha para menús y comunicación con medidor
        llListen(MENU_CHANNEL, "", llGetOwner(), "");
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        llListen(0, "", llGetOwner(), ""); // Escuchar al canal público para comandos
        
        llOwnerSay("Canal de menú: " + (string)MENU_CHANNEL);
        llOwnerSay("Canal de estadísticas: " + (string)STATS_CHANNEL);
        
        llOwnerSay("TOQUE ESTE HUD para mostrar el menú principal");
        llOwnerSay("O USE ESTOS COMANDOS DE CHAT:");
        llOwnerSay("/1menu - Mostrar menú principal");
        llOwnerSay("/1conectar - Conectar con el medidor");
        llOwnerSay("/1datos - Enviar datos al medidor");
    }
    
    touch_start(integer total_number) {
        llOwnerSay("*** HUD TOCADO - MOSTRANDO MENÚ ***");
        
        // Mostrar un menú sencillo
        llDialog(llGetOwner(), 
            "HUD Imperial - Menú Simple", 
            ["Info", "Conectar", "Enviar Datos", "Salir"], 
            MENU_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        llOwnerSay("Mensaje recibido en canal " + (string)channel + ": " + message);
        
        // Procesar opciones del menú
        if (channel == MENU_CHANNEL && id == llGetOwner()) {
            if (message == "Info") {
                llOwnerSay("HUD Imperial - Versión simple de prueba");
                llOwnerSay("Este HUD es una versión simplificada para probar la comunicación con el medidor");
            }
            else if (message == "Conectar") {
                connectMeter();
            }
            else if (message == "Enviar Datos") {
                sendTestData();
            }
            else if (message == "Salir") {
                llOwnerSay("Menú cerrado");
            }
        }
        // Procesar mensajes del canal de estadísticas
        else if (channel == STATS_CHANNEL) {
            if (message == "HUD_CONNECTED") {
                meterID = id;
                isMeterConnected = TRUE;
                llOwnerSay("¡CONEXIÓN ESTABLECIDA CON EL MEDIDOR!");
                
                // Enviar datos de prueba automáticamente
                sendTestData();
            }
            else if (message == "REQUEST_STATS_UPDATE") {
                llOwnerSay("El medidor solicita actualización de datos");
                sendTestData();
            }
        }
    }
}