// Imperial Court HUD - Main Script
// Este script gestiona la comunicación entre Second Life y el servidor Flask
// Propietario: Zar Nicolai II Romanov

// Configuración
string API_URL = "https://imperial-russian-court.replit.app"; // URL del servidor Flask
string API_ENDPOINT = "/api/players/";
integer API_CHANNEL = -9876543; // Canal para recibir respuestas HTTP
integer STATS_CHANNEL = -987654321; // Canal para comunicación con el medidor flotante
integer MENU_CHANNEL; // Canal dinámico para menús
key HTTP_REQUEST_ID; // ID de la solicitud HTTP actual
string PLAYER_UUID; // UUID del jugador en Second Life

// Variables de sesión
string playerFirstName = "";
string playerLastName = "";
string fullName = "";
string familyName = "";
string socialClass = "";
string profession = "";
string politicalFaction = "";
string gender = "";
string language = "ES"; // Idioma por defecto: Español

// Variables de estadísticas
integer health = 100;
integer influence = 10;
integer rubles = 100;
integer charm = 10;
integer popularity = 10;
integer lovePoints = 10;
integer loyalty = 10;
integer faith = 10;
integer wealth = 10;
integer xp = 0;
integer age = 25;

// Estado del jugador
integer isInComa = FALSE;
integer isDead = FALSE;
string comaSince = "";
string deathDate = "";

// Flags
integer isAPIConnected = FALSE;
integer isMenuActive = FALSE;
integer isMeterConnected = FALSE;
integer quietMode = FALSE;
integer oocMode = FALSE; // Modo fuera de personaje

// Textos multilingües
list LANGUAGE_CODES = ["ES", "EN"];
list MENU_TITLE_TEXT = ["Menú Principal", "Main Menu"];
list HEALTH_TEXT = ["Salud", "Health"];
list INFLUENCE_TEXT = ["Influencia", "Influence"];
list RUBLES_TEXT = ["Rublos", "Rubles"];
list CHARM_TEXT = ["Encanto", "Charm"];
list POPULARITY_TEXT = ["Popularidad", "Popularity"];
list LOVE_TEXT = ["Amor", "Love"];
list LOYALTY_TEXT = ["Lealtad", "Loyalty"];
list FAITH_TEXT = ["Fe", "Faith"];
list WEALTH_TEXT = ["Riqueza", "Wealth"];
list XP_TEXT = ["Experiencia", "Experience"];
list AGE_TEXT = ["Edad", "Age"];
list STATS_TEXT = ["Estadísticas", "Statistics"];
list PROFILE_TEXT = ["Perfil", "Profile"];
list COMA_TEXT = ["¡Estás en coma!", "You are in a coma!"];
list DEAD_TEXT = ["¡Has muerto!", "You are dead!"];
list LANGUAGE_TEXT = ["Idioma", "Language"];
list CONNECT_TEXT = ["Conectar Medidor", "Connect Meter"];
list OOC_TEXT = ["Modo OOC", "OOC Mode"];
list CONNECT_SUCCESS = ["Medidor conectado con éxito", "Meter connected successfully"];
list DISCONNECT_SUCCESS = ["Medidor desconectado", "Meter disconnected"];
list API_CONNECT_FAIL = ["Error al conectar con el servidor API", "Failed to connect to API server"];
list HELP_TEXT = ["Ayuda", "Help"];
list CLOSE_TEXT = ["Cerrar", "Close"];

// Función para obtener texto en el idioma actual
string getText(list textList) {
    integer langIndex = llListFindList(LANGUAGE_CODES, [language]);
    if (langIndex == -1) {
        langIndex = 0; // Por defecto español
    }
    return llList2String(textList, langIndex);
}

// Función para mostrar mensajes al propietario
say(string message) {
    if (!quietMode) {
        llOwnerSay(message);
    }
}

// Función para inicializar el HUD
initialize() {
    // Obtener el UUID del avatar
    PLAYER_UUID = (string)llGetOwner();
    
    // Mostrar mensaje de depuración
    llOwnerSay("ID de jugador: " + PLAYER_UUID);
    
    // Generar un canal dinámico para los menús
    MENU_CHANNEL = ((integer)("0x" + llGetSubString(PLAYER_UUID, 0, 8))) & 0x7FFFFFFF;
    llOwnerSay("Canal de menú configurado: " + (string)MENU_CHANNEL);
    
    // Configurar escucha para respuestas HTTP, menús y comunicación con medidor
    llListen(API_CHANNEL, "", NULL_KEY, "");
    llListen(MENU_CHANNEL, "", llGetOwner(), "");
    llListen(STATS_CHANNEL, "", NULL_KEY, "");
    
    llOwnerSay("Escuchando en canales: API=" + (string)API_CHANNEL + ", MENU=" + (string)MENU_CHANNEL + ", STATS=" + (string)STATS_CHANNEL);
    
    // Obtener el nombre del avatar
    fullName = llKey2Name(llGetOwner());
    llOwnerSay("Nombre completo detectado: " + fullName);
    
    list nameParts = llParseString2List(fullName, [" "], []);
    if (llGetListLength(nameParts) >= 2) {
        playerFirstName = llList2String(nameParts, 0);
        playerLastName = llList2String(nameParts, 1);
        llOwnerSay("Nombre procesado: " + playerFirstName + " " + playerLastName);
    } else {
        llOwnerSay("ADVERTENCIA: No se pudo dividir el nombre correctamente.");
    }
    
    // Intentar cargar el perfil del jugador desde el servidor
    llOwnerSay("Intentando cargar perfil desde el servidor...");
    loadPlayerProfile();
}

// Función para cargar el perfil del jugador desde el API
loadPlayerProfile() {
    string url = API_URL + API_ENDPOINT + PLAYER_UUID;
    say("Conectando con el servidor...");
    HTTP_REQUEST_ID = llHTTPRequest(url, [HTTP_METHOD, "GET"], "");
}

// Función para crear un perfil de jugador si no existe
createPlayerProfile() {
    say("Creando un nuevo perfil de personaje...");
    showCharacterCreationMenu();
}

// Función para actualizar las estadísticas del jugador en el servidor
updatePlayerStats() {
    if (!isAPIConnected) return;
    
    string url = API_URL + API_ENDPOINT + PLAYER_UUID;
    string postData = llList2Json(JSON_OBJECT, [
        "health", health,
        "influence", influence,
        "rubles", rubles,
        "charm", charm,
        "popularity", popularity,
        "love_points", lovePoints,
        "loyalty", loyalty,
        "faith", faith,
        "wealth", wealth,
        "xp", xp,
        "age", age
    ]);
    
    HTTP_REQUEST_ID = llHTTPRequest(url, [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json"], postData);
}

// Función para procesar la respuesta HTTP
processHTTPResponse(key request_id, integer status, list metadata, string body) {
    if (request_id != HTTP_REQUEST_ID) return;
    
    if (status != 200 && status != 201) {
        say(getText(API_CONNECT_FAIL) + " (" + (string)status + ")");
        if (status == 404) {
            // Si el jugador no existe, ofrecer crear un perfil
            createPlayerProfile();
        }
        return;
    }
    
    isAPIConnected = TRUE;
    
    // Intentar analizar la respuesta JSON
    if (llJsonValueType(body, []) == JSON_OBJECT) {
        // Actualizar datos del perfil
        if (llJsonValueType(body, ["rp_name"]) == JSON_STRING) {
            playerFirstName = llJsonGetValue(body, ["rp_name"]);
        }
        if (llJsonValueType(body, ["rp_surname"]) == JSON_STRING) {
            playerLastName = llJsonGetValue(body, ["rp_surname"]);
        }
        if (llJsonValueType(body, ["family_name"]) == JSON_STRING) {
            familyName = llJsonGetValue(body, ["family_name"]);
        }
        if (llJsonValueType(body, ["social_class"]) == JSON_STRING) {
            socialClass = llJsonGetValue(body, ["social_class"]);
        }
        if (llJsonValueType(body, ["profession"]) == JSON_STRING) {
            profession = llJsonGetValue(body, ["profession"]);
        }
        if (llJsonValueType(body, ["political_faction"]) == JSON_STRING) {
            politicalFaction = llJsonGetValue(body, ["political_faction"]);
        }
        if (llJsonValueType(body, ["gender"]) == JSON_STRING) {
            gender = llJsonGetValue(body, ["gender"]);
        }
        if (llJsonValueType(body, ["language"]) == JSON_STRING) {
            language = llJsonGetValue(body, ["language"]);
        }
        
        // Actualizar estadísticas
        if (llJsonValueType(body, ["stats", "health"]) == JSON_NUMBER) {
            health = (integer)llJsonGetValue(body, ["stats", "health"]);
        }
        if (llJsonValueType(body, ["stats", "influence"]) == JSON_NUMBER) {
            influence = (integer)llJsonGetValue(body, ["stats", "influence"]);
        }
        if (llJsonValueType(body, ["stats", "rubles"]) == JSON_NUMBER) {
            rubles = (integer)llJsonGetValue(body, ["stats", "rubles"]);
        }
        if (llJsonValueType(body, ["stats", "charm"]) == JSON_NUMBER) {
            charm = (integer)llJsonGetValue(body, ["stats", "charm"]);
        }
        if (llJsonValueType(body, ["stats", "popularity"]) == JSON_NUMBER) {
            popularity = (integer)llJsonGetValue(body, ["stats", "popularity"]);
        }
        if (llJsonValueType(body, ["stats", "love_points"]) == JSON_NUMBER) {
            lovePoints = (integer)llJsonGetValue(body, ["stats", "love_points"]);
        }
        if (llJsonValueType(body, ["stats", "loyalty"]) == JSON_NUMBER) {
            loyalty = (integer)llJsonGetValue(body, ["stats", "loyalty"]);
        }
        if (llJsonValueType(body, ["stats", "faith"]) == JSON_NUMBER) {
            faith = (integer)llJsonGetValue(body, ["stats", "faith"]);
        }
        if (llJsonValueType(body, ["stats", "wealth"]) == JSON_NUMBER) {
            wealth = (integer)llJsonGetValue(body, ["stats", "wealth"]);
        }
        if (llJsonValueType(body, ["stats", "xp"]) == JSON_NUMBER) {
            xp = (integer)llJsonGetValue(body, ["stats", "xp"]);
        }
        if (llJsonValueType(body, ["stats", "age"]) == JSON_NUMBER) {
            age = (integer)llJsonGetValue(body, ["stats", "age"]);
        }
        
        // Actualizar estado del jugador
        if (llJsonValueType(body, ["status", "in_coma"]) == JSON_TRUE) {
            isInComa = TRUE;
        } else if (llJsonValueType(body, ["status", "in_coma"]) == JSON_FALSE) {
            isInComa = FALSE;
        }
        if (llJsonValueType(body, ["status", "is_dead"]) == JSON_TRUE) {
            isDead = TRUE;
        } else if (llJsonValueType(body, ["status", "is_dead"]) == JSON_FALSE) {
            isDead = FALSE;
        }
        if (llJsonValueType(body, ["status", "coma_since"]) != JSON_INVALID) {
            comaSince = llJsonGetValue(body, ["status", "coma_since"]);
        }
        if (llJsonValueType(body, ["status", "death_date"]) != JSON_INVALID) {
            deathDate = llJsonGetValue(body, ["status", "death_date"]);
        }
        
        // Actualizar el medidor si está conectado
        updateMeter();
        
        say("Perfil cargado con éxito");
        
        // Si el jugador está en coma o muerto, mostrar un aviso
        if (isInComa) {
            say("\n⚠️ " + getText(COMA_TEXT));
        } else if (isDead) {
            say("\n⚠️ " + getText(DEAD_TEXT));
        }
    }
}

// Función para mostrar el menú principal
showMainMenu() {
    if (isMenuActive) {
        llOwnerSay("Menú ya activo, no se mostrará de nuevo");
        return;
    }
    
    isMenuActive = TRUE;
    llOwnerSay("Mostrando menú principal...");
    
    list buttons = [];
    
    // Sección principal
    buttons += [getText(STATS_TEXT), getText(PROFILE_TEXT)];
    
    // Opciones adicionales
    buttons += [getText(CONNECT_TEXT), getText(LANGUAGE_TEXT), getText(OOC_TEXT)];
    
    // Ayuda y cerrar
    buttons += [getText(HELP_TEXT), getText(CLOSE_TEXT)];
    
    // Debug
    llOwnerSay("Botones del menú: " + llList2CSV(buttons));
    llOwnerSay("Canal del menú: " + (string)MENU_CHANNEL);
    
    // Mostrar diálogo al propietario
    llDialog(llGetOwner(), getText(MENU_TITLE_TEXT), buttons, MENU_CHANNEL);
    
    // Establecer un temporizador para cerrar el menú si no hay respuesta
    llSetTimerEvent(60.0);
}

// Función para mostrar el menú de estadísticas
showStatsMenu() {
    if (!isAPIConnected) {
        say(getText(API_CONNECT_FAIL));
        return;
    }
    
    string message = getText(STATS_TEXT) + ":\n";
    message += getText(HEALTH_TEXT) + ": " + (string)health + "/100\n";
    message += getText(INFLUENCE_TEXT) + ": " + (string)influence + "\n";
    message += getText(RUBLES_TEXT) + ": " + (string)rubles + "\n";
    message += getText(CHARM_TEXT) + ": " + (string)charm + "\n";
    message += getText(POPULARITY_TEXT) + ": " + (string)popularity + "\n";
    message += getText(LOVE_TEXT) + ": " + (string)lovePoints + "\n";
    message += getText(LOYALTY_TEXT) + ": " + (string)loyalty + "\n";
    message += getText(FAITH_TEXT) + ": " + (string)faith + "\n";
    message += getText(WEALTH_TEXT) + ": " + (string)wealth + "\n";
    message += getText(XP_TEXT) + ": " + (string)xp + "\n";
    message += getText(AGE_TEXT) + ": " + (string)age + "\n";
    
    list buttons = [getText(CLOSE_TEXT)];
    llDialog(llGetOwner(), message, buttons, MENU_CHANNEL);
}

// Función para mostrar el menú de perfil
showProfileMenu() {
    if (!isAPIConnected) {
        say(getText(API_CONNECT_FAIL));
        return;
    }
    
    string message = getText(PROFILE_TEXT) + ":\n";
    message += "Nombre: " + playerFirstName + " " + playerLastName + "\n";
    message += "Familia: " + familyName + "\n";
    message += "Clase Social: " + socialClass + "\n";
    message += "Profesión: " + profession + "\n";
    message += "Facción Política: " + politicalFaction + "\n";
    message += "Género: " + gender + "\n";
    
    list buttons = [getText(CLOSE_TEXT)];
    llDialog(llGetOwner(), message, buttons, MENU_CHANNEL);
}

// Función para cambiar el idioma
changeLanguage() {
    integer langIndex = llListFindList(LANGUAGE_CODES, [language]);
    langIndex = (langIndex + 1) % llGetListLength(LANGUAGE_CODES);
    language = llList2String(LANGUAGE_CODES, langIndex);
    
    // Actualizar el idioma en el servidor
    if (isAPIConnected) {
        string url = API_URL + API_ENDPOINT + PLAYER_UUID;
        string postData = llList2Json(JSON_OBJECT, [
            "language", language
        ]);
        HTTP_REQUEST_ID = llHTTPRequest(url, [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json"], postData);
    }
    
    say("Idioma cambiado a: " + language);
}

// Función para conectar con un medidor de estadísticas flotante
connectMeter() {
    say("Buscando medidor de estadísticas...");
    llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + PLAYER_UUID);
    
    // Dar un tiempo para la conexión
    llSetTimerEvent(5.0);
}

// Función para desconectar del medidor
disconnectMeter() {
    if (isMeterConnected) {
        llRegionSay(STATS_CHANNEL, "HUD_DISCONNECTED");
        isMeterConnected = FALSE;
        say(getText(DISCONNECT_SUCCESS));
    }
}

// Función para actualizar los datos del medidor
updateMeter() {
    if (!isMeterConnected) {
        llOwnerSay("Medidor no conectado, no se enviarán datos.");
        return;
    }
    
    llOwnerSay("Actualizando medidor de estadísticas...");
    
    // Preparar datos para enviar al medidor
    string playerGenderValue = "0";
    if (gender == "Femenino" || gender == "Female") {
        playerGenderValue = "1";
    }
    
    // Determinar el rango de riqueza basado en rubles y wealth
    string wealthCategory = "Pobre";
    if (wealth > 80 || rubles > 5000) {
        wealthCategory = "Extremadamente Rico";
    } else if (wealth > 60 || rubles > 1000) {
        wealthCategory = "Rico";
    } else if (wealth > 40 || rubles > 500) {
        wealthCategory = "Acomodado";
    } else if (wealth > 20 || rubles > 200) {
        wealthCategory = "Clase Media";
    }
    
    // No enviar datos en modo OOC
    if (oocMode) {
        llOwnerSay("Enviando datos en modo OOC");
        llRegionSay(STATS_CHANNEL, "STATS_DATA:OOC||OOC||OOC||OOC||OOC||100||0||0||0||0||0||OOC||0||0");
        return;
    }
    
    // Construir la cadena de datos
    string statsData = "STATS_DATA:" + 
        playerFirstName + "||" + 
        playerLastName + "||" + 
        socialClass + "||" + 
        familyName + "||" + 
        profession + "||" + 
        (string)health + "||" + 
        (string)charm + "||" + 
        (string)influence + "||" + 
        (string)xp + "||" + 
        (string)rubles + "||" + 
        (string)popularity + "||" + 
        wealthCategory + "||" + 
        playerGenderValue + "||" + 
        (string)faith;
    
    // Mostrar datos para depuración
    llOwnerSay("Enviando datos al medidor: " + statsData);
    
    // Enviar datos al medidor
    llRegionSay(STATS_CHANNEL, statsData);
}

// Función para alternar el modo OOC (Fuera de Personaje)
toggleOOCMode() {
    oocMode = !oocMode;
    
    if (oocMode) {
        say("Modo OOC activado. Tus estadísticas están ocultas.");
    } else {
        say("Modo OOC desactivado. Tus estadísticas son visibles.");
    }
    
    // Actualizar el medidor
    updateMeter();
}

// Función para mostrar el menú de creación de personaje
showCharacterCreationMenu() {
    // Esta función debería permitir al usuario seleccionar:
    // - Nombre (para RP, no necesariamente el nombre de avatar)
    // - Apellido
    // - Familia noble (si es aplicable)
    // - Clase social
    // - Profesión
    // - Facción política
    // - Género
    
    // Por ahora, vamos a crear un perfil básico con datos ficticios
    // En una implementación completa, estos datos deberían ser solicitados al usuario
    
    say("Creando perfil básico para iniciar. Usa el menú para editarlo más tarde.");
    
    string url = API_URL + API_ENDPOINT;
    string postData = llList2Json(JSON_OBJECT, [
        "id", PLAYER_UUID,
        "rp_name", playerFirstName,
        "rp_surname", playerLastName,
        "social_class", "Nobleza",
        "profession", "Aristócrata de la Corte",
        "political_faction", "Monárquico",
        "gender", "Masculino",
        "language", language,
        "family_name", playerLastName
    ]);
    
    HTTP_REQUEST_ID = llHTTPRequest(url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json"], postData);
}

default {
    state_entry() {
        // Inicializar el HUD con mensajes adicionales
        llOwnerSay("¡SCRIPT INICIADO! Imperial Russian Court HUD cargado.");
        llOwnerSay("Toca el HUD para ver opciones. Escuchando en canales:");
        
        // Establecer canales manualmente, sin llamar a la función initialize
        PLAYER_UUID = (string)llGetOwner();
        llOwnerSay("ID de jugador: " + PLAYER_UUID);
        
        // Canal para menús
        MENU_CHANNEL = ((integer)("0x" + llGetSubString(PLAYER_UUID, 0, 8))) & 0x7FFFFFFF;
        llOwnerSay("Canal de menú: " + (string)MENU_CHANNEL);
        
        // Configuraciones de escucha directamente
        llListen(MENU_CHANNEL, "", llGetOwner(), "");
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        llListen(API_CHANNEL, "", NULL_KEY, "");
        
        // Mensaje final
        llOwnerSay("--- INICIALIZACIÓN COMPLETA. TOQUE ESTE OBJETO PARA INTERACTUAR ---");
    }
    
    touch_start(integer total_number) {
        // Respuesta muy básica al toque
        llOwnerSay("*** TOQUE DETECTADO ***");
        
        // Prueba de diálogo directa sin invocar la función showMainMenu
        llDialog(llGetOwner(), 
                 "Menú Imperial HUD - Prueba directa", 
                 ["Estadísticas", "Perfil", "Conectar", "Cerrar"], 
                 MENU_CHANNEL);
                 
        llOwnerSay("Diálogo enviado directamente en canal: " + (string)MENU_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Añadir un mensaje de depuración para monitorear los escuchas
        llOwnerSay("Mensaje escuchado en canal " + (string)channel + ": " + message);
        llOwnerSay("De: " + name + " (ID: " + (string)id + ")");
        llOwnerSay("Mi ID: " + (string)llGetOwner());
        
        if (channel == MENU_CHANNEL && id == llGetOwner()) {
            // Procesamiento de selecciones de menú
            llOwnerSay("Procesando selección de menú: " + message);
            
            // Respuesta al menú simplificado primero
            if (message == "Estadísticas") {
                llOwnerSay("Mostrando estadísticas simples de prueba");
                llDialog(llGetOwner(), "Estadísticas:\nSalud: 100\nInfluencia: 50\nRublos: 250", ["Cerrar"], MENU_CHANNEL);
                return;
            } else if (message == "Perfil") {
                llOwnerSay("Mostrando perfil simple de prueba");
                llDialog(llGetOwner(), "Perfil:\nNombre: "  + playerFirstName + " " + playerLastName + "\nClase: Nobleza", ["Cerrar"], MENU_CHANNEL);
                return;
            } else if (message == "Conectar") {
                llOwnerSay("Intentando conectar al medidor de prueba");
                llRegionSay(STATS_CHANNEL, "CONNECT_METER:" + PLAYER_UUID);
                return;
            } else if (message == "Cerrar") {
                llOwnerSay("Cerrando menú de prueba");
                return;
            }
            
            // Procesamiento normal del menú
            if (message == getText(STATS_TEXT)) {
                showStatsMenu();
            } else if (message == getText(PROFILE_TEXT)) {
                showProfileMenu();
            } else if (message == getText(LANGUAGE_TEXT)) {
                changeLanguage();
                showMainMenu();
            } else if (message == getText(CONNECT_TEXT)) {
                connectMeter();
            } else if (message == getText(OOC_TEXT)) {
                toggleOOCMode();
                showMainMenu();
            } else if (message == getText(HELP_TEXT)) {
                say("Sistema de la Corte Imperial Rusa - Ayuda:\n- Toca el HUD para mostrar el menú\n- Conecta un medidor para mostrar tus estadísticas a otros");
                showMainMenu();
            } else if (message == getText(CLOSE_TEXT)) {
                isMenuActive = FALSE;
                llSetTimerEvent(0.0);
            }
        } else if (channel == STATS_CHANNEL) {
            // Procesamiento de mensajes del medidor
            llOwnerSay("Mensaje del canal de estadísticas: " + message);
            
            if (message == "HUD_CONNECTED") {
                isMeterConnected = TRUE;
                say(getText(CONNECT_SUCCESS));
                updateMeter();
            } else if (message == "REQUEST_STATS_UPDATE") {
                updateMeter();
            }
        } else if (channel == API_CHANNEL) {
            // Este es un canal para respuestas HTTP simuladas
            // En Second Life, esto sería manejado por http_response
            llOwnerSay("Mensaje del canal API: " + message);
            
            list parts = llParseString2List(message, ["|"], []);
            if (llGetListLength(parts) >= 3) {
                key request_id = (key)llList2String(parts, 0);
                integer status = (integer)llList2String(parts, 1);
                string body = llList2String(parts, 2);
                processHTTPResponse(request_id, status, [], body);
            }
        }
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
        processHTTPResponse(request_id, status, metadata, body);
    }
    
    timer() {
        if (isMenuActive) {
            isMenuActive = FALSE;
            llSetTimerEvent(0.0);
        } else if (isMeterConnected) {
            // Si estamos conectados a un medidor, actualizar periódicamente
            updateMeter();
            llSetTimerEvent(10.0); // Actualizar cada 10 segundos
        } else {
            llSetTimerEvent(0.0);
        }
    }
}