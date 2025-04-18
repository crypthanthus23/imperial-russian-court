// Imperial Foreign Visitors Connector
// Part of the Imperial Russian Court Roleplay System
// Connects the Foreign Visitors Module with the main Imperial Court system

// System constants
integer SYSTEM_CHANNEL = -9999876; // General system communications
integer HUD_CHANNEL = -987654321; // HUD general communications
integer FOREIGN_VISITOR_CHANNEL = -99874321; // Foreign visitor communications
integer RELATIONSHIP_CHANNEL = -654321789; // Channel for social relationships
string AUTHENTICATION_KEY = "ImperialRussianCourtAuth1905"; // Authentication key for system messages

// Connector state
list pendingVisitors = []; // Visitors waiting for connection confirmation
list foreignRelations = []; // List tracking diplomatic relations between countries
string connectorState = "ready"; // Current state of the connector

// Helper functions
processRegistration(key visitorKey, string visitorName, string visitorCountry, string visitorCourt, string visitorRank, string visitorTitle) {
    // Process a new foreign visitor registration by interfacing with other modules
    
    // 1. Notify the Core HUD system
    llMessageLinked(LINK_THIS, SYSTEM_CHANNEL, "FOREIGN_VISITOR_ARRIVED|" + AUTHENTICATION_KEY + "|" + 
                   (string)visitorKey + "|" + visitorName + "|" + visitorCountry, NULL_KEY);
    
    // 2. Update the visitor's HUD with registration details
    llMessageLinked(LINK_THIS, HUD_CHANNEL, "VISITOR_REGISTERED|" + AUTHENTICATION_KEY + "|" + 
                   (string)visitorKey + "|" + visitorName + "|" + visitorCountry + "|" + 
                   visitorCourt + "|" + visitorRank + "|" + visitorTitle, NULL_KEY);
    
    // 3. Award the standard diplomatic stipend (3000 rubles)
    llMessageLinked(LINK_THIS, HUD_CHANNEL, "RUBLES_UPDATE|" + AUTHENTICATION_KEY + "|" + 
                   (string)visitorKey + "|3000", NULL_KEY);
    
    // 4. Add to the relationships system for diplomatic interactions
    llMessageLinked(LINK_THIS, RELATIONSHIP_CHANNEL, "ADD_FOREIGN_RELATION|" + AUTHENTICATION_KEY + "|" + 
                   (string)visitorKey + "|" + visitorName + "|" + visitorCountry + "|" + visitorRank, NULL_KEY);
    
    // 5. Log the registration
    llOwnerSay("Foreign visitor registration processed: " + visitorName + " from " + visitorCountry);
}

updateDiplomaticRelations(string country1, string country2, float relationValue) {
    // Update diplomatic relations between two countries
    integer idx = llListFindList(foreignRelations, [country1, country2]);
    if (idx != -1) {
        // Update existing relation
        foreignRelations = llListReplaceList(foreignRelations, [country1, country2, relationValue], idx, idx + 2);
    } else {
        // Add new relation
        foreignRelations += [country1, country2, relationValue];
    }
}

float getDiplomaticRelation(string country1, string country2) {
    // Get the diplomatic relation level between two countries
    integer idx = llListFindList(foreignRelations, [country1, country2]);
    if (idx != -1) {
        return llList2Float(foreignRelations, idx + 2);
    }
    
    // Try reverse order
    idx = llListFindList(foreignRelations, [country2, country1]);
    if (idx != -1) {
        return llList2Float(foreignRelations, idx + 2);
    }
    
    // Default neutral relation (50%)
    return 50.0;
}

// Main state
default {
    state_entry() {
        // Initialize the connector
        llOwnerSay("Initializing Imperial Foreign Visitors Connector...");
        
        // Set up listeners for system communications
        llListen(SYSTEM_CHANNEL, "", NULL_KEY, "");
        llListen(FOREIGN_VISITOR_CHANNEL, "", NULL_KEY, "");
        
        // Initialize diplomatic relations for major powers of 1905
        // Relations are on a scale of 0-100 (hostile to friendly)
        updateDiplomaticRelations("Russia", "Germany", 30.0); // Strained after Morocco Crisis
        updateDiplomaticRelations("Russia", "France", 90.0); // Franco-Russian Alliance
        updateDiplomaticRelations("Russia", "United Kingdom", 40.0); // Improving but after Dogger Bank
        updateDiplomaticRelations("Russia", "Japan", 10.0); // Russo-Japanese War
        updateDiplomaticRelations("Russia", "Austria-Hungary", 20.0); // Balkans tension
        updateDiplomaticRelations("Russia", "Ottoman Empire", 15.0); // Historical enemies
        updateDiplomaticRelations("Russia", "United States", 60.0); // Neutral to positive
        
        llOwnerSay("Imperial Foreign Visitors Connector activated.");
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == SYSTEM_CHANNEL) {
            // Handle system messages
            list msgParts = llParseString2List(message, ["|"], []);
            string command = llList2String(msgParts, 0);
            string authKey = llList2String(msgParts, 1);
            
            if (authKey == AUTHENTICATION_KEY) {
                if (command == "GLOBAL_RESET") {
                    // Reset this connector
                    llResetScript();
                }
                else if (command == "PROCESS_VISITOR_REGISTRATION") {
                    // Process a visitor registration from another module
                    key visitorKey = (key)llList2String(msgParts, 2);
                    string visitorName = llList2String(msgParts, 3);
                    string visitorCountry = llList2String(msgParts, 4);
                    string visitorCourt = llList2String(msgParts, 5);
                    string visitorRank = llList2String(msgParts, 6);
                    string visitorTitle = llList2String(msgParts, 7);
                    
                    processRegistration(visitorKey, visitorName, visitorCountry, visitorCourt, visitorRank, visitorTitle);
                }
                else if (command == "QUERY_DIPLOMATIC_RELATION") {
                    // Query the diplomatic relation between two countries
                    string country1 = llList2String(msgParts, 2);
                    string country2 = llList2String(msgParts, 3);
                    string replyChannel = llList2String(msgParts, 4);
                    
                    float relation = getDiplomaticRelation(country1, country2);
                    
                    // Send back the result
                    llMessageLinked(LINK_THIS, (integer)replyChannel, "DIPLOMATIC_RELATION|" + AUTHENTICATION_KEY + "|" + 
                                   country1 + "|" + country2 + "|" + (string)relation, NULL_KEY);
                }
                else if (command == "UPDATE_DIPLOMATIC_RELATION") {
                    // Update the diplomatic relation between two countries
                    string country1 = llList2String(msgParts, 2);
                    string country2 = llList2String(msgParts, 3);
                    float newRelation = (float)llList2String(msgParts, 4);
                    
                    // Limit to valid range
                    if (newRelation < 0.0) newRelation = 0.0;
                    if (newRelation > 100.0) newRelation = 100.0;
                    
                    updateDiplomaticRelations(country1, country2, newRelation);
                    
                    llOwnerSay("Diplomatic relations updated: " + country1 + " - " + country2 + " = " + (string)newRelation + "%");
                }
            }
        }
        else if (channel == FOREIGN_VISITOR_CHANNEL) {
            // Process messages from the Foreign Visitors module
            list msgParts = llParseString2List(message, ["|"], []);
            string command = llList2String(msgParts, 0);
            string authKey = llList2String(msgParts, 1);
            
            if (authKey == AUTHENTICATION_KEY) {
                if (command == "VISITOR_REGISTERED") {
                    // A new visitor has been registered
                    key visitorKey = (key)llList2String(msgParts, 2);
                    string visitorName = llList2String(msgParts, 3);
                    string visitorCountry = llList2String(msgParts, 4);
                    string visitorCourt = llList2String(msgParts, 5);
                    string visitorRank = llList2String(msgParts, 6);
                    string visitorTitle = llList2String(msgParts, 7);
                    
                    // Process the registration through our system
                    processRegistration(visitorKey, visitorName, visitorCountry, visitorCourt, visitorRank, visitorTitle);
                }
            }
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            // Reset the script if ownership changes
            llResetScript();
        }
    }
}