// Imperial Russian Court RP - HUD Básico
// Sistema modular independiente sin conexión externa
// Almacenamiento local mediante notecards

// Canales de comunicación
integer MAIN_MENU_CHANNEL;
integer PROFILE_CHANNEL;
integer STATS_CHANNEL;
integer ACTIONS_CHANNEL;
integer SOCIAL_CHANNEL;
integer SETTINGS_CHANNEL;
integer METER_CHANNEL = -1000001; // Canal de comunicación con el medidor

// Variables del jugador - Datos personales
string playerFirstName;
string playerLastName;
string playerFamily;
string playerClass;
string playerProfession;
string playerPolitics;
string playerGender;
integer playerAge;
string playerLanguage = "ES"; // Predeterminado Español (ES o EN)
integer playerRank = 0;       // 0=Commoner, 1+=Noble ranks

// Variables del jugador - Estadísticas
integer playerHealth = 100;
integer playerInfluence = 10;
integer playerRubles = 100;
integer playerWealth = 10;
integer playerCharm = 10;
integer playerPopularity = 10;
integer playerLove = 10;
integer playerLoyalty = 10;
integer playerFaith = 10;
integer playerXP = 0;

// Estados del jugador
integer isInComa = FALSE;
integer isDead = FALSE;
string healthStatus = "Healthy";

// Variables de control
key ownerID;
integer listenHandle;
integer hudVisible = TRUE;
integer meterActive = TRUE;
integer lastStatUpdateTime;
integer STAT_UPDATE_INTERVAL = 3600; // Segundos entre actualizaciones automáticas
string currentMenu = "MAIN";
string lastAction = "";

// Inicialización de canales para evitar interferencias
initializeChannels() {
    integer baseChannel = -1000000 - (integer)llFrand(999999);
    MAIN_MENU_CHANNEL = baseChannel;
    PROFILE_CHANNEL = baseChannel - 1;
    STATS_CHANNEL = baseChannel - 2;
    ACTIONS_CHANNEL = baseChannel - 3;
    SOCIAL_CHANNEL = baseChannel - 4;
    SETTINGS_CHANNEL = baseChannel - 5;
}

// Leer datos de la notecard
string notecardName;
key notecardQueryId;
integer notecardLine;

readNotecard() {
    if (llGetInventoryNumber(INVENTORY_NOTECARD) > 0) {
        notecardName = llGetInventoryName(INVENTORY_NOTECARD, 0);
        if (notecardName != "") {
            // Iniciar lectura de la notecard
            notecardLine = 0;
            notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
            llOwnerSay("Leyendo datos de personaje...");
        }
    }
    else {
        string noCardMsg = (playerLanguage == "ES") ? 
            "⚠️ No hay datos de personaje. Coloque la notecard de registro en el HUD." :
            "⚠️ No character data found. Please place your registration notecard in the HUD.";
        llOwnerSay(noCardMsg);
    }
}

// Actualizar el medidor con las estadísticas
updateMeter() {
    if (!meterActive) return;
    
    // Preparar datos para el medidor en formato estándar
    string meterData = "STATS_DATA:";
    
    // Formato: firstName||lastName||family||class||profession||politics||health||influence||rubles||wealth||charm||popularity||love||loyalty||faith||xp||gender||age||status
    meterData += playerFirstName + "||" + 
                playerLastName + "||" + 
                playerFamily + "||" + 
                playerClass + "||" + 
                playerProfession + "||" + 
                playerPolitics + "||" + 
                (string)playerHealth + "||" + 
                (string)playerInfluence + "||" + 
                (string)playerRubles + "||" + 
                (string)playerWealth + "||" + 
                (string)playerCharm + "||" + 
                (string)playerPopularity + "||" + 
                (string)playerLove + "||" + 
                (string)playerLoyalty + "||" + 
                (string)playerFaith + "||" + 
                (string)playerXP + "||" + 
                playerGender + "||" + 
                (string)playerAge + "||" + 
                healthStatus;
    
    // Enviar datos al canal del medidor
    llRegionSay(METER_CHANNEL, meterData);
}

// Actualización periódica de estadísticas
updateStats() {
    // Solo actualiza si el personaje está vivo y no en coma
    if (!isDead && !isInComa) {
        integer currentTime = llGetUnixTime();
        if ((currentTime - lastStatUpdateTime) >= STAT_UPDATE_INTERVAL) {
            // Actualizar estadísticas basadas en la situación
            // Por ejemplo, reducir salud si está baja en riqueza (comida)
            if (playerWealth < 5 && playerHealth > 0) {
                playerHealth -= 5;
                string healthMsg = (playerLanguage == "ES") ? 
                    "Tu salud ha disminuido debido a tu baja riqueza (necesidades básicas no cubiertas)." :
                    "Your health has decreased due to your low wealth (basic needs not covered).";
                llOwnerSay(healthMsg);
            }
            
            // Penalizar popularidad si la lealtad es muy baja
            if (playerLoyalty < 5 && playerPopularity > 0) {
                playerPopularity -= 3;
                string loyaltyMsg = (playerLanguage == "ES") ? 
                    "Tu popularidad ha disminuido por ser visto como desleal al régimen." :
                    "Your popularity has decreased for being seen as disloyal to the regime.";
                llOwnerSay(loyaltyMsg);
            }
            
            // Aumentar un poco de XP por simplemente estar activo
            playerXP += 1;
            
            // Actualizar estado de salud
            updateHealthStatus();
            
            // Actualizar el tiempo de la última actualización
            lastStatUpdateTime = currentTime;
            
            // Actualizar el medidor
            updateMeter();
        }
    }
}

// Actualizar estado de salud basado en puntos de salud
updateHealthStatus() {
    string oldStatus = healthStatus;
    
    if (playerHealth >= 90) {
        healthStatus = (playerLanguage == "ES") ? "Excelente" : "Excellent";
    }
    else if (playerHealth >= 70) {
        healthStatus = (playerLanguage == "ES") ? "Saludable" : "Healthy";
    }
    else if (playerHealth >= 50) {
        healthStatus = (playerLanguage == "ES") ? "Bien" : "Well";
    }
    else if (playerHealth >= 30) {
        healthStatus = (playerLanguage == "ES") ? "Débil" : "Weak";
    }
    else if (playerHealth >= 10) {
        healthStatus = (playerLanguage == "ES") ? "Enfermo" : "Sick";
    }
    else if (playerHealth > 0) {
        healthStatus = (playerLanguage == "ES") ? "Crítico" : "Critical";
    }
    else {
        // Salud llegó a 0 o menos
        playerHealth = 0;
        healthStatus = (playerLanguage == "ES") ? "Coma" : "Coma";
        isInComa = TRUE;
        
        string comaMsg = (playerLanguage == "ES") ? 
            "⚠️ Has entrado en coma debido a tu salud crítica. Busca asistencia médica." :
            "⚠️ You have fallen into a coma due to critical health. Seek medical assistance.";
        llOwnerSay(comaMsg);
    }
    
    // Notificar cambio de estado si ocurrió
    if (oldStatus != healthStatus) {
        string statusMsg = (playerLanguage == "ES") ? 
            "Tu estado de salud ha cambiado a: " + healthStatus :
            "Your health status has changed to: " + healthStatus;
        llOwnerSay(statusMsg);
    }
}

// Función para curar al jugador
healPlayer(integer amount) {
    if (!isDead) {
        playerHealth += amount;
        if (playerHealth > 100) playerHealth = 100;
        
        if (isInComa && playerHealth > 20) {
            isInComa = FALSE;
            string recoverMsg = (playerLanguage == "ES") ? 
                "🎉 Has salido del coma y estás recuperándote." :
                "🎉 You have awakened from the coma and are recovering.";
            llOwnerSay(recoverMsg);
        }
        
        updateHealthStatus();
        updateMeter();
    }
}

// Función para dañar al jugador
damagePlayer(integer amount) {
    if (!isDead && !isInComa) {
        playerHealth -= amount;
        
        updateHealthStatus(); // Esto verificará si entró en coma
        updateMeter();
    }
}

// Mostrar menú principal del HUD
showMainMenu() {
    currentMenu = "MAIN";
    
    string menuText = (playerLanguage == "ES") ? 
        "\n=== MENÚ PRINCIPAL ===\n\n" +
        "Seleccione una opción:" :
        "\n=== MAIN MENU ===\n\n" +
        "Select an option:";
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Perfil", "Estadísticas", "Acciones", "Social", "Módulos", "Configuración"];
    } else {
        buttons = ["Profile", "Statistics", "Actions", "Social", "Modules", "Settings"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(MAIN_MENU_CHANNEL, "", ownerID, "");
    llDialog(ownerID, menuText, buttons, MAIN_MENU_CHANNEL);
}

// Mostrar menú de perfil
showProfileMenu() {
    currentMenu = "PROFILE";
    
    string profileText;
    
    if (playerLanguage == "ES") {
        profileText = "\n=== PERFIL ===\n\n";
        profileText += "Nombre: " + playerFirstName + " " + playerLastName + "\n";
        profileText += "Familia: " + playerFamily + "\n";
        profileText += "Clase: " + playerClass + "\n";
        profileText += "Profesión: " + playerProfession + "\n";
        profileText += "Política: " + playerPolitics + "\n";
        profileText += "Género: " + playerGender + "\n";
        profileText += "Edad: " + (string)playerAge + " años\n";
    } else {
        profileText = "\n=== PROFILE ===\n\n";
        profileText += "Name: " + playerFirstName + " " + playerLastName + "\n";
        profileText += "Family: " + playerFamily + "\n";
        profileText += "Class: " + playerClass + "\n";
        profileText += "Profession: " + playerProfession + "\n";
        profileText += "Politics: " + playerPolitics + "\n";
        profileText += "Gender: " + playerGender + "\n";
        profileText += "Age: " + (string)playerAge + " years\n";
    }
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Volver"];
    } else {
        buttons = ["Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(PROFILE_CHANNEL, "", ownerID, "");
    llDialog(ownerID, profileText, buttons, PROFILE_CHANNEL);
}

// Mostrar menú de estadísticas
showStatsMenu() {
    currentMenu = "STATS";
    
    string statsText;
    
    if (playerLanguage == "ES") {
        statsText = "\n=== ESTADÍSTICAS ===\n\n";
        statsText += "❤️ Salud: " + (string)playerHealth + "/100 (" + healthStatus + ")\n";
        statsText += "🏛️ Influencia: " + (string)playerInfluence + "/100\n";
        statsText += "💰 Rublos: " + (string)playerRubles + "\n";
        statsText += "👑 Riqueza: " + (string)playerWealth + "/100\n";
        statsText += "✨ Encanto: " + (string)playerCharm + "/100\n";
        statsText += "👥 Popularidad: " + (string)playerPopularity + "/100\n";
        statsText += "❣️ Amor: " + (string)playerLove + "/100\n";
        statsText += "⚜️ Lealtad: " + (string)playerLoyalty + "/100\n";
        statsText += "✝️ Fe: " + (string)playerFaith + "/100\n";
        statsText += "⭐ Experiencia: " + (string)playerXP + "\n";
    } else {
        statsText = "\n=== STATISTICS ===\n\n";
        statsText += "❤️ Health: " + (string)playerHealth + "/100 (" + healthStatus + ")\n";
        statsText += "🏛️ Influence: " + (string)playerInfluence + "/100\n";
        statsText += "💰 Rubles: " + (string)playerRubles + "\n";
        statsText += "👑 Wealth: " + (string)playerWealth + "/100\n";
        statsText += "✨ Charm: " + (string)playerCharm + "/100\n";
        statsText += "👥 Popularity: " + (string)playerPopularity + "/100\n";
        statsText += "❣️ Love: " + (string)playerLove + "/100\n";
        statsText += "⚜️ Loyalty: " + (string)playerLoyalty + "/100\n";
        statsText += "✝️ Faith: " + (string)playerFaith + "/100\n";
        statsText += "⭐ Experience: " + (string)playerXP + "\n";
    }
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Mostrar Medidor", "Ocultar Medidor", "Volver"];
    } else {
        buttons = ["Show Meter", "Hide Meter", "Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(STATS_CHANNEL, "", ownerID, "");
    llDialog(ownerID, statsText, buttons, STATS_CHANNEL);
}

// Mostrar menú de acciones
showActionsMenu() {
    currentMenu = "ACTIONS";
    
    string actionText = (playerLanguage == "ES") ? 
        "\n=== ACCIONES ===\n\n" +
        "Seleccione una acción para realizar:" :
        "\n=== ACTIONS ===\n\n" +
        "Select an action to perform:";
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Saludar", "Reverencia", "Inclinar Cabeza", "Aplaudir", "Asentir", "Negar"];
        buttons += ["Militar", "Mirar Reloj", "Volver"];
    } else {
        buttons = ["Greet", "Bow", "Nod Head", "Applaud", "Agree", "Deny"];
        buttons += ["Military", "Check Watch", "Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(ACTIONS_CHANNEL, "", ownerID, "");
    llDialog(ownerID, actionText, buttons, ACTIONS_CHANNEL);
}

// Mostrar menú social
showSocialMenu() {
    currentMenu = "SOCIAL";
    
    string socialText = (playerLanguage == "ES") ? 
        "\n=== INTERACCIÓN SOCIAL ===\n\n" +
        "Seleccione una interacción:" :
        "\n=== SOCIAL INTERACTION ===\n\n" +
        "Select an interaction:";
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Presentarse", "Cotillear", "Adular", "Coquetear", "Insultar", "Desafiar"];
        buttons += ["Debatir", "Enseñar", "Volver"];
    } else {
        buttons = ["Introduce", "Gossip", "Compliment", "Flirt", "Insult", "Challenge"];
        buttons += ["Debate", "Teach", "Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(SOCIAL_CHANNEL, "", ownerID, "");
    llDialog(ownerID, socialText, buttons, SOCIAL_CHANNEL);
}

// Mostrar menú de módulos
showModulesMenu() {
    currentMenu = "MODULES";
    
    string modulesText = (playerLanguage == "ES") ? 
        "\n=== MÓDULOS ===\n\n" +
        "Seleccione un módulo para interactuar:" :
        "\n=== MODULES ===\n\n" +
        "Select a module to interact with:";
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Economía", "Salud", "Política", "Familia", "Relaciones", "Sociedad"];
        buttons += ["Volver"];
    } else {
        buttons = ["Economy", "Health", "Politics", "Family", "Relationships", "Society"];
        buttons += ["Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(MAIN_MENU_CHANNEL, "", ownerID, "");
    llDialog(ownerID, modulesText, buttons, MAIN_MENU_CHANNEL);
}

// Mostrar menú de configuración
showSettingsMenu() {
    currentMenu = "SETTINGS";
    
    string settingsText = (playerLanguage == "ES") ? 
        "\n=== CONFIGURACIÓN ===\n\n" +
        "Seleccione una opción:" :
        "\n=== SETTINGS ===\n\n" +
        "Select an option:";
    
    list buttons;
    
    if (playerLanguage == "ES") {
        buttons = ["Español ➔ English", "Recargar Datos", "Reiniciar HUD", "Acerca de", "Volver"];
    } else {
        buttons = ["English ➔ Español", "Reload Data", "Reset HUD", "About", "Back"];
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(SETTINGS_CHANNEL, "", ownerID, "");
    llDialog(ownerID, settingsText, buttons, SETTINGS_CHANNEL);
}

// Ejecutar acción social (RP)
doAction(string action) {
    string actionText;
    
    // Acciones básicas
    if (action == "Saludar" || action == "Greet") {
        if (playerClass == "Aristocracia") {
            if (playerGender == "Masculino" || playerGender == "Male") {
                actionText = playerFirstName + " " + playerLastName + " hace un elegante saludo cortesano.";
            } else {
                actionText = playerFirstName + " " + playerLastName + " hace una refinada reverencia de corte.";
            }
        } else {
            actionText = playerFirstName + " " + playerLastName + " saluda respetuosamente.";
        }
    }
    else if (action == "Reverencia" || action == "Bow") {
        if (playerGender == "Masculino" || playerGender == "Male") {
            actionText = playerFirstName + " hace una profunda reverencia.";
        } else {
            actionText = playerFirstName + " hace una grácil reverencia.";
        }
    }
    else if (action == "Inclinar Cabeza" || action == "Nod Head") {
        actionText = playerFirstName + " inclina levemente la cabeza en señal de reconocimiento.";
    }
    else if (action == "Aplaudir" || action == "Applaud") {
        actionText = playerFirstName + " aplaude con elegante entusiasmo.";
    }
    else if (action == "Asentir" || action == "Agree") {
        actionText = playerFirstName + " asiente, mostrando su acuerdo.";
    }
    else if (action == "Negar" || action == "Deny") {
        actionText = playerFirstName + " niega sutilmente con la cabeza.";
    }
    else if (action == "Militar" || action == "Military") {
        if (playerClass == "Militares") {
            actionText = playerFirstName + " " + playerLastName + " realiza un formal saludo militar.";
        } else {
            actionText = playerFirstName + " " + playerLastName + " intenta un poco torpe saludo militar.";
        }
    }
    else if (action == "Mirar Reloj" || action == "Check Watch") {
        actionText = playerFirstName + " consulta discretamente su reloj de bolsillo.";
        if (playerGender != "Masculino" && playerGender != "Male") {
            actionText = playerFirstName + " mira discretamente su pequeño reloj colgante.";
        }
    }
    
    // Acciones sociales
    else if (action == "Presentarse" || action == "Introduce") {
        if (playerRank > 0) {
            actionText = playerFirstName + " " + playerLastName + " se presenta formalmente como miembro de la familia " + playerFamily + ".";
        } else {
            actionText = playerFirstName + " " + playerLastName + " se presenta como " + playerProfession + ".";
        }
    }
    else if (action == "Cotillear" || action == "Gossip") {
        actionText = playerFirstName + " susurra algunas palabras sobre los últimos cotilleos de la corte.";
        // Pequeño aumento de popularidad
        playerPopularity += 1;
        if (playerPopularity > 100) playerPopularity = 100;
    }
    else if (action == "Adular" || action == "Compliment") {
        actionText = playerFirstName + " ofrece un elegante cumplido.";
        // Pequeño aumento de encanto
        playerCharm += 1;
        if (playerCharm > 100) playerCharm = 100;
    }
    else if (action == "Coquetear" || action == "Flirt") {
        actionText = playerFirstName + " coquetea de manera sutil y refinada.";
        // Pequeño aumento de amor
        playerLove += 1;
        if (playerLove > 100) playerLove = 100;
    }
    else if (action == "Insultar" || action == "Insult") {
        actionText = playerFirstName + " lanza una velada crítica, apenas disimulada como una observación.";
        // Pequeña disminución de popularidad
        playerPopularity -= 1;
        if (playerPopularity < 0) playerPopularity = 0;
    }
    else if (action == "Desafiar" || action == "Challenge") {
        actionText = playerFirstName + " " + playerLastName + " lanza un desafío formal!";
    }
    else if (action == "Debatir" || action == "Debate") {
        actionText = playerFirstName + " comienza un acalorado debate sobre asuntos de actualidad.";
        // Pequeño aumento de influencia
        playerInfluence += 1;
        if (playerInfluence > 100) playerInfluence = 100;
    }
    else if (action == "Enseñar" || action == "Teach") {
        actionText = playerFirstName + " explica con paciencia un concepto o tradición.";
        // Pequeño aumento de XP
        playerXP += 2;
    }
    
    // Enviar la acción al chat local
    llSay(0, actionText);
    
    // Actualizar medidor después de acciones sociales
    updateMeter();
}

default {
    state_entry() {
        // Guardar UUID del propietario para seguridad
        ownerID = llGetOwner();
        
        // Inicializar canales de comunicación
        initializeChannels();
        
        // Inicializar tiempo de última actualización
        lastStatUpdateTime = llGetUnixTime();
        
        // Configurar listener para menús
        llListenRemove(listenHandle);
        listenHandle = llListen(MAIN_MENU_CHANNEL, "", ownerID, "");
        
        // Leer datos de la notecard si está disponible
        readNotecard();
        
        // Mensaje de bienvenida
        llOwnerSay("=== Imperial Russian Court RP - HUD Básico ===");
        llOwnerSay("Toque el HUD para acceder al menú principal");
        
        // Iniciar timer para actualizaciones periódicas
        llSetTimerEvent(60.0); // Revisar cada minuto
    }
    
    touch_start(integer total_number) {
        key id = llDetectedKey(0);
        if (id == ownerID) {
            showMainMenu();
        }
    }
    
    dataserver(key queryId, string data) {
        if (queryId == notecardQueryId) {
            if (data != EOF) {
                // Procesar la línea de la notecard
                if (llSubStringIndex(data, "//") != 0 && data != "") {
                    // Dividir la línea en clave=valor
                    list parts = llParseString2List(data, ["="], []);
                    if (llGetListLength(parts) == 2) {
                        string key = llList2String(parts, 0);
                        string value = llList2String(parts, 1);
                        
                        // Asignar valores según la clave
                        if (key == "FIRST_NAME") playerFirstName = value;
                        else if (key == "LAST_NAME") playerLastName = value;
                        else if (key == "FAMILY") playerFamily = value;
                        else if (key == "CLASS") playerClass = value;
                        else if (key == "PROFESSION") playerProfession = value;
                        else if (key == "POLITICS") playerPolitics = value;
                        else if (key == "GENDER") playerGender = value;
                        else if (key == "AGE") playerAge = (integer)value;
                        else if (key == "LANGUAGE") playerLanguage = value;
                        else if (key == "RANK") playerRank = (integer)value;
                        else if (key == "HEALTH") playerHealth = (integer)value;
                        else if (key == "INFLUENCE") playerInfluence = (integer)value;
                        else if (key == "RUBLES") playerRubles = (integer)value;
                        else if (key == "WEALTH") playerWealth = (integer)value;
                        else if (key == "CHARM") playerCharm = (integer)value;
                        else if (key == "POPULARITY") playerPopularity = (integer)value;
                        else if (key == "LOVE") playerLove = (integer)value;
                        else if (key == "LOYALTY") playerLoyalty = (integer)value;
                        else if (key == "FAITH") playerFaith = (integer)value;
                        else if (key == "XP") playerXP = (integer)value;
                    }
                }
                
                // Solicitar la siguiente línea
                notecardLine++;
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
            }
            else {
                // Finalizar lectura de la notecard
                updateHealthStatus();
                
                // Mensaje de confirmación
                string loadMsg = (playerLanguage == "ES") ? 
                    "Datos cargados para: " + playerFirstName + " " + playerLastName :
                    "Data loaded for: " + playerFirstName + " " + playerLastName;
                llOwnerSay(loadMsg);
                
                // Enviar datos al medidor
                updateMeter();
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (id != ownerID) return;
        
        // Menú principal
        if (channel == MAIN_MENU_CHANNEL) {
            if (message == "Perfil" || message == "Profile") {
                showProfileMenu();
            }
            else if (message == "Estadísticas" || message == "Statistics") {
                showStatsMenu();
            }
            else if (message == "Acciones" || message == "Actions") {
                showActionsMenu();
            }
            else if (message == "Social") {
                showSocialMenu();
            }
            else if (message == "Módulos" || message == "Modules") {
                showModulesMenu();
            }
            else if (message == "Configuración" || message == "Settings") {
                showSettingsMenu();
            }
            // Opciones del menú de módulos
            else if (message == "Economía" || message == "Economy") {
                llOwnerSay("Módulo de Economía - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Salud" || message == "Health") {
                llOwnerSay("Módulo de Salud - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Política" || message == "Politics") {
                llOwnerSay("Módulo de Política - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Familia" || message == "Family") {
                llOwnerSay("Módulo de Familia - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Relaciones" || message == "Relationships") {
                llOwnerSay("Módulo de Relaciones - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Sociedad" || message == "Society") {
                llOwnerSay("Módulo de Sociedad - No implementado en HUD básico");
                showModulesMenu();
            }
            else if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
        }
        // Menú de perfil
        else if (channel == PROFILE_CHANNEL) {
            if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
        }
        // Menú de estadísticas
        else if (channel == STATS_CHANNEL) {
            if (message == "Mostrar Medidor" || message == "Show Meter") {
                meterActive = TRUE;
                updateMeter();
                string meterMsg = (playerLanguage == "ES") ? 
                    "Medidor de estadísticas activado." :
                    "Statistics meter enabled.";
                llOwnerSay(meterMsg);
            }
            else if (message == "Ocultar Medidor" || message == "Hide Meter") {
                meterActive = FALSE;
                llRegionSay(METER_CHANNEL, "HIDE_STATS");
                string meterMsg = (playerLanguage == "ES") ? 
                    "Medidor de estadísticas desactivado." :
                    "Statistics meter disabled.";
                llOwnerSay(meterMsg);
            }
            else if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
        }
        // Menú de acciones
        else if (channel == ACTIONS_CHANNEL) {
            if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
            else {
                // Ejecutar la acción seleccionada
                doAction(message);
            }
        }
        // Menú social
        else if (channel == SOCIAL_CHANNEL) {
            if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
            else {
                // Ejecutar la acción social seleccionada
                doAction(message);
            }
        }
        // Menú de configuración
        else if (channel == SETTINGS_CHANNEL) {
            if (message == "Español ➔ English") {
                playerLanguage = "EN";
                llOwnerSay("Language changed to English.");
                showSettingsMenu();
            }
            else if (message == "English ➔ Español") {
                playerLanguage = "ES";
                llOwnerSay("Idioma cambiado a Español.");
                showSettingsMenu();
            }
            else if (message == "Recargar Datos" || message == "Reload Data") {
                readNotecard();
                showSettingsMenu();
            }
            else if (message == "Reiniciar HUD" || message == "Reset HUD") {
                string resetMsg = (playerLanguage == "ES") ? 
                    "Reiniciando HUD..." :
                    "Resetting HUD...";
                llOwnerSay(resetMsg);
                llResetScript();
            }
            else if (message == "Acerca de" || message == "About") {
                string aboutMsg = (playerLanguage == "ES") ? 
                    "HUD Básico de la Corte Imperial Rusa\nVersión 1.0\n\nSistema modular sin conexión externa." :
                    "Imperial Russian Court Basic HUD\nVersion 1.0\n\nModular system without external connection.";
                llOwnerSay(aboutMsg);
                showSettingsMenu();
            }
            else if (message == "Volver" || message == "Back") {
                showMainMenu();
            }
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_INVENTORY) {
            // Volver a leer la notecard si el inventario cambia
            readNotecard();
        }
        else if (change & CHANGED_OWNER) {
            // Reiniciar si cambia el propietario
            llResetScript();
        }
    }
    
    timer() {
        // Actualizar estadísticas periódicamente
        updateStats();
    }
    
    on_rez(integer start_param) {
        // Reiniciar al ser creado
        llResetScript();
    }
}