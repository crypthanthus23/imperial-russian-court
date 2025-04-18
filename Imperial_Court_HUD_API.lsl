// Imperial Court HUD - API Connected Version
// Este script maneja la interfaz del HUD y la comunicación con la API

// Configuración y variables globales
string API_URL = "https://imperial-russian-court-rp.replit.app"; // URL de producción en Replit
string PLAYER_ID = ""; // Se establecerá al iniciar
integer gChannel = -12345; // Canal para comunicación
integer gMenuChannel; // Canal para menús
integer gMenuListen;
integer gDebug = TRUE; // Modo depuración
integer gMeterChannel = -987654321; // Canal para comunicación con el Meter

// Información del jugador
string gRpName = "";
string gRpSurname = "";
string gSocialClass = "";
string gProfession = "";
string gPoliticalFaction = "";
string gGender = "";
string gLanguage = "ES"; // Por defecto español

// HTTP request IDs
key gPlayerId;
key gPlayerDataRequest;
key gPlayerDamageRequest;
key gPlayerHealRequest;
key gPlayerReviveRequest;

// Estado de juego
integer gInSetupMode = TRUE;
integer gAwaitingCharacterCreation = FALSE;

// Funciones de ayuda
sayDebug(string msg)
{
    if(gDebug)
        llOwnerSay("DEBUG: " + msg);
}

showCharacterCreationMenu()
{
    gAwaitingCharacterCreation = TRUE;
    llDialog(llGetOwner(), "Por favor, seleccione una opción para comenzar a crear su personaje:", 
             ["Nombre", "Apellido", "Clase Social", "Facción Política", "Profesión", "Género", "Idioma", "Guardar"], 
             gMenuChannel);
}

updateMeter()
{
    // Enviar actualización al Meter
    string playerInfo = llList2CSV([
        gRpName,
        gRpSurname,
        gSocialClass,
        gProfession,
        gPoliticalFaction,
        gGender,
        gLanguage
    ]);
    
    // Enviar datos al Meter a través del canal
    llRegionSay(gMeterChannel, "UPDATE|" + playerInfo);
    
    // También actualizar el texto flotante del HUD
    string displayText = "";
    
    // Solo mostrar el texto si tenemos datos
    if(gRpName != "" && gRpSurname != "") {
        displayText = gRpName + " " + gRpSurname + "\n";
        
        if(gSocialClass != "") {
            displayText += gSocialClass;
            
            if(gProfession != "") {
                displayText += " - " + gProfession;
            }
        }
        
        if(gPoliticalFaction != "") {
            displayText += "\n" + gPoliticalFaction;
        }
        
        // Actualizar el texto flotante con la información del personaje
        llSetText(displayText, <1.0, 0.8, 0.6>, 1.0);
    } else {
        // Si no hay datos, mostrar mensaje predeterminado
        llSetText("Imperial Court HUD\nToque aquí", <1.0, 0.8, 0.6>, 1.0);
    }
}

default
{
    state_entry()
    {
        // Inicialización
        PLAYER_ID = (string)llGetOwner(); // Usar UUID del usuario como ID
        gMenuChannel = (integer)("0x" + llGetSubString(llGetOwner(), 0, 8)) - 42; // Canal único basado en UUID
        
        // Preparar escucha
        llListen(gChannel, "", NULL_KEY, "");
        gMenuListen = llListen(gMenuChannel, "", NULL_KEY, "");
        
        llOwnerSay("HUD de la Corte Imperial inicializado.");
        llOwnerSay("Toque el HUD para comenzar.");
        llSetText("Imperial Court HUD\nToque aquí", <1.0, 0.8, 0.6>, 1.0);
        
        // Verificar si ya existe el jugador
        gPlayerId = llHTTPRequest(API_URL + "/api/player/" + PLAYER_ID, 
                                 [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json"], 
                                 "");
    }
    
    touch_start(integer total_number)
    {
        // Mostrar menú principal
        if(gInSetupMode) {
            llDialog(llGetOwner(), "Bienvenido al sistema de la Corte Imperial Rusa\nPor favor, seleccione una opción:", 
                     ["Crear Personaje", "Info"], gMenuChannel);
        } else {
            // Configurar texto del botón de debug sin usar operador ternario
            string debugButton = "Debug ";
            if(gDebug) {
                debugButton = debugButton + "OFF";
            } else {
                debugButton = debugButton + "ON";
            }
            
            llDialog(llGetOwner(), "Menú Principal de la Corte Imperial\nSeleccione una opción:", 
                     ["Perfil", "Acciones", "Configuración", debugButton], 
                     gMenuChannel);
        }
    }
    
    listen(integer channel, string user_sender_name, key id, string message)
    {
        if(id != llGetOwner()) return;
        
        if(channel == gMenuChannel) {
            if(message == "Crear Personaje") {
                showCharacterCreationMenu();
            }
            else if(message == "Info") {
                llOwnerSay("Sistema de Corte Imperial Rusa 1905\nDesarrollado para Second Life\nConexión API: " + API_URL);
            }
            else if(message == "Debug ON") {
                gDebug = TRUE;
                llOwnerSay("Modo depuración activado");
            }
            else if(message == "Debug OFF") {
                gDebug = FALSE;
                llOwnerSay("Modo depuración desactivado");
            }
            else if(message == "Perfil") {
                // Solicitar datos actualizados
                gPlayerDataRequest = llHTTPRequest(API_URL + "/api/player/" + PLAYER_ID, 
                                                 [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json"], 
                                                 "");
            }
            else if(message == "Acciones") {
                llDialog(llGetOwner(), "¿Qué acción desea realizar?", 
                         ["Recibir Daño", "Curación", "Revivir", "Volver"], 
                         gMenuChannel);
            }
            else if(message == "Recibir Daño") {
                gPlayerDamageRequest = llHTTPRequest(API_URL + "/api/player/damage/" + PLAYER_ID, 
                                                   [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], 
                                                   "amount=10");
            }
            else if(message == "Curación") {
                gPlayerHealRequest = llHTTPRequest(API_URL + "/api/player/heal/" + PLAYER_ID, 
                                                 [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], 
                                                 "amount=10");
            }
            else if(message == "Revivir") {
                gPlayerReviveRequest = llHTTPRequest(API_URL + "/api/player/revive/" + PLAYER_ID, 
                                                   [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json"], 
                                                   "");
            }
            else if(message == "Volver") {
                // Volver al menú principal - no podemos llamar a touch_start directamente
                // Mostramos el menú principal manualmente
                if(gInSetupMode) {
                    llDialog(llGetOwner(), "Bienvenido al sistema de la Corte Imperial Rusa\nPor favor, seleccione una opción:", 
                             ["Crear Personaje", "Info"], gMenuChannel);
                } else {
                    // Configurar texto del botón de debug
                    string debugButton = "Debug ";
                    if(gDebug) {
                        debugButton = debugButton + "OFF";
                    } else {
                        debugButton = debugButton + "ON";
                    }
                    
                    llDialog(llGetOwner(), "Menú Principal de la Corte Imperial\nSeleccione una opción:", 
                             ["Perfil", "Acciones", "Configuración", debugButton], 
                             gMenuChannel);
                }
            }
            
            // Procesamiento del menú de creación de personaje
            if(gAwaitingCharacterCreation) {
                if(message == "Nombre") {
                    llTextBox(llGetOwner(), "Por favor, ingrese su nombre (solo el nombre, sin apellido):", gMenuChannel);
                }
                else if(message == "Apellido") {
                    llTextBox(llGetOwner(), "Por favor, ingrese su apellido:", gMenuChannel);
                }
                else if(message == "Clase Social") {
                    // Obtener clases sociales disponibles
                    llHTTPRequest(API_URL + "/api/social_classes", 
                                 [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json"], 
                                 "");
                }
                else if(message == "Facción Política") {
                    // Obtener facciones políticas disponibles
                    llHTTPRequest(API_URL + "/api/political_factions", 
                                 [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json"], 
                                 "");
                }
                else if(message == "Profesión") {
                    // Obtener profesiones disponibles
                    llHTTPRequest(API_URL + "/api/professions", 
                                 [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json"], 
                                 "");
                }
                else if(message == "Género") {
                    llDialog(llGetOwner(), "Seleccione su género:", 
                             ["Masculino", "Femenino"], 
                             gMenuChannel);
                }
                else if(message == "Idioma") {
                    llDialog(llGetOwner(), "Seleccione su idioma preferido:", 
                             ["Español", "English"], 
                             gMenuChannel);
                }
                else if(message == "Guardar") {
                    // Validar que todos los campos necesarios estén completos
                    if(gRpName == "" || gRpSurname == "" || gSocialClass == "" || 
                       gProfession == "" || gPoliticalFaction == "" || gGender == "") {
                        llOwnerSay("Por favor complete todos los campos antes de guardar.");
                        showCharacterCreationMenu();
                        return;
                    }
                    
                    // Crear objeto JSON para enviar
                    string jsonData = "{\"id\": \"" + PLAYER_ID + 
                                     "\", \"rp_name\": \"" + gRpName + 
                                     "\", \"rp_surname\": \"" + gRpSurname + 
                                     "\", \"social_class\": \"" + gSocialClass + 
                                     "\", \"profession\": \"" + gProfession + 
                                     "\", \"political_faction\": \"" + gPoliticalFaction + 
                                     "\", \"gender\": \"" + gGender + 
                                     "\", \"language\": \"" + gLanguage + "\"}";
                    
                    sayDebug("Enviando datos: " + jsonData);
                    
                    // Enviar petición para crear jugador
                    llHTTPRequest(API_URL + "/api/player", 
                                 [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json"], 
                                 jsonData);
                }
                else if(message == "Masculino") {
                    gGender = "Male";
                    llOwnerSay("Género seleccionado: Masculino");
                    showCharacterCreationMenu();
                }
                else if(message == "Femenino") {
                    gGender = "Female";
                    llOwnerSay("Género seleccionado: Femenino");
                    showCharacterCreationMenu();
                }
                else if(message == "Español") {
                    gLanguage = "ES";
                    llOwnerSay("Idioma seleccionado: Español");
                    showCharacterCreationMenu();
                }
                else if(message == "English") {
                    gLanguage = "EN";
                    llOwnerSay("Idioma seleccionado: Inglés");
                    showCharacterCreationMenu();
                }
                else if(llStringLength(message) > 0 && gRpName == "") {
                    // Si no tenemos nombre y recibimos texto, asumimos que es el nombre
                    gRpName = message;
                    llOwnerSay("Nombre establecido: " + gRpName);
                    showCharacterCreationMenu();
                }
                else if(llStringLength(message) > 0 && gRpName != "" && gRpSurname == "") {
                    // Si ya tenemos nombre pero no apellido y recibimos texto, asumimos que es el apellido
                    gRpSurname = message;
                    llOwnerSay("Apellido establecido: " + gRpSurname);
                    showCharacterCreationMenu();
                }
            }
        }
    }
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        // En LSL, todas las variables deben declararse al principio de la función
        // Este es un requisito estricto del lenguaje
        integer start = 0;
        integer end = 0;
        integer i = 0;
        integer pos = 0;
        integer maxOptions = 8;
        integer continuar = TRUE;
        string option = "";
        list options = [];
        
        sayDebug("HTTP Response: Status " + (string)status);
        sayDebug("Body: " + body);
        
        if(status != 200) {
            llOwnerSay("Error de conexión con la API: " + (string)status);
            return;
        }
        
        if(request_id == gPlayerId) {
            // Verificar si el jugador existe
            if(body == "null" || body == "" || body == "{}") {
                llOwnerSay("No se encontró un perfil existente. Por favor cree un nuevo personaje.");
                gInSetupMode = TRUE;
            } else {
                // Jugador existe, parsear datos
                gInSetupMode = FALSE;
                llOwnerSay("Perfil encontrado. ¡Bienvenido de nuevo!");
                
                // Implementar lógica para extraer datos del JSON simplificada con literales directos
                if(llStringIndexOf(body, "rp_name") != -1) {
                    start = llStringIndexOf(body, "rp_name") + 11; // "rp_name":"" (11 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gRpName = llGetSubString(body, start, end - 1);
                }
                
                // Usar literales directos en lugar de variables
                if(llStringIndexOf(body, "rp_surname") != -1) {
                    start = llStringIndexOf(body, "rp_surname") + 14; // "rp_surname":"" (14 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gRpSurname = llGetSubString(body, start, end - 1);
                }
                
                // Extraer clase social
                if(llStringIndexOf(body, "social_class") != -1) {
                    start = llStringIndexOf(body, "social_class") + 16; // "social_class":"" (16 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gSocialClass = llGetSubString(body, start, end - 1);
                }
                
                // Extraer profesión
                if(llStringIndexOf(body, "profession") != -1) {
                    start = llStringIndexOf(body, "profession") + 14; // "profession":"" (14 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gProfession = llGetSubString(body, start, end - 1);
                }
                
                // Extraer facción política
                if(llStringIndexOf(body, "political_faction") != -1) {
                    start = llStringIndexOf(body, "political_faction") + 20; // "political_faction":"" (20 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gPoliticalFaction = llGetSubString(body, start, end - 1);
                }
                
                // Extraer género
                if(llStringIndexOf(body, "gender") != -1) {
                    start = llStringIndexOf(body, "gender") + 10; // "gender":"" (10 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gGender = llGetSubString(body, start, end - 1);
                }
                
                // Extraer idioma
                if(llStringIndexOf(body, "language") != -1) {
                    start = llStringIndexOf(body, "language") + 12; // "language":"" (12 para incluir las comillas)
                    end = llStringIndexOf(body, "\"", start);
                    gLanguage = llGetSubString(body, start, end - 1);
                }
                
                // Actualizar el Meter
                updateMeter();
            }
        }
        else if(request_id == gPlayerDataRequest) {
            llOwnerSay("Datos del personaje actualizados.");
            
            // Extraer los mismos campos que al cargar el jugador
            // Implementar lógica para extraer datos del JSON simplificada con literales directos
            if(llStringIndexOf(body, "rp_name") != -1) {
                start = llStringIndexOf(body, "rp_name") + 11; // "rp_name":"" (11 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gRpName = llGetSubString(body, start, end - 1);
            }
            
            // Usar literales directos en lugar de variables
            if(llStringIndexOf(body, "rp_surname") != -1) {
                start = llStringIndexOf(body, "rp_surname") + 14; // "rp_surname":"" (14 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gRpSurname = llGetSubString(body, start, end - 1);
            }
            
            // Extraer clase social
            if(llStringIndexOf(body, "social_class") != -1) {
                start = llStringIndexOf(body, "social_class") + 16; // "social_class":"" (16 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gSocialClass = llGetSubString(body, start, end - 1);
            }
            
            // Extraer profesión
            if(llStringIndexOf(body, "profession") != -1) {
                start = llStringIndexOf(body, "profession") + 14; // "profession":"" (14 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gProfession = llGetSubString(body, start, end - 1);
            }
            
            // Extraer facción política
            if(llStringIndexOf(body, "political_faction") != -1) {
                start = llStringIndexOf(body, "political_faction") + 20; // "political_faction":"" (20 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gPoliticalFaction = llGetSubString(body, start, end - 1);
            }
            
            // Extraer género
            if(llStringIndexOf(body, "gender") != -1) {
                start = llStringIndexOf(body, "gender") + 10; // "gender":"" (10 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gGender = llGetSubString(body, start, end - 1);
            }
            
            // Extraer idioma
            if(llStringIndexOf(body, "language") != -1) {
                start = llStringIndexOf(body, "language") + 12; // "language":"" (12 para incluir las comillas)
                end = llStringIndexOf(body, "\"", start);
                gLanguage = llGetSubString(body, start, end - 1);
            }
            
            // Mostrar un resumen del perfil al jugador
            string idiomaMostrar = "Inglés";
            if(gLanguage == "ES") {
                idiomaMostrar = "Español";
            }
            
            llOwnerSay("\n=== PERFIL ACTUALIZADO ===\n" +
                      "Nombre: " + gRpName + " " + gRpSurname + "\n" +
                      "Clase: " + gSocialClass + "\n" +
                      "Profesión: " + gProfession + "\n" +
                      "Facción Política: " + gPoliticalFaction + "\n" +
                      "Género: " + gGender + "\n" +
                      "Idioma: " + idiomaMostrar + "\n" +
                      "=======================");
            
            // Actualizar el Meter
            updateMeter();
        }
        else if(request_id == gPlayerDamageRequest) {
            llOwnerSay("Has recibido daño.");
            updateMeter();
        }
        else if(request_id == gPlayerHealRequest) {
            llOwnerSay("Has sido curado.");
            updateMeter();
        }
        else if(request_id == gPlayerReviveRequest) {
            llOwnerSay("Has sido revivido.");
            updateMeter();
        }
        // Respuestas para opciones en la creación de personaje - usando literales directos
        else if(llStringIndexOf(body, "social_classes") != -1 || 
                llStringIndexOf(body, "name") != -1) {
            // Respuesta con clases sociales, facciones políticas o profesiones
            // Implementar lógica para extraer opciones y mostrar menú
            options = [];
            
            // Ejemplo básico de parsing - limitado a 9 opciones (0-8)
            i = 0;
            pos = 0;
            maxOptions = 8; // Máximo 9 opciones (índices 0-8)
            
            // En LSL no se puede usar break, así que usamos una variable de control
            continuar = TRUE;
            // Usar literal directo para el campo "name"
            while(llStringIndexOf(body, "name", pos) != -1 && continuar) {
                // Encontramos la posición del campo y sumamos 6 para saltar las comillas, el nombre del campo y los dos puntos
                pos = llStringIndexOf(body, "name", pos) + 6;
                // Buscamos la siguiente comilla
                end = llStringIndexOf(body, "\"", pos);
                option = llGetSubString(body, pos, end - 1);
                options = options + [option]; // Forma correcta de añadir a una lista en LSL
                
                // Incrementamos contador y verificamos límite
                i++;
                if(i > maxOptions) {
                    continuar = FALSE;
                }
            }
            
            // Si hay opciones, mostrar menú
            if(llGetListLength(options) > 0) {
                options = options + ["Volver"]; // Forma correcta de añadir a una lista en LSL
                llDialog(llGetOwner(), "Seleccione una opción:", options, gMenuChannel);
            } else {
                llOwnerSay("No se encontraron opciones disponibles.");
                showCharacterCreationMenu();
            }
        }
        else if(llStringIndexOf(body, "player") != -1 && 
                llStringIndexOf(body, "created successfully") != -1) {
            // Jugador creado con éxito
            llOwnerSay("¡Personaje creado con éxito!");
            gInSetupMode = FALSE;
            gAwaitingCharacterCreation = FALSE;
            
            // Actualizar el Meter
            updateMeter();
        }
    }
}