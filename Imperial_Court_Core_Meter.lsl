// Imperial Russian Court - Stats Meter
// Compatible with Core Module (METER_STATS_CHANNEL = -987654321)
// Esta versión está diseñada para funcionar específicamente con el Core Module

// ============= CONSTANTS =============
integer METER_STATS_CHANNEL = -987654321; // Debe coincidir con el Core Module
float TEXT_UPDATE_RATE = 1.0; // Frecuencia de actualización del texto flotante
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Color ámbar/dorado
float TEXT_ALPHA = 1.0; // Opacidad del texto

// ============= VARIABLES =============
// Información básica del personaje
string playerName = "";
string familyName = "";
string rankName = "";
string russianRank = "";
string courtPosition = "";

// Estadísticas
integer health = 100;
integer charm = 50;
integer influence = 25;
integer experience = 0;
integer rubles = 500;
integer imperialFavor = 0;
integer wealth = 2; // Por defecto "Modest"
integer faith = 15;
integer age = 25;
integer love = 0;
integer popularity = 0;
integer loyalty = 0;

// Estado
integer isDead = FALSE;
integer isInHospital = FALSE;
integer isOOC = FALSE;
integer playerClass = 4; // Ciudadano por defecto
integer playerRank = 5; // Rango más bajo por defecto

// Control
integer textVisible = TRUE;
integer isConnected = FALSE;
key hudOwnerID = NULL_KEY;

// Listas de referencia (copiadas del Core para coherencia)
list COURT_POSITIONS = [
    "None",
    "Minister of the Imperial Court",
    "Imperial Chamberlain",
    "Master of Ceremonies",
    "Master of the Horse",
    "Imperial Cupbearer",
    "Imperial Guard Captain",
    "Lady/Gentleman-in-Waiting"
];

list WEALTH_RANKS = [
    "Destitute", // 0
    "Poor",      // 1
    "Modest",    // 2
    "Comfortable", // 3 
    "Wealthy",   // 4
    "Affluent"   // 5
];

list HEALTH_STATUS = [
    "Deceased", // 0
    "Critical", // 1
    "Ill",      // 2
    "Weak",     // 3
    "Healthy",  // 4
    "Vigorous"  // 5
];

// ============= FUNCTIONS =============
// Convierte el valor de salud en un estado textual
string getHealthStatus(integer healthValue) {
    if (healthValue <= 0) return llList2String(HEALTH_STATUS, 0); // Deceased
    else if (healthValue < 20) return llList2String(HEALTH_STATUS, 1); // Critical
    else if (healthValue < 40) return llList2String(HEALTH_STATUS, 2); // Ill
    else if (healthValue < 60) return llList2String(HEALTH_STATUS, 3); // Weak
    else if (healthValue < 80) return llList2String(HEALTH_STATUS, 4); // Healthy
    else return llList2String(HEALTH_STATUS, 5); // Vigorous
}

// Actualiza el texto flotante con la información actual
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    // Si no hay datos del personaje, mostrar mensaje predeterminado
    if (playerName == "" && familyName == "") {
        llSetText("Imperial Court Meter\n(Esperando conexión con HUD)", TEXT_COLOR, TEXT_ALPHA);
        return;
    }
    
    // Si el jugador está en modo OOC, mostrar solo eso
    if (isOOC) {
        llSetText("OOC", <0.5, 0.5, 1.0>, 1.0);
        return;
    }
    
    string displayText = "";
    
    // Información básica
    displayText += playerName + " " + familyName + "\n";
    
    // Rango ruso si está disponible
    if (russianRank != "") {
        displayText += russianRank + "\n";
    }
    
    // Rango en inglés
    if (rankName != "") {
        displayText += rankName + "\n";
    }
    
    // Posición en la corte si la tiene
    if (courtPosition != "None" && courtPosition != "") {
        displayText += courtPosition + "\n";
    }
    
    // Línea separadora
    displayText += "──────────────\n";
    
    // Estado de salud
    string healthStatus = getHealthStatus(health);
    displayText += "Health: " + (string)health + " (" + healthStatus + ")\n";
    
    // Mostrar si está muerto o en el hospital
    if (isDead) {
        displayText += "DECEASED\n";
    }
    else if (isInHospital) {
        displayText += "HOSPITALIZED\n";
    }
    
    // Estadísticas principales
    displayText += "Faith: " + (string)faith + "\n";
    displayText += "Influence: " + (string)influence + " • Charm: " + (string)charm + "\n";
    
    // Información económica
    displayText += "Rubles: " + (string)rubles + " • Wealth: " + llList2String(WEALTH_RANKS, wealth) + "\n";
    
    // Favor imperial
    if (imperialFavor > 0) {
        displayText += "Imperial Favor: " + (string)imperialFavor + "\n";
    }
    
    // Estadísticas secundarias
    displayText += "Age: " + (string)age + " • XP: " + (string)experience + "\n";
    
    // Mostrar el texto
    llSetText(displayText, TEXT_COLOR, TEXT_ALPHA);
}

// Solicita una actualización de estadísticas al HUD
requestStatsUpdate() {
    if (isConnected && hudOwnerID != NULL_KEY) {
        // Enviar solicitud en el canal de estadísticas
        llRegionSay(METER_STATS_CHANNEL, "REQUEST_STATS_UPDATE");
    }
}

// Procesa los datos recibidos del HUD
processStatsData(string data) {
    // Debug: mostrar los datos recibidos
    llOwnerSay("Procesando datos: " + data);
    
    // Dividir la cadena en pares clave:valor separados por |
    list pairs = llParseString2List(data, ["|"], []);
    integer numPairs = llGetListLength(pairs);
    
    // Variable para evitar spam de mensajes
    list changedStats = [];
    
    // Procesar cada par clave:valor
    integer i;
    for (i = 0; i < numPairs; i++) {
        string pair = llList2String(pairs, i);
        
        // Dividir en clave y valor
        list keyValue = llParseString2List(pair, [":"], []);
        
        // Verificar que tenemos clave y valor
        if (llGetListLength(keyValue) == 2) {
            string keyName = llList2String(keyValue, 0);
            string value = llList2String(keyValue, 1);
            
            // Procesar según la clave
            if (keyName == "NAME") {
                // Verificar si hay un cambio
                string oldName = playerName + " " + familyName;
                
                // Dividir el nombre completo en nombre y apellido
                list nameParts = llParseString2List(value, [" "], []);
                if (llGetListLength(nameParts) >= 2) {
                    playerName = llList2String(nameParts, 0);
                    
                    // El apellido podría tener varias palabras
                    familyName = llDumpList2String(llList2List(nameParts, 1, -1), " ");
                }
                else if (value != "") {
                    // Si solo hay una palabra, asumir que es el nombre
                    playerName = value;
                    familyName = "";
                }
                else {
                    // Valor vacío o inválido
                    playerName = "Usuario";
                    familyName = "Sin Registrar";
                }
                
                string newName = playerName + " " + familyName;
                if (oldName != newName) {
                    changedStats += ["Nombre: " + newName];
                }
            }
            else if (keyName == "CLASS") {
                // Almacenar la clase para usarla junto con el rango
                integer newClass = (integer)value;
                if (playerClass != newClass) {
                    playerClass = newClass;
                    changedStats += ["Clase: " + (string)playerClass];
                }
            }
            else if (keyName == "RANK") {
                // Almacenar el rango para usarlo con la clase
                integer newRank = (integer)value;
                if (playerRank != newRank) {
                    playerRank = newRank;
                    changedStats += ["Rango: " + (string)playerRank];
                }
                
                // No actualizamos rankName aquí porque necesitamos la clase
            }
            else if (keyName == "HEALTH") {
                integer newHealth = (integer)value;
                if (health != newHealth) {
                    health = newHealth;
                    changedStats += ["Salud: " + (string)health];
                }
            }
            else if (keyName == "CHARM") {
                integer newCharm = (integer)value;
                if (charm != newCharm) {
                    charm = newCharm;
                    changedStats += ["Encanto: " + (string)charm];
                }
            }
            else if (keyName == "INFLUENCE") {
                integer newInfluence = (integer)value;
                if (influence != newInfluence) {
                    influence = newInfluence;
                    changedStats += ["Influencia: " + (string)influence];
                }
            }
            else if (keyName == "FAITH") {
                integer newFaith = (integer)value;
                if (faith != newFaith) {
                    faith = newFaith;
                    changedStats += ["Fe: " + (string)faith];
                }
            }
            else if (keyName == "WEALTH") {
                integer newWealth = (integer)value;
                if (wealth != newWealth) {
                    wealth = newWealth;
                    changedStats += ["Riqueza: " + llList2String(WEALTH_RANKS, wealth)];
                }
            }
            else if (keyName == "FAVOR") {
                integer newFavor = (integer)value;
                if (imperialFavor != newFavor) {
                    imperialFavor = newFavor;
                    changedStats += ["Favor Imperial: " + (string)imperialFavor];
                }
            }
            else if (keyName == "RUBLES") {
                integer newRubles = (integer)value;
                if (rubles != newRubles) {
                    rubles = newRubles;
                    changedStats += ["Rublos: " + (string)rubles];
                }
            }
            else if (keyName == "XP") {
                integer newXP = (integer)value;
                if (experience != newXP) {
                    experience = newXP;
                    changedStats += ["Experiencia: " + (string)experience];
                }
            }
            else if (keyName == "DEAD") {
                integer newDeadStatus = (integer)value;
                if (isDead != newDeadStatus) {
                    isDead = newDeadStatus;
                    if (isDead) {
                        changedStats += ["Estado: FALLECIDO"];
                    }
                }
            }
            else if (keyName == "COURT") {
                integer courtIndex = (integer)value;
                if (courtIndex >= 0 && courtIndex < llGetListLength(COURT_POSITIONS)) {
                    string newPosition = llList2String(COURT_POSITIONS, courtIndex);
                    if (courtPosition != newPosition) {
                        courtPosition = newPosition;
                        if (courtPosition != "None") {
                            changedStats += ["Posición en la Corte: " + courtPosition];
                        }
                    }
                }
            }
            else if (keyName == "OOC") {
                integer newOOCStatus = (integer)value;
                if (isOOC != newOOCStatus) {
                    isOOC = newOOCStatus;
                    if (isOOC) {
                        changedStats += ["Modo: OOC"];
                    }
                    else {
                        changedStats += ["Modo: En personaje"];
                    }
                }
            }
            else if (keyName == "GENDER") {
                // Guardamos el género pero no lo mostramos directamente
                // Lo usaremos para determinar la versión correcta del rango
            }
        }
    }
    
    // Intentar extraer información específica sobre rangos rusos e ingleses
    if (playerClass == 0 || playerClass == 1) { // Imperial o Noble
        llRegionSay(METER_STATS_CHANNEL, "REQUEST_RANK_NAME:" + (string)playerClass + ":" + (string)playerRank);
    }
    
    // Mostrar un resumen de los cambios si hay alguno
    if (llGetListLength(changedStats) > 0) {
        llOwnerSay("Estadísticas actualizadas: " + llDumpList2String(changedStats, ", "));
    }
    
    // Actualizar el texto flotante con los nuevos datos
    updateFloatingText();
}

// ============= DEFAULT STATE =============
default {
    state_entry() {
        // Inicializar el medidor
        llSetText("Imperial Court Meter\n(Esperando conexión con HUD)", TEXT_COLOR, TEXT_ALPHA);
        
        // Escuchar en el canal de estadísticas
        llListen(METER_STATS_CHANNEL, "", NULL_KEY, "");
        
        // Iniciar temporizador para actualizaciones periódicas
        llSetTimerEvent(TEXT_UPDATE_RATE);
        
        // Informar al propietario
        llOwnerSay("Imperial Court Meter inicializado. Versión compatible con Core Module.");
        llOwnerSay("Canal de comunicación: " + (string)METER_STATS_CHANNEL);
    }
    
    touch_start(integer total_number) {
        // Responder solo a toques del propietario
        if (llDetectedKey(0) == llGetOwner()) {
            // Alternar visibilidad del texto
            textVisible = !textVisible;
            
            if (textVisible) {
                llOwnerSay("Estadísticas visibles");
                updateFloatingText();
            }
            else {
                llOwnerSay("Estadísticas ocultas");
                llSetText("", <0,0,0>, 0.0);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == METER_STATS_CHANNEL) {
            // Mostrar mensaje recibido para depuración
            llOwnerSay("Mensaje recibido: " + message);
            
            // Comprobar tipo de mensaje
            if (llSubStringIndex(message, "CONNECT_METER:") == 0) {
                // Solicitud de conexión desde el HUD Core
                string ownerIDString = llGetSubString(message, 14, -1);
                // Convertir a key y comparar directamente
                if ((key)ownerIDString == llGetOwner()) {
                    hudOwnerID = id;
                    isConnected = TRUE;
                    llOwnerSay("Conectado al HUD Core de " + name);
                    
                    // Enviar confirmación al HUD
                    llRegionSay(METER_STATS_CHANNEL, "HUD_CONNECTED");
                    
                    // Solicitar estadísticas iniciales
                    llSetTimerEvent(0.5); // Pequeña pausa antes de solicitar
                }
            }
            // Respuesta a solicitud de nombres de rangos
            else if (llSubStringIndex(message, "RANK_NAME_RESPONSE:") == 0) {
                // Extraer información del rango
                list rankInfo = llParseString2List(llGetSubString(message, 18, -1), [":"], []);
                if (llGetListLength(rankInfo) >= 2) {
                    rankName = llList2String(rankInfo, 0);
                    russianRank = llList2String(rankInfo, 1);
                    llOwnerSay("Información de rango recibida: " + rankName + " / " + russianRank);
                    updateFloatingText();
                }
            }
            // Formato estándar de datos de estadísticas (NAME:valor|HEALTH:valor|etc.)
            else if (llSubStringIndex(message, "NAME:") != -1) {
                // Procesar los datos recibidos
                processStatsData(message);
                
                // Si no estábamos conectados, ahora lo estamos
                if (!isConnected) {
                    isConnected = TRUE;
                    hudOwnerID = id;
                    llOwnerSay("Conectado y recibiendo datos del HUD");
                }
            }
        }
    }
    
    timer() {
        // Si estamos conectados, solicitar actualizaciones periódicas
        if (isConnected && hudOwnerID != NULL_KEY) {
            requestStatsUpdate();
            
            // Establecer un intervalo más largo para no sobrecargar
            llSetTimerEvent(5.0);
        }
        else {
            // Si no estamos conectados, seguir intentando con menos frecuencia
            llSetTimerEvent(10.0);
        }
    }
}