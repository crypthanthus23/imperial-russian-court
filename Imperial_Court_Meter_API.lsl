// Imperial Court Stats Meter - API Connected Version
// Este script muestra las estadísticas del jugador como texto flotante visible para otros
// Complementa al HUD que se conecta con la API de Replit

// Canal de comunicación
integer METER_CHANNEL = -987654321;

// Configuración visual
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Color dorado
float TEXT_ALPHA = 1.0; // Opacidad del texto
float UPDATE_RATE = 0.5; // Frecuencia de actualización (segundos)

// Variables para datos del jugador
string playerName = "";
string playerSurname = "";
string playerClass = "";
string playerProfession = "";
string playerFaction = "";
string playerGender = "";
string playerLanguage = "ES";

// Estadísticas del jugador
integer playerHealth = 100;
integer playerCharm = 10;
integer playerInfluence = 10;
integer playerXP = 0;
integer playerRubles = 100;
integer playerPopularity = 10;
integer playerFaith = 10;
integer playerWealth = 10;
integer playerLoyalty = 10;
integer playerLove = 10;

// Estado del jugador
integer playerIsDead = FALSE;
integer playerInComa = FALSE;

// Función para actualizar el texto flotante
updateFloatingText()
{
    string displayText = "";
    
    // Título: Nombre y apellido
    displayText += playerName + " " + playerSurname + "\n";
    
    // Clase social y profesión
    if(playerClass != "" || playerProfession != "")
    {
        displayText += playerClass;
        if(playerClass != "" && playerProfession != "")
            displayText += " - ";
        displayText += playerProfession + "\n";
    }
    
    // Línea separadora
    displayText += "---------------\n";
    
    // Estado de salud especial
    if(playerIsDead)
    {
        displayText += "*** FALLECIDO ***\n";
    }
    else if(playerInComa)
    {
        displayText += "*** EN COMA ***\n";
    }
    
    // Estadísticas principales 
    displayText += "Salud: " + (string)playerHealth + "%\n";
    
    // Otras estadísticas
    displayText += "Influencia: " + (string)playerInfluence + "\n";
    displayText += "Riqueza: " + (string)playerWealth + "\n";
    displayText += "Encanto: " + (string)playerCharm + "\n";
    displayText += "Popularidad: " + (string)playerPopularity + "\n";
    displayText += "Fé: " + (string)playerFaith + "\n";
    displayText += "XP: " + (string)playerXP;
    
    // Mostrar el texto
    llSetText(displayText, TEXT_COLOR, TEXT_ALPHA);
}

// Función para procesar mensajes del HUD
processHudUpdate(string data)
{
    list dataParts = llParseString2List(data, ["|"], []);
    if(llGetListLength(dataParts) < 2) return;
    
    string command = llList2String(dataParts, 0);
    string params = llList2String(dataParts, 1);
    
    if(command == "UPDATE")
    {
        // Formato esperado: "UPDATE|nombre,apellido,clase,profesión,facción,género,idioma"
        list playerData = llCSV2List(params);
        if(llGetListLength(playerData) >= 7)
        {
            playerName = llList2String(playerData, 0);
            playerSurname = llList2String(playerData, 1);
            playerClass = llList2String(playerData, 2);
            playerProfession = llList2String(playerData, 3);
            playerFaction = llList2String(playerData, 4);
            playerGender = llList2String(playerData, 5);
            playerLanguage = llList2String(playerData, 6);
            
            // Actualizar texto
            updateFloatingText();
        }
    }
    else if(command == "STATS")
    {
        // Formato esperado: "STATS|salud,encanto,influencia,xp,rublos,popularidad,fe,riqueza,lealtad,amor"
        list statsData = llCSV2List(params);
        if(llGetListLength(statsData) >= 10)
        {
            playerHealth = (integer)llList2String(statsData, 0);
            playerCharm = (integer)llList2String(statsData, 1);
            playerInfluence = (integer)llList2String(statsData, 2);
            playerXP = (integer)llList2String(statsData, 3);
            playerRubles = (integer)llList2String(statsData, 4);
            playerPopularity = (integer)llList2String(statsData, 5);
            playerFaith = (integer)llList2String(statsData, 6);
            playerWealth = (integer)llList2String(statsData, 7);
            playerLoyalty = (integer)llList2String(statsData, 8);
            playerLove = (integer)llList2String(statsData, 9);
            
            // Actualizar texto
            updateFloatingText();
        }
    }
    else if(command == "STATUS")
    {
        // Formato esperado: "STATUS|isDead,inComa"
        list statusData = llCSV2List(params);
        if(llGetListLength(statusData) >= 2)
        {
            playerIsDead = (integer)llList2String(statusData, 0);
            playerInComa = (integer)llList2String(statusData, 1);
            
            // Actualizar texto
            updateFloatingText();
        }
    }
}

default
{
    state_entry()
    {
        // Configuración inicial
        llListen(METER_CHANNEL, "", NULL_KEY, "");
        
        // Mostrar mensaje inicial
        llSetText("Medidor de Estadísticas\nCorte Imperial Rusa\n\nConectándose...", TEXT_COLOR, TEXT_ALPHA);
        
        // Actualizar periódicamente (por si se pierde una actualización)
        llSetTimerEvent(30.0); // Cada 30 segundos pedirá actualización
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(channel == METER_CHANNEL)
        {
            processHudUpdate(message);
        }
    }
    
    timer()
    {
        // Si no ha habido actualizaciones en un tiempo, solicitar
        llRegionSay(METER_CHANNEL, "REQUEST_UPDATE");
    }
    
    on_rez(integer start_param)
    {
        // Reiniciar al rezar
        llResetScript();
    }
}