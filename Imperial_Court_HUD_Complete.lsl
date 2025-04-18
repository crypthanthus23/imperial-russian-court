// Imperial Court - HUD Completo
// Versión con funcionalidad básica y depuración mejorada
// Desarrollado para Imperial Russian Court RP - 1905

// ========== CONFIGURACIÓN DE CANALES ==========
integer MENU_CHANNEL = 12345;                // Canal fijo para menús
integer STATS_CHANNEL = -987654321;          // Canal para comunicación con medidor
integer DEBUG_MODE = TRUE;                   // Activar mensajes de depuración

// ========== VARIABLES DE ESTADO ==========
key meterID = NULL_KEY;                       // ID del medidor conectado
integer isConnected = FALSE;                  // Estado de conexión con medidor
string currentLanguage = "ES";                // Idioma actual (ES/EN)

// ========== DATOS DEL PERSONAJE ==========
string rp_name = "";
string rp_surname = "";
string social_class = "";
string family_name = "";
string profession = "";
string political_faction = "";
integer health = 100;
integer xp = 0;
integer influence = 10;
integer rubles = 100;
integer wealth = 10;
integer charm = 10;
integer popularity = 10;
integer love_points = 10;
integer loyalty = 10;
integer faith = 10;

// ========== MENSAJES MULTILINGÜE ==========
// Mensajes en español
list MENU_MAIN_ES = ["Información", "Estadísticas", "Configuración", "Idioma", "Conectar Medidor", "Salir"];
list MENU_INFO_ES = ["Nombre", "Clase Social", "Familia", "Profesión", "Facción Política", "Volver"];
list MENU_STATS_ES = ["Salud", "Experiencia", "Influencia", "Riqueza", "Encanto", "Popularidad", "Amor", "Lealtad", "Fe", "Volver"];
list MENU_CONFIG_ES = ["Depuración", "Reiniciar", "Volver"];
list MENU_LANG_ES = ["English", "Español", "Volver"];

// Mensajes en inglés
list MENU_MAIN_EN = ["Information", "Statistics", "Settings", "Language", "Connect Meter", "Exit"];
list MENU_INFO_EN = ["Name", "Social Class", "Family", "Profession", "Political Faction", "Back"];
list MENU_STATS_EN = ["Health", "Experience", "Influence", "Wealth", "Charm", "Popularity", "Love", "Loyalty", "Faith", "Back"];
list MENU_CONFIG_EN = ["Debug", "Reset", "Back"];
list MENU_LANG_EN = ["English", "Español", "Back"];

// ========== FUNCIONES AUXILIARES ==========

// Función para enviar mensaje de depuración
DebugMessage(string message) {
    if (DEBUG_MODE) {
        llOwnerSay("[DEBUG] " + message);
    }
}

// Función para actualizar el medidor de estadísticas
UpdateMeter() {
    if (isConnected && meterID != NULL_KEY) {
        DebugMessage("Enviando datos actualizados al medidor");
        
        // Crear cadena de datos
        string data = "STATS_DATA:" + 
            rp_name + "||" + 
            rp_surname + "||" + 
            social_class + "||" + 
            family_name + "||" + 
            profession + "||" + 
            (string)health + "||" + 
            (string)xp + "||" + 
            (string)influence + "||" + 
            (string)wealth + "||" + 
            (string)rubles + "||" + 
            (string)charm + "||" + 
            (string)popularity + "||" + 
            (string)love_points + "||" + 
            (string)loyalty + "||" + 
            (string)faith;
        
        // Enviar al canal de estadísticas
        llRegionSay(STATS_CHANNEL, data);
    } else {
        DebugMessage("No se puede actualizar: Medidor no conectado");
    }
}

// Función para mostrar menú principal según el idioma
ShowMainMenu() {
    list menu_items;
    string menu_title;
    
    if (currentLanguage == "ES") {
        menu_items = MENU_MAIN_ES;
        menu_title = "HUD Imperial - Menú Principal";
    } else {
        menu_items = MENU_MAIN_EN;
        menu_title = "Imperial HUD - Main Menu";
    }
    
    llDialog(llGetOwner(), menu_title, menu_items, MENU_CHANNEL);
}

// Función para conectar con el medidor
ConnectMeter() {
    DebugMessage("Intentando conectar con medidor de estadísticas");
    
    // Enviar mensaje de conexión al canal de estadísticas
    llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + (string)llGetOwner());
}

// ========== EVENTOS DEL SCRIPT ==========

default {
    state_entry() {
        llOwnerSay("==========================================");
        llOwnerSay("   HUD IMPERIAL DE LA CORTE RUSA - 1905   ");
        llOwnerSay("==========================================");
        
        // Configurar canales de escucha
        llListen(MENU_CHANNEL, "", llGetOwner(), "");
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        llListen(0, "", llGetOwner(), ""); // Canal público para comandos alternativos
        
        DebugMessage("HUD iniciado - Canal de estadísticas: " + (string)STATS_CHANNEL);
        
        // Inicializar con algunos datos de ejemplo
        rp_name = "Nombre";
        rp_surname = "Apellido";
        social_class = "Noble";
        family_name = "Romanov";
        profession = "Cortesano";
        political_faction = "Monárquicos";
        
        // Información para el usuario
        llOwnerSay("Toque este HUD para mostrar el menú principal.");
        llOwnerSay("Comandos alternativos:");
        llOwnerSay("/1menu - Muestra el menú principal");
        llOwnerSay("/1conectar - Conecta con el medidor de estadísticas");
    }
    
    touch_start(integer total_number) {
        DebugMessage("HUD tocado - Mostrando menú principal");
        ShowMainMenu();
    }
    
    listen(integer channel, string name, key id, string message) {
        DebugMessage("Mensaje recibido en canal " + (string)channel + ": " + message);
        
        // Comandos en canal público
        if (channel == 0 && id == llGetOwner()) {
            if (message == "/1menu") {
                DebugMessage("Comando de menú detectado");
                ShowMainMenu();
            }
            else if (message == "/1conectar") {
                DebugMessage("Comando de conexión detectado");
                ConnectMeter();
            }
        }
        // Respuestas de menú
        else if (channel == MENU_CHANNEL && id == llGetOwner()) {
            // Menú en español
            if (currentLanguage == "ES") {
                // Menú principal
                if (message == "Información") {
                    llDialog(llGetOwner(), "Información del Personaje", MENU_INFO_ES, MENU_CHANNEL);
                }
                else if (message == "Estadísticas") {
                    llDialog(llGetOwner(), "Estadísticas del Personaje", MENU_STATS_ES, MENU_CHANNEL);
                }
                else if (message == "Configuración") {
                    llDialog(llGetOwner(), "Configuración del HUD", MENU_CONFIG_ES, MENU_CHANNEL);
                }
                else if (message == "Idioma") {
                    llDialog(llGetOwner(), "Seleccionar Idioma", MENU_LANG_ES, MENU_CHANNEL);
                }
                else if (message == "Conectar Medidor") {
                    ConnectMeter();
                }
                else if (message == "Salir") {
                    llOwnerSay("Menú cerrado");
                }
                // Menú de idioma
                else if (message == "Español") {
                    currentLanguage = "ES";
                    llOwnerSay("Idioma cambiado a Español");
                    ShowMainMenu();
                }
                else if (message == "English") {
                    currentLanguage = "EN";
                    llOwnerSay("Language changed to English");
                    ShowMainMenu();
                }
                // Opción Volver
                else if (message == "Volver") {
                    ShowMainMenu();
                }
            }
            // Menú en inglés
            else {
                // Main menu
                if (message == "Information") {
                    llDialog(llGetOwner(), "Character Information", MENU_INFO_EN, MENU_CHANNEL);
                }
                else if (message == "Statistics") {
                    llDialog(llGetOwner(), "Character Statistics", MENU_STATS_EN, MENU_CHANNEL);
                }
                else if (message == "Settings") {
                    llDialog(llGetOwner(), "HUD Settings", MENU_CONFIG_EN, MENU_CHANNEL);
                }
                else if (message == "Language") {
                    llDialog(llGetOwner(), "Select Language", MENU_LANG_EN, MENU_CHANNEL);
                }
                else if (message == "Connect Meter") {
                    ConnectMeter();
                }
                else if (message == "Exit") {
                    llOwnerSay("Menu closed");
                }
                // Language menu
                else if (message == "Español") {
                    currentLanguage = "ES";
                    llOwnerSay("Idioma cambiado a Español");
                    ShowMainMenu();
                }
                else if (message == "English") {
                    currentLanguage = "EN";
                    llOwnerSay("Language changed to English");
                    ShowMainMenu();
                }
                // Back option
                else if (message == "Back") {
                    ShowMainMenu();
                }
            }
        }
        // Mensajes del canal de estadísticas
        else if (channel == STATS_CHANNEL) {
            if (message == "HUD_CONNECTED") {
                DebugMessage("Conexión con medidor establecida");
                llOwnerSay("¡Medidor de estadísticas conectado correctamente!");
                isConnected = TRUE;
                
                // Enviar datos actualizados al medidor
                UpdateMeter();
            }
            else if (message == "REQUEST_STATS_UPDATE") {
                DebugMessage("Solicitud de actualización recibida");
                
                // Enviar datos actualizados al medidor
                UpdateMeter();
            }
            else if (llGetSubString(message, 0, 12) == "METER_STATUS:") {
                string status = llGetSubString(message, 13, -1);
                DebugMessage("Estado del medidor: " + status);
            }
        }
    }
}