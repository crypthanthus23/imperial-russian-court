// Imperial Court HUD - Stats Meter - Complete Version
// This script displays player stats as floating text visible to others
// Supports all new features: Faith, Health, Family, Wealth Categories

// Constants
integer STATS_CHANNEL = -987654321; // Communication channel between HUD and meter
float TEXT_UPDATE_RATE = 0.5; // How often to update the floating text (in seconds)
vector TEXT_COLOR = <1.0, 0.8, 0.6>; // Amber/gold color for text
float TEXT_ALPHA = 1.0; // Text opacity (1.0 = fully opaque)
vector DECEASED_COLOR = <0.7, 0.2, 0.2>; // Red color for deceased nobles

// Variables
string playerName = "";
string familyName = "";
string rankName = "";
string russianRankName = "";
string wealthCategory = "";
string dynastyName = "";
string healthStatus = "Healthy";
integer health = 100;
integer charm = 50;
integer influence = 25;
integer imperialFavor = 0;
integer rubles = 0;
integer experience = 0;
string courtPosition = "";
integer playerGender = 0; // 0=male, 1=female
integer faith = 15; // Faith stat
integer isDead = FALSE; // Whether player is dead

// Flags
integer textVisible = TRUE;
integer isLinked = FALSE;
key hudOwnerID = NULL_KEY;
integer displayMode = 0; // 0=standard, 1=minimal, 2=detailed

// Function to format and display the stats as floating text
updateFloatingText() {
    if (!textVisible) {
        llSetText("", <0,0,0>, 0.0);
        return;
    }
    
    string displayText = "";
    vector textColor = TEXT_COLOR;
    
    // Check if player is dead
    if (isDead) {
        displayText = "† DECEASED †\n";
        displayText += playerName + " " + familyName + "\n";
        if (rankName != "") {
            displayText += rankName + "\n";
        }
        displayText += "Rest In Peace";
        
        llSetText(displayText, DECEASED_COLOR, TEXT_ALPHA);
        return;
    }
    
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
        
        // Add dynasty if any
        if (dynastyName != "") {
            displayText += dynastyName + " Dynasty\n";
        }
        
        // Add horizontal line
        displayText += "---------------------\n";
        
        // Different display modes based on setting
        if (displayMode == 0) { // Standard display
            // Add gender identifier
            if (playerGender == 0) {
                displayText += "♂ ";
            } else {
                displayText += "♀ ";
            }
            
            // Add core stats
            displayText += "Health: " + (string)health + " (" + healthStatus + ")\n";
            displayText += "Faith: " + (string)faith + " • ";
            displayText += "Charm: " + (string)charm + "\n";
            
            // Add influence and favor
            displayText += "Influence: " + (string)influence + " • ";
            displayText += "Favor: " + (string)imperialFavor + "\n";
            
            // Add wealth information with category
            displayText += "Status: " + wealthCategory + "\n";
        }
        else if (displayMode == 1) { // Minimal display
            // Simplified display with just key info
            displayText += healthStatus + " • " + wealthCategory + "\n";
            
            if (faith >= 75) {
                displayText += "Devout Orthodox";
            } else if (faith >= 40) {
                displayText += "Religious";
            } else {
                displayText += "Secular";
            }
        }
        else if (displayMode == 2) { // Detailed display
            // Full detailed stats
            // Add gender identifier
            if (playerGender == 0) {
                displayText += "♂ ";
            } else {
                displayText += "♀ ";
            }
            
            // Add all stats in detail
            displayText += "Health: " + (string)health + "/100 (" + healthStatus + ")\n";
            displayText += "Faith: " + (string)faith + "/100\n";
            displayText += "Charm: " + (string)charm + "/100\n";
            displayText += "Influence: " + (string)influence + "/100\n";
            displayText += "Imperial Favor: " + (string)imperialFavor + "/100\n";
            displayText += "Rubles: " + (string)rubles + "\n";
            displayText += "Wealth: " + wealthCategory + "\n";
            displayText += "Experience: " + (string)experience + "\n";
        }
    }
    else {
        displayText = "Imperial Court Stats Meter\n";
        displayText += "(Connect to HUD for data)";
    }
    
    // Display the text with appropriate color
    llSetText(displayText, textColor, TEXT_ALPHA);
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
    
    if (llGetListLength(dataParts) < 13) {
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
    playerGender = (integer)llList2String(dataParts, 12);
    
    // Check for faith stat (added in updated version)
    if (llGetListLength(dataParts) >= 14) {
        faith = (integer)llList2String(dataParts, 13);
    }
    
    // Check for isDead status (added in complete version)
    if (llGetListLength(dataParts) >= 15) {
        isDead = (integer)llList2String(dataParts, 14);
    }
    
    // Check for dynasty name (added in complete version)
    if (llGetListLength(dataParts) >= 16) {
        dynastyName = llList2String(dataParts, 15);
    }
    
    // Check for health status text (added in complete version)
    if (llGetListLength(dataParts) >= 17) {
        healthStatus = llList2String(dataParts, 16);
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
        // Toggle through display modes when touched by owner
        if (llDetectedKey(0) == llGetOwner()) {
            displayMode = (displayMode + 1) % 3; // Cycle through 0, 1, 2
            
            string modeText = "";
            if (displayMode == 0) modeText = "Standard";
            else if (displayMode == 1) modeText = "Minimal";
            else modeText = "Detailed";
            
            llOwnerSay("Display mode changed to: " + modeText);
            updateFloatingText();
        }
        // Toggle visibility when touched by others
        else {
            textVisible = !textVisible;
            updateFloatingText();
        }
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
                llOwnerSay("Imperial Court HUD disconnected.");
                
                // Reset display when disconnected
                playerName = "";
                familyName = "";
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