// Imperial Court HUD - API Connector Module
// Este módulo permite que el HUD se conecte con la API de base de datos

// API Constants
// IMPORTANTE: Actualiza esta URL con la URL real de tu servidor Replit antes de usar
// Por ejemplo: "https://imperial-russian-court-rp.NombreUsuario.repl.co" 
string API_URL = "https://imperial-russian-court-rp.replit.app"; // URL de la API en Replit
string API_ENDPOINT_PLAYER = "/api/player/";
string API_ENDPOINT_DAMAGE = "/api/player/damage/";
string API_ENDPOINT_HEAL = "/api/player/heal/";
string API_ENDPOINT_REVIVE = "/api/player/revive/";

// HTTP Constants para peticiones
string METHOD_PARAM = "method";
string MIME_PARAM = "type";

// HTTP Request Keys
key httpPlayerRequest = NULL_KEY;
key httpUpdateRequest = NULL_KEY;
key httpDamageRequest = NULL_KEY;
key httpHealRequest = NULL_KEY;
key httpReviveRequest = NULL_KEY;

// Constants para comunicación
integer HUD_API_CHANNEL = -76543210; // Canal para comunicación con el HUD principal
string AUTH_KEY = "ImperialCourtAuth1905"; // Debe coincidir con el HUD principal

// Variables
key ownerID = NULL_KEY;
string playerID = "";
integer isInitialized = FALSE;
string playerData = "";

// Función para inicializar el módulo
initialize() {
    ownerID = llGetOwner();
    playerID = (string)ownerID; // Usamos el UUID como ID de jugador
    isInitialized = TRUE;
    
    // Informar al usuario
    llOwnerSay("Módulo API inicializado. Conectando con servidor...");
    
    // Notificar al HUD Core que el API Connector está activo
    llRegionSay(HUD_API_CHANNEL, "API_CONNECTED");
    
    // Escuchar el canal del HUD
    llListen(HUD_API_CHANNEL, "", NULL_KEY, "");
    
    // Verificar si el jugador existe en la base de datos
    checkPlayerExists();
}

// Verificar si el jugador existe en la base de datos
checkPlayerExists() {
    string url = API_URL + API_ENDPOINT_PLAYER + playerID;
    httpPlayerRequest = llHTTPRequest(url, [METHOD_PARAM, "GET"], "");
    llOwnerSay("Consultando base de datos...");
}

// Crear un nuevo jugador o actualizar existente
createOrUpdatePlayer(string firstName, string lastName, integer socialClass, integer rank, integer gender) {
    // Determinar clase social según el valor
    string socialClassStr = "Nobility"; // Por defecto Nobleza
    if (socialClass == 0) socialClassStr = "Imperial";
    else if (socialClass == 2) socialClassStr = "Clergy";
    else if (socialClass == 3) socialClassStr = "Military";
    else if (socialClass == 4) socialClassStr = "Citizen";
    
    // Determinar género
    string genderStr = "Masculino";
    if (gender == 1) genderStr = "Femenino";
    
    // Determinar profesión según la clase y rango
    string professionStr = "Noble"; // Por defecto
    
    if (socialClass == 0) {
        if (rank == 0) professionStr = "Tsar/Tsarina";
        else if (rank == 1) professionStr = "Dowager Empress";
        else if (rank == 2) professionStr = "Tsarevich/Tsarevna";
        else professionStr = "Imperial Family Member";
    } 
    else if (socialClass == 1) {
        if (rank < 3) professionStr = "High Nobility";
        else professionStr = "Lower Nobility";
    }
    else if (socialClass == 2) {
        professionStr = "Orthodox Clergy";
    }
    else if (socialClass == 3) {
        if (rank < 3) professionStr = "High Military Officer";
        else professionStr = "Military";
    }
    else if (socialClass == 4) {
        if (rank == 0) professionStr = "Government Official";
        else if (rank == 1) professionStr = "Banker";
        else if (rank == 2) professionStr = "Merchant";
        else professionStr = "Citizen";
    }
    
    // Facción política (por defecto)
    string factionStr = "Neutral";
    
    // Construir el JSON para la solicitud
    string jsonData = "{" +
        "\"id\": \"" + playerID + "\"," +
        "\"rp_name\": \"" + firstName + "\"," +
        "\"rp_surname\": \"" + lastName + "\"," +
        "\"social_class\": \"" + socialClassStr + "\"," +
        "\"profession\": \"" + professionStr + "\"," +
        "\"political_faction\": \"" + factionStr + "\"," +
        "\"gender\": \"" + genderStr + "\"," +
        "\"language\": \"ES\"" +
    "}";
    
    // Realizar la solicitud HTTP
    httpPlayerRequest = llHTTPRequest(
        API_URL + API_ENDPOINT_PLAYER,
        [METHOD_PARAM, "POST", MIME_PARAM, "application/json"],
        jsonData
    );
    
    llOwnerSay("Enviando datos de personaje a la base de datos...");
}

// Actualizar estadísticas en la base de datos
updatePlayerStats(integer health, integer influence, integer charm, integer rubles, integer wealth, integer faith) {
    // Construir el JSON para la actualización
    string jsonData = "{" +
        "\"stats\": {" +
            "\"health\": " + (string)health + "," +
            "\"influence\": " + (string)influence + "," +
            "\"charm\": " + (string)charm + "," +
            "\"rubles\": " + (string)rubles + "," +
            "\"wealth\": " + (string)wealth + "," +
            "\"faith\": " + (string)faith + "" +
        "}" +
    "}";
    
    // Realizar la solicitud HTTP
    httpUpdateRequest = llHTTPRequest(
        API_URL + API_ENDPOINT_PLAYER + playerID,
        [METHOD_PARAM, "PUT", MIME_PARAM, "application/json"],
        jsonData
    );
    
    // No mostrar mensaje para no saturar al usuario
}

// Aplicar daño al jugador
damagePlayer(integer amount) {
    // Crear el form data
    string formData = "amount=" + (string)amount;
    
    // Realizar la solicitud HTTP
    httpDamageRequest = llHTTPRequest(
        API_URL + API_ENDPOINT_DAMAGE + playerID,
        [METHOD_PARAM, "POST", MIME_PARAM, "application/x-www-form-urlencoded"],
        formData
    );
    
    llOwnerSay("Aplicando daño: " + (string)amount + " puntos");
}

// Curar al jugador
healPlayer(integer amount) {
    // Crear el form data
    string formData = "amount=" + (string)amount;
    
    // Realizar la solicitud HTTP
    httpHealRequest = llHTTPRequest(
        API_URL + API_ENDPOINT_HEAL + playerID,
        [METHOD_PARAM, "POST", MIME_PARAM, "application/x-www-form-urlencoded"],
        formData
    );
    
    llOwnerSay("Curando: " + (string)amount + " puntos");
}

// Revivir al jugador
revivePlayer() {
    // Realizar la solicitud HTTP
    httpReviveRequest = llHTTPRequest(
        API_URL + API_ENDPOINT_REVIVE + playerID,
        [METHOD_PARAM, "POST"],
        ""
    );
    
    llOwnerSay("Intentando revivir...");
}

// Procesar datos del jugador recibidos
processPlayerData(string data) {
    // Guardar datos para uso posterior
    playerData = data;
    
    // Notificar al HUD principal sobre los datos
    llRegionSay(HUD_API_CHANNEL, "API_DATA:" + AUTH_KEY + ":" + data);
    
    // Verificar si es una respuesta a un registro exitoso
    if (llSubStringIndex(data, "\"id\":") != -1) {
        // Si contiene un ID, notificar registro exitoso
        llRegionSay(HUD_API_CHANNEL, "API_REGISTERED");
        
        // Notificar también al meter (después de un pequeño retraso)
        llSetTimerEvent(1.0);
    }
    
    // Extraer información básica para mostrar al usuario
    // Esto es solo una aproximación simple, un parseo JSON real sería mejor
    if (llSubStringIndex(data, "\"rp_name\":") != -1) {
        // Extraer el nombre y apellido usando técnicas básicas (esto es simplificado)
        integer nameStart = llSubStringIndex(data, "\"rp_name\":") + 11; // +11 para incluir las comillas
        integer nameEnd = llSubStringIndex(llGetSubString(data, nameStart, -1), "\"") + nameStart;
        string name = llGetSubString(data, nameStart, nameEnd - 1);
        
        integer surnameStart = llSubStringIndex(data, "\"rp_surname\":") + 14; // +14 para incluir las comillas
        integer surnameEnd = llSubStringIndex(llGetSubString(data, surnameStart, -1), "\"") + surnameStart;
        string surname = llGetSubString(data, surnameStart, surnameEnd - 1);
        
        // Extraer salud
        integer healthStart = llSubStringIndex(data, "\"health\":") + 9;
        integer healthEnd = llSubStringIndex(llGetSubString(data, healthStart, -1), ",") + healthStart;
        string healthStr = llGetSubString(data, healthStart, healthEnd - 1);
        integer health = (integer)healthStr;
        
        llOwnerSay("Datos obtenidos para " + name + " " + surname + " (Salud: " + (string)health + ")");
    }
    else {
        llOwnerSay("No se encontraron datos del jugador. Se creará un nuevo perfil cuando te registres.");
    }
}

// Enviar datos al meter
sendDataToMeter(string firstName, string familyName, string rankName, string russianRank, 
               string courtPos, integer health, integer charm, integer influence, 
               integer xp, integer rubles, integer imperialFavor, string wealthCategory, 
               integer gender, integer faith) {
               
    // Formato de datos: STATS_DATA:nombre||apellido||rango||rangoRuso||posiciónCorte||salud||encanto||influencia||xp||rublos||favor||riqueza||género||fe
    string statsData = "STATS_DATA:" + 
                      firstName + "||" + 
                      familyName + "||" + 
                      rankName + "||" + 
                      russianRank + "||" + 
                      courtPos + "||" + 
                      (string)health + "||" + 
                      (string)charm + "||" + 
                      (string)influence + "||" + 
                      (string)xp + "||" + 
                      (string)rubles + "||" + 
                      (string)imperialFavor + "||" + 
                      wealthCategory + "||" + 
                      (string)gender + "||" + 
                      (string)faith;
    
    // Enviar al canal del meter
    integer METER_STATS_CHANNEL = -987654321;
    llRegionSay(METER_STATS_CHANNEL, statsData);
}

// Función para conectar con un meter
connectToMeter() {
    integer METER_STATS_CHANNEL = -987654321;
    llRegionSay(METER_STATS_CHANNEL, "CONNECT_METER:" + (string)ownerID);
    llOwnerSay("Buscando meter de estadísticas...");
    
    // Notificar al meter sobre la conexión a la base de datos
    llSetTimerEvent(2.0); // Esperar un poco para que el meter tenga tiempo de conectarse
}

default {
    state_entry() {
        llOwnerSay("Módulo API cargando...");
        
        // Esperar un momento antes de inicializar para asegurar que el HUD principal cargue primero
        llSetTimerEvent(2.0);
    }
    
    timer() {
        llSetTimerEvent(0.0); // Detener el timer
        
        // Si venimos de connectToMeter(), notificar al meter sobre la conexión a la base de datos
        integer METER_STATS_CHANNEL = -987654321;
        llRegionSay(METER_STATS_CHANNEL, "DATABASE_CONNECTED");
        llOwnerSay("Notificando al meter sobre la conexión con la base de datos...");
        
        initialize();
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == HUD_API_CHANNEL) {
            // Verificar si el mensaje comienza con el código de autenticación
            // El formato esperado es "COMANDO:AUTH_KEY:DATOS"
            list parts = llParseString2List(message, [":"], []);
            
            if (llGetListLength(parts) >= 2) {
                string command = llList2String(parts, 0);
                string auth = llList2String(parts, 1);
                
                // Verificar autenticación
                if (auth == AUTH_KEY) {
                    // Procesar comandos
                    if (command == "REGISTER_PLAYER") {
                        // Formato: REGISTER_PLAYER:AUTH_KEY:firstName:lastName:classNum:rankNum:genderNum
                        string firstName = llList2String(parts, 2);
                        string lastName = llList2String(parts, 3);
                        integer classNum = (integer)llList2String(parts, 4);
                        integer rankNum = (integer)llList2String(parts, 5);
                        integer genderNum = (integer)llList2String(parts, 6);
                        
                        createOrUpdatePlayer(firstName, lastName, classNum, rankNum, genderNum);
                    }
                    else if (command == "UPDATE_STATS") {
                        // Formato: UPDATE_STATS:AUTH_KEY:health:influence:charm:rubles:wealth:faith
                        integer health = (integer)llList2String(parts, 2);
                        integer influence = (integer)llList2String(parts, 3);
                        integer charm = (integer)llList2String(parts, 4);
                        integer rubles = (integer)llList2String(parts, 5);
                        integer wealth = (integer)llList2String(parts, 6);
                        integer faith = (integer)llList2String(parts, 7);
                        
                        updatePlayerStats(health, influence, charm, rubles, wealth, faith);
                    }
                    else if (command == "DAMAGE_PLAYER") {
                        // Formato: DAMAGE_PLAYER:AUTH_KEY:amount
                        integer amount = (integer)llList2String(parts, 2);
                        damagePlayer(amount);
                    }
                    else if (command == "HEAL_PLAYER") {
                        // Formato: HEAL_PLAYER:AUTH_KEY:amount
                        integer amount = (integer)llList2String(parts, 2);
                        healPlayer(amount);
                    }
                    else if (command == "REVIVE_PLAYER") {
                        revivePlayer();
                    }
                    else if (command == "CONNECT_METER") {
                        connectToMeter();
                    }
                    else if (command == "SEND_TO_METER") {
                        // Formato muy largo para meter datos, necesitaría procesarse
                        // Es más eficiente que el HUD llame a esta función directamente
                        if (llGetListLength(parts) >= 15) {
                            sendDataToMeter(
                                llList2String(parts, 2),  // firstName
                                llList2String(parts, 3),  // familyName
                                llList2String(parts, 4),  // rankName
                                llList2String(parts, 5),  // russianRank
                                llList2String(parts, 6),  // courtPos
                                (integer)llList2String(parts, 7),  // health
                                (integer)llList2String(parts, 8),  // charm
                                (integer)llList2String(parts, 9),  // influence
                                (integer)llList2String(parts, 10), // xp
                                (integer)llList2String(parts, 11), // rubles
                                (integer)llList2String(parts, 12), // imperialFavor
                                llList2String(parts, 13), // wealthCategory
                                (integer)llList2String(parts, 14), // gender
                                (integer)llList2String(parts, 15)  // faith
                            );
                        }
                    }
                }
            }
        }
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
        // Procesar respuestas HTTP
        if (request_id == httpPlayerRequest) {
            if (status == 200) {
                processPlayerData(body);
            }
            else {
                llOwnerSay("Error al obtener datos del jugador: " + (string)status);
            }
        }
        else if (request_id == httpUpdateRequest) {
            if (status == 200) {
                // Actualización exitosa, no necesitamos hacer nada
            }
            else {
                llOwnerSay("Error al actualizar estadísticas: " + (string)status);
            }
        }
        else if (request_id == httpDamageRequest) {
            if (status == 200) {
                // Extraer el mensaje de la respuesta (simplificado)
                integer msgStart = llSubStringIndex(body, "\"message\":") + 11;
                integer msgEnd = llSubStringIndex(llGetSubString(body, msgStart, -1), "\"") + msgStart;
                string message = llGetSubString(body, msgStart, msgEnd - 1);
                
                llOwnerSay("Resultado: " + message);
                
                // Actualizar datos locales
                processPlayerData(body);
            }
            else {
                llOwnerSay("Error al aplicar daño: " + (string)status);
            }
        }
        else if (request_id == httpHealRequest) {
            if (status == 200) {
                // Extraer el mensaje de la respuesta (simplificado)
                integer msgStart = llSubStringIndex(body, "\"message\":") + 11;
                integer msgEnd = llSubStringIndex(llGetSubString(body, msgStart, -1), "\"") + msgStart;
                string message = llGetSubString(body, msgStart, msgEnd - 1);
                
                llOwnerSay("Resultado: " + message);
                
                // Actualizar datos locales
                processPlayerData(body);
            }
            else {
                llOwnerSay("Error al curar: " + (string)status);
            }
        }
        else if (request_id == httpReviveRequest) {
            if (status == 200) {
                // Extraer el mensaje de la respuesta (simplificado)
                integer msgStart = llSubStringIndex(body, "\"message\":") + 11;
                integer msgEnd = llSubStringIndex(llGetSubString(body, msgStart, -1), "\"") + msgStart;
                string message = llGetSubString(body, msgStart, msgEnd - 1);
                
                llOwnerSay("Resultado: " + message);
                
                // Actualizar datos locales
                processPlayerData(body);
            }
            else {
                llOwnerSay("Error al revivir: " + (string)status);
            }
        }
    }
    
    // Cuando se adjunta al avatar
    attach(key id) {
        if (id != NULL_KEY) {
            // Solo reinicializar si ya estaba inicializado previamente
            if (isInitialized) {
                initialize();
            }
        }
    }
}