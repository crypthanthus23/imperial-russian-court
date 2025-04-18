// Imperial Court HUD - Stats Meter - Updated Version
// This script displays player stats as floating text visible to others
// Added Faith stat and improved wealth rank system
// Updated with API connection support

// Constants
integer STATS_CHANNEL = -987654321; // Communication channel between HUD and meter
float TEXT_UPDATE_RATE = 0.5; // How often to update the floating text (in seconds)
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Amber/gold color for text
float TEXT_ALPHA = 1.0; // Text opacity (1.0 = fully opaque)

// Variables
string playerName = "";
string familyName = "";
string rankName = "";
string russianRankName = "";
string wealthCategory = "";
integer health = 100;
integer charm = 50;
integer influence = 25;
integer imperialFavor = 0;
integer rubles = 0;
integer experience = 0;
string courtPosition = "";
integer playerGender = 0; // 0=male, 1=female
integer faith = 15; // Faith stat

// Flags
integer textVisible = TRUE;
integer isLinked = FALSE;
integer isDatabaseConnected = FALSE;
key hudOwnerID = NULL_KEY;
key apiConnectorID = NULL_KEY;

// Function to format and display the stats as floating text
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    string displayText = "";
    
    // Add header with player name and rank if available
    if (playerName != "" && familyName != "") {
        displayText += playerName + " " + familyName + "\n";
        
        if (rankName != "") {
            displayText += rankName;
            
            if (russianRankName != "") {
                displayText += " (" + russianRankName + ")";
            }
            
            displayText += "\n";
        }
        
        // Add court position if any
        if (courtPosition != "") {
            displayText += courtPosition + "\n";
        }
        
        // Add database connection status
        if (isDatabaseConnected) {
            displayText += "◉ Sistema Conectado\n";
        } else {
            displayText += "◎ Sin Conexión al Servidor\n";
        }
        
        // Add horizontal line
        displayText += "---------------------\n";
        
        // Add gender identifier (optional)
        if (playerGender == 0) {
            displayText += "♂ ";
        } else {
            displayText += "♀ ";
        }
        
        // Add core stats
        displayText += "Health: " + (string)health + " • ";
        displayText += "Charm: " + (string)charm + "\n";
        
        // Add influence and favor
        displayText += "Influence: " + (string)influence + " • ";
        displayText += "Favor: " + (string)imperialFavor + "\n";
        
        // Add wealth information with category
        displayText += "Rubles: " + (string)rubles + " • ";
        displayText += "Status: " + wealthCategory + "\n";
        
        // Add faith stat
        displayText += "Faith: " + (string)faith + "\n";
        
        // Optionally add experience
        displayText += "Experience: " + (string)experience;
    }
    else {
        displayText = "Imperial Court Stats Meter\n";
        
        if (isLinked) {
            displayText += "(Conectado al HUD)";
            
            if (isDatabaseConnected) {
                displayText += "\n◉ Base de datos conectada";
            } else {
                displayText += "\n◎ Esperando conexión a base de datos";
            }
        } else {
            displayText += "(Sin conexión al HUD)";
        }
    }
    
    // Display the text
    llSetText(displayText, TEXT_COLOR, TEXT_ALPHA);
}

// Function to request stats update from the HUD
requestStatsUpdate() {
    if (isLinked && hudOwnerID != NULL_KEY) {
        // Send a request on the stats channel
        llRegionSay(STATS_CHANNEL, "REQUEST_STATS_UPDATE");
    }
}

// Function to process incoming stats data
processStatsData(string data) {
    // Split the data string by separator
    list dataParts = llParseString2List(data, ["||"], []);
    
    if (llGetListLength(dataParts) < 10) {
        llOwnerSay("Error: Received incomplete stats data");
        return;
    }
    
    // Extract data from the list
    playerName = llList2String(dataParts, 0);
    familyName = llList2String(dataParts, 1);
    rankName = llList2String(dataParts, 2);
    russianRankName = llList2String(dataParts, 3);
    courtPosition = llList2String(dataParts, 4);
    health = (integer)llList2String(dataParts, 5);
    charm = (integer)llList2String(dataParts, 6);
    influence = (integer)llList2String(dataParts, 7);
    experience = (integer)llList2String(dataParts, 8);
    rubles = (integer)llList2String(dataParts, 9);
    imperialFavor = (integer)llList2String(dataParts, 10);
    wealthCategory = llList2String(dataParts, 11);
    
    // Check if gender data is included
    if (llGetListLength(dataParts) >= 13) {
        playerGender = (integer)llList2String(dataParts, 12);
    }
    
    // Check if faith data is included
    if (llGetListLength(dataParts) >= 14) {
        faith = (integer)llList2String(dataParts, 13);
    }
    
    // Update the floating text with new data
    updateFloatingText();
}

default {
    state_entry() {
        // Initialize the meter
        llSetText("Imperial Court Stats Meter\n(Connect to HUD for data)", TEXT_COLOR, TEXT_ALPHA);
        
        // Listen for communications on the stats channel
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        
        // Start a timer for periodic updates
        llSetTimerEvent(TEXT_UPDATE_RATE);
    }
    
    touch_start(integer total_number) {
        // Toggle text visibility when touched
        textVisible = !textVisible;
        updateFloatingText();
        
        string visibilityStatus;
        if (textVisible) {
            visibilityStatus = "visible";
        } else {
            visibilityStatus = "hidden";
        }
        llOwnerSay("Stats display " + visibilityStatus);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == STATS_CHANNEL) {
            // Check for connection request
            if (llSubStringIndex(message, "CONNECT_METER:") == 0) {
                // Extract owner ID from message
                string ownerIDString = llGetSubString(message, 14, -1);
                key ownerKey = (key)ownerIDString;
                
                // If this meter belongs to the requester, establish connection
                if (ownerKey == llGetOwner()) {
                    hudOwnerID = id;
                    isLinked = TRUE;
                    llOwnerSay("Connected to Imperial Court HUD.");
                    
                    // Store potential API connector ID
                    apiConnectorID = id;
                    
                    // Send confirmation to the HUD
                    llRegionSay(STATS_CHANNEL, "HUD_CONNECTED");
                    
                    // Request initial stats
                    requestStatsUpdate();
                }
            }
            // Check for database connection notification
            else if (message == "DATABASE_CONNECTED" && (id == hudOwnerID || id == apiConnectorID)) {
                isDatabaseConnected = TRUE;
                llOwnerSay("Base de datos conectada correctamente.");
                updateFloatingText();
                
                // Request stats update now that database is connected
                requestStatsUpdate();
            }
            // Check for stats data
            else if (llSubStringIndex(message, "STATS_DATA:") == 0) {
                // Extract data part of the message
                string data = llGetSubString(message, 11, -1);
                
                // Process the stats data
                processStatsData(data);
                
                // Store the HUD owner ID for future communication
                hudOwnerID = id;
                isLinked = TRUE;
            }
            // Check for connection confirmation
            else if (message == "HUD_CONNECTED") {
                hudOwnerID = id;
                isLinked = TRUE;
                llOwnerSay("Imperial Court HUD connected successfully.");
                
                requestStatsUpdate();
            }
            // Check for disconnection message
            else if (message == "HUD_DISCONNECTED" && id == hudOwnerID) {
                hudOwnerID = NULL_KEY;
                isLinked = FALSE;
                isDatabaseConnected = FALSE;
                llOwnerSay("Imperial Court HUD disconnected.");
                updateFloatingText();
            }
        }
    }
    
    timer() {
        // If we're linked to a HUD, periodically request updates
        if (isLinked && hudOwnerID != NULL_KEY) {
            requestStatsUpdate();
        }
    }
}