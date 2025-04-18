// Imperial Court Relationship Connector
// This script connects individual HUDs to the Relationship System
// Add this script to any HUD to enable relationship and influence tracking

// Constants
integer COURT_RELATIONSHIPS_CHANNEL = -100;
integer COURT_INFLUENCE_CHANNEL = -101;
integer RELATIONSHIP_UPDATE_CHANNEL = -102;
integer REPUTATION_UPDATE_CHANNEL = -103;
integer HUD_LINK_MESSAGE_CHANNEL = 42;

// Shared key for authenticating messages between HUDs
string AUTHENTICATION_KEY = "ImperialCourtAuth1905";

// Store player data
key playerKey;
string playerName;
string playerTitle = "";
integer playerInfluence = 0;
integer playerFaith = 0;
integer playerCharm = 0;

// Track recent interactions to prevent spam
list recentInteractions = [];
integer MAX_RECENT_INTERACTIONS = 10;

// Relationship data storage (small cache for quick access)
// Format: [UUID, relationship level, relationship type, last interaction time]
list relationshipCache = [];
integer MAX_CACHE_SIZE = 5;

// Initialize the connector
initialize() {
    playerKey = llGetOwner();
    playerName = llKey2Name(playerKey);
    
    // Listen for relationship updates
    llListen(RELATIONSHIP_UPDATE_CHANNEL, "", NULL_KEY, "");
    llListen(REPUTATION_UPDATE_CHANNEL, "", NULL_KEY, "");
    
    // Clear any previous data
    recentInteractions = [];
    relationshipCache = [];
    
    // Send a request for player data
    sendLinkMessage("REQUEST_PLAYER_DATA", "");
}

// Function to add to recent interactions list
addRecentInteraction(key targetKey, string interactionType) {
    // Add to the list
    recentInteractions += [targetKey, interactionType, llGetUnixTime()];
    
    // Ensure list doesn't grow too large
    while(llGetListLength(recentInteractions) > MAX_RECENT_INTERACTIONS * 3) {
        recentInteractions = llDeleteSubList(recentInteractions, 0, 2);
    }
}

// Check if an interaction was recently performed (to prevent spam)
integer wasRecentlyPerformed(key targetKey, string interactionType) {
    integer i;
    integer count = llGetListLength(recentInteractions) / 3;
    integer currentTime = llGetUnixTime();
    
    for(i = 0; i < count; i++) {
        key storedKey = (key)llList2String(recentInteractions, i * 3);
        string storedType = llList2String(recentInteractions, i * 3 + 1);
        integer storedTime = llList2Integer(recentInteractions, i * 3 + 2);
        
        // Check if this is the same interaction within the last 5 minutes
        if(storedKey == targetKey && storedType == interactionType && currentTime - storedTime < 300) {
            return TRUE;
        }
    }
    
    return FALSE;
}

// Add or update relationship cache entry
updateRelationshipCache(key targetKey, integer level, string type) {
    integer i;
    integer count = llGetListLength(relationshipCache) / 4;
    
    // Check if already in cache
    for(i = 0; i < count; i++) {
        key storedKey = (key)llList2String(relationshipCache, i * 4);
        if(storedKey == targetKey) {
            // Update existing entry
            relationshipCache = llListReplaceList(relationshipCache, 
                [targetKey, level, type, llGetUnixTime()], i * 4, i * 4 + 3);
            return;
        }
    }
    
    // Not in cache, add it
    if(count < MAX_CACHE_SIZE) {
        // Add to the cache
        relationshipCache += [targetKey, level, type, llGetUnixTime()];
    } else {
        // Replace the oldest entry
        integer oldestTime = llGetUnixTime();
        integer oldestIndex = 0;
        
        for(i = 0; i < count; i++) {
            integer storedTime = llList2Integer(relationshipCache, i * 4 + 3);
            if(storedTime < oldestTime) {
                oldestTime = storedTime;
                oldestIndex = i * 4;
            }
        }
        
        relationshipCache = llListReplaceList(relationshipCache, 
            [targetKey, level, type, llGetUnixTime()], oldestIndex, oldestIndex + 3);
    }
}

// Get cached relationship level for a target avatar
integer getCachedRelationshipLevel(key targetKey) {
    integer i;
    integer count = llGetListLength(relationshipCache) / 4;
    
    for(i = 0; i < count; i++) {
        key storedKey = (key)llList2String(relationshipCache, i * 4);
        if(storedKey == targetKey) {
            return llList2Integer(relationshipCache, i * 4 + 1);
        }
    }
    
    return 0; // Neutral by default
}

// Get cached relationship type for a target avatar
string getCachedRelationshipType(key targetKey) {
    integer i;
    integer count = llGetListLength(relationshipCache) / 4;
    
    for(i = 0; i < count; i++) {
        key storedKey = (key)llList2String(relationshipCache, i * 4);
        if(storedKey == targetKey) {
            return llList2String(relationshipCache, i * 4 + 2);
        }
    }
    
    return "Acquaintance"; // Default type
}

// Send a record of interaction to the main relationship system
recordInteraction(key targetKey, string interactionType, string details) {
    // Check if this was recently performed (to prevent spam)
    if(wasRecentlyPerformed(targetKey, interactionType)) {
        llOwnerSay("You recently performed this type of interaction. Please wait before doing it again.");
        return;
    }
    
    // Send the interaction data
    string message = llList2CSV([AUTHENTICATION_KEY, "RECORD_INTERACTION", 
        (string)playerKey, (string)targetKey, interactionType, details]);
    llRegionSay(COURT_INFLUENCE_CHANNEL, message);
    
    // Add to recent interactions
    addRecentInteraction(targetKey, interactionType);
    
    // Log the interaction
    llOwnerSay("Recorded " + interactionType + " interaction with " + llKey2Name(targetKey));
}

// Process relationship update from the main system
processRelationshipUpdate(key avatar1, key avatar2, integer level, string type) {
    // Only process if one of the avatars is the owner
    if(avatar1 == playerKey || avatar2 == playerKey) {
        // Determine the other avatar
        key otherAvatar;
        if(avatar1 == playerKey) {
            otherAvatar = avatar2;
        } else {
            otherAvatar = avatar1;
        }
        
        // Update cache
        updateRelationshipCache(otherAvatar, level, type);
        
        // Notify owner
        llOwnerSay("Your relationship with " + llKey2Name(otherAvatar) + 
            " is now " + type + " (" + (string)level + ")");
    }
}

// Process reputation update from the main system
processReputationUpdate(key avatar, integer score, string faction, integer change) {
    // Only process if the avatar is the owner
    if(avatar == playerKey) {
        // Update cached influence value
        playerInfluence = score;
        
        // Notify owner
        string changeText;
        if(change > 0) {
            changeText = "increased by " + (string)change;
        } else {
            changeText = "decreased by " + (string)(-change);
        }
        
        llOwnerSay("Your court reputation has " + changeText + 
            ". New influence: " + (string)score);
        llOwnerSay("Your strongest influence is with the " + faction + " faction.");
    }
}

// Send interaction data via link message to the host HUD script
sendLinkMessage(string command, string data) {
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, 
        llList2CSV(["RELATIONSHIP", command, data]), NULL_KEY);
}

// Default state
default {
    state_entry() {
        initialize();
    }
    
    listen(integer channel, string name, key id, string message) {
        list params = llCSV2List(message);
        
        // Verify authentication key
        if(llList2String(params, 0) == AUTHENTICATION_KEY) {
            string messageType = llList2String(params, 1);
            
            // Process relationship updates
            if(channel == RELATIONSHIP_UPDATE_CHANNEL && messageType == "RELATIONSHIP_UPDATE") {
                key avatar1 = (key)llList2String(params, 2);
                key avatar2 = (key)llList2String(params, 3);
                integer level = (integer)llList2String(params, 4);
                string type = llList2String(params, 5);
                
                processRelationshipUpdate(avatar1, avatar2, level, type);
                
                // Send update to host HUD
                if(avatar1 == playerKey || avatar2 == playerKey) {
                    key otherAvatar;
                    if(avatar1 == playerKey) {
                        otherAvatar = avatar2;
                    } else {
                        otherAvatar = avatar1;
                    }
                    sendLinkMessage("RELATIONSHIP_UPDATE", 
                        llList2CSV([otherAvatar, level, type]));
                }
            }
            // Process reputation updates
            else if(channel == REPUTATION_UPDATE_CHANNEL && messageType == "REPUTATION_UPDATE") {
                key avatar = (key)llList2String(params, 2);
                integer score = (integer)llList2String(params, 3);
                string faction = llList2String(params, 4);
                integer change = (integer)llList2String(params, 5);
                
                processReputationUpdate(avatar, score, faction, change);
                
                // Send update to host HUD
                if(avatar == playerKey) {
                    sendLinkMessage("REPUTATION_UPDATE", 
                        llList2CSV([score, faction, change]));
                }
            }
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        // Only process messages on the HUD channel
        if(num == HUD_LINK_MESSAGE_CHANNEL) {
            list params = llCSV2List(str);
            
            // Check if the message is for the relationship system
            if(llList2String(params, 0) == "RELATIONSHIP") {
                string command = llList2String(params, 1);
                
                if(command == "RECORD_INTERACTION") {
                    // Format: ["RELATIONSHIP", "RECORD_INTERACTION", targetKey, interactionType, details]
                    key targetKey = (key)llList2String(params, 2);
                    string interactionType = llList2String(params, 3);
                    string details = llList2String(params, 4);
                    
                    recordInteraction(targetKey, interactionType, details);
                }
                else if(command == "GET_RELATIONSHIP") {
                    // Format: ["RELATIONSHIP", "GET_RELATIONSHIP", targetKey]
                    key targetKey = (key)llList2String(params, 2);
                    integer level = getCachedRelationshipLevel(targetKey);
                    string type = getCachedRelationshipType(targetKey);
                    
                    // Return the relationship data
                    sendLinkMessage("RELATIONSHIP_DATA", 
                        llList2CSV([targetKey, level, type]));
                }
                else if(command == "PLAYER_DATA_UPDATE") {
                    // Format: ["RELATIONSHIP", "PLAYER_DATA_UPDATE", title, influence, faith, charm]
                    playerTitle = llList2String(params, 2);
                    playerInfluence = (integer)llList2String(params, 3);
                    playerFaith = (integer)llList2String(params, 4);
                    playerCharm = (integer)llList2String(params, 5);
                    
                    // Send update to the relationship system
                    string message = llList2CSV([AUTHENTICATION_KEY, "PLAYER_DATA_UPDATE", 
                        (string)playerKey, playerTitle, (string)playerInfluence, 
                        (string)playerFaith, (string)playerCharm]);
                    
                    llRegionSay(COURT_INFLUENCE_CHANNEL, message);
                }
            }
        }
    }
    
    changed(integer change) {
        if(change & CHANGED_OWNER) {
            // Reset for new owner
            initialize();
        }
    }
}