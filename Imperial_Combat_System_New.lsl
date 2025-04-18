// Imperial Combat System - Integrado con el servidor API
// Este script permite a los jugadores participar en duelos y combates
// Propietario: Zar Nicolai II Romanov

// Configuración
string API_URL = "https://imperial-russian-court.replit.app"; // URL del servidor Flask
string API_ENDPOINT = "/api/players/";
integer COMBAT_CHANNEL = -555123; // Canal para comunicación de combate
integer MENU_CHANNEL; // Canal dinámico para menús
key HTTP_REQUEST_ID; // ID de la solicitud HTTP actual
float COOLDOWN_TIME = 30.0; // Tiempo de espera entre ataques (segundos)

// Variables del jugador
key ownerID;
string ownerName;
list nearbyPlayers = []; // Lista de jugadores cercanos que pueden ser objetivos
list nearbyPlayerIDs = []; // UUID correspondientes de jugadores cercanos

// Variables de combate
integer canAttack = TRUE; // Si el jugador puede atacar ahora
integer isDefending = FALSE; // Si el jugador está en modo defensa
float defenseBonus = 0.25; // Reducción de daño en modo defensa (25%)
float attackMultiplier = 1.0; // Multiplicador de daño base

// Variables de arma
string weaponType = "Sable"; // Tipo de arma predeterminado
integer baseDamage = 20; // Daño base del arma
string attackAnimation = "saber"; // Animación al atacar
string defendAnimation = "defend"; // Animación al defender

// Textos multilingües
string language = "ES"; // Idioma por defecto: Español
list LANGUAGE_CODES = ["ES", "EN"];
list COMBAT_MENU_TEXT = ["Menú de Combate", "Combat Menu"];
list ATTACK_TEXT = ["Atacar", "Attack"];
list DEFEND_TEXT = ["Defender", "Defend"];
list SCAN_TEXT = ["Buscar Objetivos", "Scan Targets"];
list WEAPON_TEXT = ["Cambiar Arma", "Change Weapon"];
list CLOSE_TEXT = ["Cerrar", "Close"];
list NO_TARGETS_TEXT = ["No hay objetivos cercanos", "No nearby targets"];
list COOLDOWN_TEXT = ["Tiempo de espera: ", "Cooldown: "];
list ATTACK_SUCCESS_TEXT = ["¡Has atacado a ", "You attacked "];
list ATTACK_FAIL_TEXT = ["Ataque fallido", "Attack failed"];
list DEFENSE_ON_TEXT = ["Modo defensa activado", "Defense mode activated"];
list DEFENSE_OFF_TEXT = ["Modo defensa desactivado", "Defense mode deactivated"];
list SECOND_TEXT = ["segundo", "second"];
list SECONDS_TEXT = ["segundos", "seconds"];
list YOU_WERE_ATTACKED_TEXT = ["¡Fuiste atacado por ", "You were attacked by "];
list DAMAGE_TEXT = ["Daño recibido: ", "Damage received: "];

// Mensajes de ataque
list ATTACK_MESSAGES_ES = [
    "¡Ha lanzado un ataque con su WEAPON!",
    "¡Ha atacado con elegancia usando su WEAPON!",
    "¡Ha ejecutado una maniobra ofensiva con su WEAPON!",
    "¡Ha arremetido con su WEAPON en un movimiento preciso!",
    "¡Ha iniciado un asalto con su WEAPON!"
];
list ATTACK_MESSAGES_EN = [
    "Has launched an attack with their WEAPON!",
    "Has attacked elegantly using their WEAPON!",
    "Has executed an offensive maneuver with their WEAPON!",
    "Has charged with their WEAPON in a precise movement!",
    "Has initiated an assault with their WEAPON!"
];

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
    llOwnerSay(message);
}

// Función para inicializar el HUD
initialize() {
    // Obtener el UUID del propietario
    ownerID = llGetOwner();
    ownerName = llKey2Name(ownerID);
    
    // Generar un canal dinámico para los menús
    MENU_CHANNEL = ((integer)("0x" + llGetSubString((string)ownerID, 0, 8))) & 0x7FFFFFFF;
    
    // Configurar escucha para los canales relevantes
    llListen(COMBAT_CHANNEL, "", NULL_KEY, "");
    llListen(MENU_CHANNEL, "", NULL_KEY, "");
}

// Función para mostrar el menú de combate
showCombatMenu() {
    list buttons = [getText(ATTACK_TEXT), getText(DEFEND_TEXT), getText(SCAN_TEXT)];
    buttons += [getText(WEAPON_TEXT), getText(CLOSE_TEXT)];
    
    // Añadir información sobre el tiempo de espera si es aplicable
    string title = getText(COMBAT_MENU_TEXT);
    if (!canAttack) {
        title += "\n" + getText(COOLDOWN_TEXT) + "⏱️";
    }
    
    llDialog(ownerID, title, buttons, MENU_CHANNEL);
}

// Función para buscar objetivos cercanos
scanTargets() {
    say("Buscando objetivos cercanos...");
    // Limpiar listas anteriores
    nearbyPlayers = [];
    nearbyPlayerIDs = [];
    // Utilizar sensor para detectar avatares cercanos
    llSensor("", NULL_KEY, AGENT, 20.0, PI);
}

// Función para mostrar el menú de selección de objetivo
showTargetMenu() {
    integer numTargets = llGetListLength(nearbyPlayers);
    if (numTargets == 0) {
        say(getText(NO_TARGETS_TEXT));
        showCombatMenu();
        return;
    }
    
    // Limitar a 12 objetivos (máximo para llDialog)
    if (numTargets > 12) numTargets = 12;
    
    list buttons = [];
    integer i;
    for (i = 0; i < numTargets; ++i) {
        buttons += [llList2String(nearbyPlayers, i)];
    }
    
    string title = getText(ATTACK_TEXT);
    if (!canAttack) {
        title += "\n" + getText(COOLDOWN_TEXT) + "⏱️";
    }
    
    llDialog(ownerID, title, buttons, MENU_CHANNEL);
}

// Función para atacar a un objetivo
attackTarget(string targetName) {
    if (!canAttack) {
        say(getText(COOLDOWN_TEXT) + "⏱️");
        return;
    }
    
    integer targetIndex = llListFindList(nearbyPlayers, [targetName]);
    if (targetIndex == -1) {
        say(getText(ATTACK_FAIL_TEXT));
        return;
    }
    
    // Obtener el UUID del objetivo
    key targetID = (key)llList2String(nearbyPlayerIDs, targetIndex);
    
    // Calcular daño con variación aleatoria (±20%)
    float damageMultiplier = 0.8 + (llFrand(0.4)); // entre 0.8 y 1.2
    integer damage = (integer)(baseDamage * attackMultiplier * damageMultiplier);
    
    // Enviar mensaje de ataque al canal de combate
    string attackMessage = llGetDisplayName(ownerID) + " " + getRandomAttackMessage();
    attackMessage = llDumpList2String(llParseString2List(attackMessage, ["WEAPON"], []), weaponType);
    llRegionSay(COMBAT_CHANNEL, "ATTACK|" + (string)ownerID + "|" + (string)targetID + "|" + (string)damage + "|" + attackMessage);
    
    // Enviar solicitud HTTP para aplicar daño
    string url = API_URL + API_ENDPOINT + (string)targetID + "/damage";
    string postData = llList2Json(JSON_OBJECT, [
        "amount", damage
    ]);
    
    HTTP_REQUEST_ID = llHTTPRequest(url, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json"], postData);
    
    // Notificar al propietario
    say(getText(ATTACK_SUCCESS_TEXT) + targetName + "!");
    
    // Establecer tiempo de espera
    canAttack = FALSE;
    llSetTimerEvent(1.0); // Iniciar temporizador para contar el tiempo de espera
}

// Función para obtener un mensaje de ataque aleatorio
string getRandomAttackMessage() {
    if (language == "EN") {
        return llList2String(ATTACK_MESSAGES_EN, llFloor(llFrand(llGetListLength(ATTACK_MESSAGES_EN))));
    } else {
        return llList2String(ATTACK_MESSAGES_ES, llFloor(llFrand(llGetListLength(ATTACK_MESSAGES_ES))));
    }
}

// Función para alternar el modo defensa
toggleDefenseMode() {
    isDefending = !isDefending;
    
    if (isDefending) {
        say(getText(DEFENSE_ON_TEXT));
        // Iniciar animación de defensa
        llStartAnimation(defendAnimation);
    } else {
        say(getText(DEFENSE_OFF_TEXT));
        // Detener animación de defensa
        llStopAnimation(defendAnimation);
    }
}

// Función para cambiar el tipo de arma
changeWeapon() {
    list weapons = ["Sable", "Pistola", "Daga", "Puños"];
    list damages = [20, 30, 15, 10];
    list anims = ["saber", "pistol", "dagger", "punch"];
    
    // Encontrar el índice del arma actual
    integer currentIndex = llListFindList(weapons, [weaponType]);
    
    // Cambiar al siguiente arma en la lista
    integer nextIndex = (currentIndex + 1) % llGetListLength(weapons);
    weaponType = llList2String(weapons, nextIndex);
    baseDamage = llList2Integer(damages, nextIndex);
    attackAnimation = llList2String(anims, nextIndex);
    
    say("Arma cambiada a: " + weaponType + " (Daño base: " + (string)baseDamage + ")");
}

// Función para procesar un ataque recibido
processIncomingAttack(key attackerID, integer damage, string message) {
    // Aplicar reducción de daño si está en modo defensa
    if (isDefending) {
        damage = (integer)(damage * (1.0 - defenseBonus));
    }
    
    // Notificar al jugador sobre el ataque
    string attackerName = llGetDisplayName(attackerID);
    say(getText(YOU_WERE_ATTACKED_TEXT) + attackerName + "!\n" + 
        message + "\n" + 
        getText(DAMAGE_TEXT) + (string)damage);
    
    // No necesitamos enviar una solicitud HTTP aquí, ya que el atacante lo hace
}

default {
    state_entry() {
        // Inicializar el sistema de combate
        say("Inicializando Sistema de Combate Imperial...");
        initialize();
    }
    
    touch_start(integer total_number) {
        // Mostrar el menú de combate al tocar
        showCombatMenu();
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == MENU_CHANNEL && id == ownerID) {
            // Procesar selecciones del menú de combate
            if (message == getText(ATTACK_TEXT)) {
                // Si no hay objetivos escaneados, buscar primero
                if (llGetListLength(nearbyPlayers) == 0) {
                    scanTargets();
                    return;
                }
                showTargetMenu();
            } else if (message == getText(DEFEND_TEXT)) {
                toggleDefenseMode();
            } else if (message == getText(SCAN_TEXT)) {
                scanTargets();
            } else if (message == getText(WEAPON_TEXT)) {
                changeWeapon();
                showCombatMenu();
            } else if (message == getText(CLOSE_TEXT)) {
                // No hacer nada, simplemente cerrar el menú
            } else if (llListFindList(nearbyPlayers, [message]) != -1) {
                // El mensaje es un nombre de jugador de la lista de objetivos
                attackTarget(message);
            }
        } else if (channel == COMBAT_CHANNEL) {
            // Procesar mensajes de combate
            list parts = llParseString2List(message, ["|"], []);
            if (llGetListLength(parts) >= 4) {
                string command = llList2String(parts, 0);
                key senderID = (key)llList2String(parts, 1);
                key targetID = (key)llList2String(parts, 2);
                
                // Solo procesar si somos el objetivo
                if (command == "ATTACK" && targetID == ownerID) {
                    integer damage = (integer)llList2String(parts, 3);
                    string attackMessage = "";
                    if (llGetListLength(parts) >= 5) {
                        attackMessage = llList2String(parts, 4);
                    }
                    processIncomingAttack(senderID, damage, attackMessage);
                }
            }
        }
    }
    
    timer() {
        // Manejar el tiempo de espera entre ataques
        static integer cooldownRemaining = 0;
        
        if (!canAttack) {
            if (cooldownRemaining == 0) {
                cooldownRemaining = (integer)COOLDOWN_TIME;
            }
            
            cooldownRemaining--;
            
            if (cooldownRemaining <= 0) {
                canAttack = TRUE;
                cooldownRemaining = 0;
                llSetTimerEvent(0.0); // Detener el temporizador
                say("¡Listo para atacar nuevamente!");
            } else {
                string timeText;
                if (cooldownRemaining == 1) {
                    timeText = getText(SECOND_TEXT);
                } else {
                    timeText = getText(SECONDS_TEXT);
                }
                // Actualizar cada 5 segundos para no spam
                if (cooldownRemaining % 5 == 0 || cooldownRemaining <= 3) {
                    say(getText(COOLDOWN_TEXT) + (string)cooldownRemaining + " " + timeText);
                }
            }
        }
    }
    
    sensor(integer num_detected) {
        // Procesar resultados del sensor
        integer i;
        for (i = 0; i < num_detected; ++i) {
            key id = llDetectedKey(i);
            
            // No incluir al propietario en la lista
            if (id != ownerID) {
                string detectedName = llDetectedName(i);
                
                // Añadir a las listas si no está ya
                if (llListFindList(nearbyPlayerIDs, [(string)id]) == -1) {
                    nearbyPlayers += [detectedName];
                    nearbyPlayerIDs += [(string)id];
                }
            }
        }
        
        if (llGetListLength(nearbyPlayers) > 0) {
            say("Objetivos encontrados: " + (string)llGetListLength(nearbyPlayers));
            showTargetMenu();
        } else {
            say(getText(NO_TARGETS_TEXT));
            showCombatMenu();
        }
    }
    
    no_sensor() {
        say(getText(NO_TARGETS_TEXT));
        showCombatMenu();
    }
    
    http_response(key request_id, integer status, list metadata, string body) {
        if (request_id != HTTP_REQUEST_ID) return;
        
        if (status != 200) {
            say("Error al comunicarse con el servidor: " + (string)status);
            return;
        }
        
        // Analizar la respuesta JSON si es necesario
        // Por ejemplo, confirmar si el daño se aplicó correctamente
        if (llJsonValueType(body, ["success"]) == JSON_TRUE) {
            // Ataque exitoso, ya hemos mostrado el mensaje
        } else {
            say(getText(ATTACK_FAIL_TEXT));
        }
    }
}