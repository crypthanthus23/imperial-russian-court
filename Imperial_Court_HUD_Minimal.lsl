// Imperial Court - HUD Minimalista de Prueba
// Versión ultra-simplificada para depuración

integer MENU_CHANNEL = 12345;
integer STATS_CHANNEL = -987654321;

// Variable para seguir si el HUD ya está conectado a un medidor
integer isConnected = FALSE;

default {
    state_entry() {
        llOwnerSay("INICIANDO HUD MINIMALISTA DE PRUEBA");
        
        // Configurar escucha para menú y estadísticas
        llListen(MENU_CHANNEL, "", llGetOwner(), "");
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        
        // También escuchar canal público para comandos alternativos
        llListen(0, "", llGetOwner(), "");
        
        llOwnerSay("***************************");
        llOwnerSay("COMANDOS DISPONIBLES:");
        llOwnerSay("/1menu - Muestra el menú principal");
        llOwnerSay("/1conectar - Conecta directamente con el medidor");
        llOwnerSay("/1test - Envía datos de prueba");
        llOwnerSay("***************************");
        llOwnerSay("TOQUE EL HUD PARA USAR EL MENÚ");
    }
    
    // Al tocar el HUD, mostrar el menú principal
    touch_start(integer total_number) {
        llOwnerSay("HUD TOCADO - MOSTRANDO MENÚ DE PRUEBA");
        
        llDialog(llGetOwner(), 
            "HUD Imperial - Menú de Prueba\n\nSeleccione una opción:", 
            ["Info", "Conectar", "Test", "Salir"], 
            MENU_CHANNEL);
    }
    
    // Escuchar eventos de chat y respuestas de menú
    listen(integer channel, string name, key id, string message) {
        llOwnerSay("ESCUCHANDO EN CANAL " + (string)channel + ": " + message);
        
        // Responder a comandos de chat en canal 0 (chat público)
        if (channel == 0 && id == llGetOwner()) {
            // Verificar comandos
            if (message == "/1menu") {
                llOwnerSay("COMANDO MENU DETECTADO");
                
                llDialog(llGetOwner(), 
                    "HUD Imperial - Menú Prueba", 
                    ["Info", "Conectar", "Test", "Salir"], 
                    MENU_CHANNEL);
            }
            else if (message == "/1conectar") {
                llOwnerSay("COMANDO CONECTAR DETECTADO");
                llOwnerSay("INTENTANDO CONECTAR CON MEDIDOR");
                
                // Enviar mensaje de conexión
                llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + (string)llGetOwner());
            }
            else if (message == "/1test") {
                llOwnerSay("COMANDO TEST DETECTADO");
                llOwnerSay("ENVIANDO DATOS DE PRUEBA AL MEDIDOR");
                
                // Enviar datos de prueba directamente
                string testData = "STATS_DATA:Nombre||Apellido||Noble||Familia||Posición||100||75||50||25||1000||80||Rico||0||50";
                llRegionSay(STATS_CHANNEL, testData);
            }
        }
        // Responder al menú en canal específico
        else if (channel == MENU_CHANNEL && id == llGetOwner()) {
            if (message == "Info") {
                llOwnerSay("OPCIÓN INFO SELECCIONADA");
                
                llDialog(llGetOwner(), 
                    "Información básica:\nHUD de prueba\nVer: 1.0", 
                    ["Volver"], 
                    MENU_CHANNEL);
            }
            else if (message == "Conectar") {
                llOwnerSay("INTENTANDO CONECTAR CON MEDIDOR");
                
                // Enviar mensaje de conexión
                llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + (string)llGetOwner());
            }
            else if (message == "Test") {
                llOwnerSay("ENVIANDO DATOS DE PRUEBA AL MEDIDOR");
                
                // Enviar datos de prueba directamente
                string testData = "STATS_DATA:Nombre||Apellido||Noble||Familia||Posición||100||75||50||25||1000||80||Rico||0||50";
                llRegionSay(STATS_CHANNEL, testData);
            }
            else if (message == "Volver" || message == "Salir") {
                llOwnerSay("CERRANDO MENÚ");
            }
        }
        // Responder a mensajes del canal de estadísticas
        else if (channel == STATS_CHANNEL) {
            llOwnerSay("MENSAJE DEL CANAL DE ESTADÍSTICAS: " + message);
            
            if (message == "HUD_CONNECTED") {
                llOwnerSay("¡CONEXIÓN CON MEDIDOR ESTABLECIDA!");
                isConnected = TRUE;
                
                // Enviar algunos datos de prueba
                string testData = "STATS_DATA:Nombre||Apellido||Noble||Familia||Posición||100||75||50||25||1000||80||Rico||0||50";
                llRegionSay(STATS_CHANNEL, testData);
            }
            else if (message == "REQUEST_STATS_UPDATE") {
                llOwnerSay("SOLICITUD DE ACTUALIZACIÓN RECIBIDA");
                
                // Enviar datos actualizados
                string testData = "STATS_DATA:Nombre||Apellido||Noble||Familia||Posición||100||75||50||25||1000||80||Rico||0||50";
                llRegionSay(STATS_CHANNEL, testData);
            }
        }
    }
}