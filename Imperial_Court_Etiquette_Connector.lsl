/**
 * Imperial Court Etiquette Connector
 * 
 * This script serves as a connector between the Core HUD and the Etiquette Module.
 * It facilitates communication between these components, ensuring that the player
 * receives personalized etiquette advice based on their rank and status.
 * 
 * For Imperial Russian Court RP System (1905)
 * Last Updated: April 2025
 */

// System configuration
string VERSION = "1.0.0";
string AUTHENTICATION_KEY = "ImperialCourtAuth1905"; 
integer SYSTEM_CHANNEL = -89827631;
integer ETIQUETTE_CHANNEL = -98019;
integer HUD_CHANNEL = -76543219;

// Player data
key ownerID;
string playerRank = "";
string playerName = "";

// Listener tracking
integer mainListener;

// ===== UTILITY FUNCTIONS =====

// Initialize the script
initialize() {
    // Clear existing listener
    if (mainListener) llListenRemove(mainListener);
    
    // Set up listeners for system channel
    mainListener = llListen(SYSTEM_CHANNEL, "", NULL_KEY, "");
    
    // Store owner
    ownerID = llGetOwner();
    playerName = llKey2Name(ownerID);
    
    // Set default floating text
    llSetText("Court Etiquette Connector\nActive", <0.6, 0.8, 0.6>, 0.7);
}

// ===== MAIN FUNCTIONS =====

default {
    state_entry() {
        initialize();
        llOwnerSay("Imperial Court Etiquette Connector initialized.");
    }
    
    touch_start(integer total_number) {
        // Check if owner touched
        if (llDetectedKey(0) == ownerID) {
            llOwnerSay("Imperial Court Etiquette Connector active.\nVersion: " + VERSION);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Only process system channel messages
        if (channel == SYSTEM_CHANNEL) {
            list msgParts = llParseString2List(message, ["|"], []);
            string command = llList2String(msgParts, 0);
            string authKey = llList2String(msgParts, 1);
            
            // Validate authentication
            if (authKey == AUTHENTICATION_KEY) {
                // Handle player rank information
                if (command == "QUERY_PLAYER_RANK_RESPONSE") {
                    key playerID = (key)llList2String(msgParts, 2);
                    string rankInfo = llList2String(msgParts, 3);
                    
                    // Update our stored rank information
                    playerRank = rankInfo;
                    
                    // Forward to Etiquette Module if needed
                    // (No action needed here as the Module listens to the same channel)
                }
                // Handle etiquette requests from the HUD
                else if (command == "HUD_ETIQUETTE_REQUEST") {
                    key requestingPlayer = (key)llList2String(msgParts, 2);
                    
                    // If the request is from this player, forward it to the module
                    if (requestingPlayer == ownerID) {
                        // If we've already received the player's rank, use it
                        if (playerRank != "") {
                            // Forward to the etiquette module with the player's rank
                            llRegionSay(SYSTEM_CHANNEL, "ETIQUETTE_REQUEST|" + AUTHENTICATION_KEY + "|" + 
                                       (string)ownerID + "|" + playerRank);
                        }
                        else {
                            // Request rank information first
                            llRegionSay(SYSTEM_CHANNEL, "QUERY_PLAYER_RANK|" + AUTHENTICATION_KEY + "|" + 
                                       (string)ownerID);
                        }
                    }
                }
                // Handle etiquette module responses
                else if (command == "ETIQUETTE_REQUEST_RESPONSE") {
                    key targetPlayer = (key)llList2String(msgParts, 2);
                    
                    // Forward the response to the HUD if it's for this player
                    if (targetPlayer == ownerID) {
                        // Message is already formatted correctly for the HUD
                        // (No further action needed as the HUD also listens on the same channel)
                    }
                }
            }
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            initialize();
        }
    }
    
    on_rez(integer start_param) {
        initialize();
    }
}