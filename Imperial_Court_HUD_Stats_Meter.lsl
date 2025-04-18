// Imperial Court HUD - Stats Meter - Final Version
// Display stats with floating text for player characters in the imperial court
// Improved communication with core HUD and API Connector

// Constants
integer STATS_CHANNEL = -987654321;  // Communication channel between HUD and meter
float TEXT_UPDATE_RATE = 0.5;         // How often to update the floating text (in seconds)
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Amber/gold color for text
float TEXT_ALPHA = 1.0;               // Text opacity (1.0 = fully opaque)

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
integer playerGender = 0;  // 0=male, 1=female
integer faith = 15;        // NEW: Faith stat
integer playerClass = 0;   // Added for core HUD compatibility

// Flags
integer textVisible = TRUE;
integer isLinked = FALSE;
key hudOwnerID = NULL_KEY;
integer hasDbConnect = FALSE; // NEW: Flag for database connection

// Function to format and display the stats as floating text
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    string displayText = "";
    
    // Add header with player name and rank if available
    if (playerName != "") {
        displayText += playerName + "\n";
        
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
        
        // Add horizontal line
        displayText += "---------------------\n";
        
        // Add database connection status (NEW)
        if (hasDbConnect) {
            displayText += "✓ Database Connected\n";
        }
        
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
        
        // Add faith stat (NEW)
        displayText += "Faith: " + (string)faith + "\n";
        
        // Optionally add experience
        displayText += "Experience: " + (string)experience;
    }
    else {
        displayText = "Imperial Court Stats Meter\n";
        displayText += "(Connect to HUD for data)";
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

// Function to process incoming stats data - Original format (with || separator)
processStatsDataOriginal(string data) {
    // Split the data string by separator
    list dataParts = llParseString2List(data, ["||"], []);
    
    if (llGetListLength(dataParts) < 10) {
        llOwnerSay("Error: Received incomplete stats data in original format");
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

// Function to process incoming stats data - Core HUD format (with NAME:value| format)
processStatsDataCore(string data) {
    // Parse the key-value pairs
    list pairs = llParseString2List(data, ["|"], []);
    integer i;
    integer count = llGetListLength(pairs);
    
    // Reset some values to defaults
    integer gotName = FALSE;
    
    for (i = 0; i < count; i++) {
        string pair = llList2String(pairs, i);
        list splitPair = llParseString2List(pair, [":"], []);
        
        if (llGetListLength(splitPair) != 2) {
            // Skip invalid pairs
            llOwnerSay("Skipping invalid pair: " + pair);
        } else {
            string keyName = llList2String(splitPair, 0);
            string value = llList2String(splitPair, 1);
            
            // Process each key-value pair
            if (keyName == "NAME") {
                list nameParts = llParseString2List(value, [" "], []);
                if (llGetListLength(nameParts) >= 2) {
                    playerName = llList2String(nameParts, 0);
                    familyName = llList2String(nameParts, 1);
                    
                    // Handle potential middle names by adding to family name
                    if (llGetListLength(nameParts) > 2) {
                        integer j;
                        for (j = 2; j < llGetListLength(nameParts); j++) {
                            familyName += " " + llList2String(nameParts, j);
                        }
                    }
                } else {
                    playerName = value;
                    familyName = "";
                }
                gotName = TRUE;
            }
            else if (keyName == "CLASS") playerClass = (integer)value;
            else if (keyName == "RANK") {
                integer rankVal = (integer)value;
                // Convert rank numeric value to name
                if (rankVal == 1) rankName = "Commoner";
                else if (rankVal == 2) rankName = "Lesser Nobility";
                else if (rankVal == 3) rankName = "Noble";
                else if (rankVal == 4) rankName = "High Noble";
                else if (rankVal == 5) rankName = "Grand Duke/Duchess";
                else if (rankVal == 6) rankName = "Imperial Family";
                else if (rankVal == 7) rankName = "Tsar/Tsarina";
                else rankName = "Visitor";
            }
            else if (keyName == "HEALTH") health = (integer)value;
            else if (keyName == "FAITH") faith = (integer)value;
            else if (keyName == "WEALTH") {
                rubles = (integer)value;
                // Set wealth category based on rubles
                if (rubles < 100) wealthCategory = "Destitute";
                else if (rubles < 500) wealthCategory = "Poor";
                else if (rubles < 1000) wealthCategory = "Modest";
                else if (rubles < 5000) wealthCategory = "Comfortable";
                else if (rubles < 10000) wealthCategory = "Wealthy";
                else if (rubles < 50000) wealthCategory = "Rich";
                else wealthCategory = "Extremely Wealthy";
            }
            else if (keyName == "FAVOR") imperialFavor = (integer)value;
            else if (keyName == "COURT") courtPosition = value;
            // Set some reasonable defaults for stats not in core HUD
            else if (keyName == "GENDER") playerGender = (integer)value;
            else if (keyName == "EXP") experience = (integer)value;
            // NEW: Check for database connection flag
            else if (keyName == "DBCONN") hasDbConnect = (integer)value;
        }
    }
    
    // Default charm and influence to reasonable values based on favor if not provided
    charm = 40 + (imperialFavor / 2);
    influence = 30 + imperialFavor;
    
    // Only update if we at least got a name
    if (gotName) {
        updateFloatingText();
    } else {
        llOwnerSay("Warning: Received data doesn't contain player name");
    }
}

default {
    state_entry() {
        // Initialize the meter
        llSetText("Imperial Court Stats Meter\n(Connect to HUD for data)", TEXT_COLOR, TEXT_ALPHA);
        
        // Listen for communications on the stats channel
        llListen(STATS_CHANNEL, "", NULL_KEY, "");
        
        // Start a timer for periodic updates
        llSetTimerEvent(TEXT_UPDATE_RATE);
        
        llOwnerSay("Imperial Court Stats Meter initialized. Wear with your Court HUD for display.");
    }
    
    touch_start(integer total_number) {
        // Only allow owner to touch
        if (llDetectedKey(0) != llGetOwner()) return;
        
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
                    
                    // Send confirmation to the HUD
                    llRegionSay(STATS_CHANNEL, "HUD_CONNECTED");
                    
                    // Request initial stats
                    requestStatsUpdate();
                }
            }
            // Check for stats data in original format (from early versions)
            else if (llSubStringIndex(message, "STATS_DATA:") == 0) {
                // Extract data part of the message
                string data = llGetSubString(message, 11, -1);
                
                // Process the stats data in original format
                processStatsDataOriginal(data);
                
                // Store the HUD owner ID for future communication
                hudOwnerID = id;
                isLinked = TRUE;
            }
            // Check for stats data in Core HUD format (key:value pairs)
            else if (llSubStringIndex(message, "NAME:") == 0) {
                // Process the stats data in Core HUD format
                processStatsDataCore(message);
            }
            // NEW: Handle DATABASE_CONNECTED message
            else if (message == "DATABASE_CONNECTED") {
                hasDbConnect = TRUE;
                llOwnerSay("Database connection established.");
                updateFloatingText();
            }
            // Respond to update requests
            else if (message == "REQUEST_STATS_UPDATE") {
                // This would typically be sent from the HUD to the meter
                // But we can use it to request updates from HUD if needed
                if (isLinked && hudOwnerID != NULL_KEY) {
                    llRegionSayTo(hudOwnerID, STATS_CHANNEL, "METER_READY");
                }
            }
        }
    }
    
    timer() {
        // Periodic update for the floating text
        llSetTimerEvent(TEXT_UPDATE_RATE);
        
        // If connected but haven't received data in a while, can request an update
        if (isLinked && hudOwnerID != NULL_KEY && playerName == "") {
            requestStatsUpdate();
        }
    }
    
    // Extra security - reset if attached to a new owner
    attach(key id) {
        if (id != NULL_KEY && id != llGetOwner()) {
            llResetScript();
        }
    }
}