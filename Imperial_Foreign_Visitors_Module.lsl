// Imperial Foreign Visitors Module
// Part of the Imperial Russian Court Roleplay System
// Handles registration and management of foreign visitors to the Imperial Russian Court

// System constants
integer FOREIGN_VISITOR_CHANNEL = -99874321; // Foreign visitor communications
integer SYSTEM_CHANNEL = -9999876; // General system communications
integer HUD_CHANNEL = -987654321; // HUD system communications
string AUTHENTICATION_KEY = "ImperialRussianCourtAuth1905"; // Authentication key for system messages

// Foreign visitor state variables
list foreignVisitors = []; // List of registered visitors (format: key|name|country|court|rank|title)
integer listenerHandle;
integer welcomeListenerHandle;

// Variables for visitor details
string visitorName;
string visitorCountry;
string visitorCourt;
string visitorRank;
string visitorTitle;
key visitorKey;
integer registrationStep;

// Display settings
vector textColor = <0.1, 0.4, 0.9>; // Blue color for foreign visitors

// Helper functions
updateDisplay() {
    // Update the display of registered visitors
    string displayText = "Foreign Visitors to the Imperial Court\n";
    integer i;
    integer count = llGetListLength(foreignVisitors) / 6; // 6 items per visitor
    integer idx;
    string vName;
    string vCountry;
    string vCourt;
    string vRank;
    string vTitle;
    
    if (count == 0) {
        displayText += "No foreign dignitaries currently registered.";
    } else {
        for (i = 0; i < count; i++) {
            idx = i * 6;
            vName = llList2String(foreignVisitors, idx + 1);
            vCountry = llList2String(foreignVisitors, idx + 2);
            vCourt = llList2String(foreignVisitors, idx + 3);
            vRank = llList2String(foreignVisitors, idx + 4);
            vTitle = llList2String(foreignVisitors, idx + 5);
            
            displayText += "\n";
            if (vTitle != "") {
                displayText += vTitle + " ";
            }
            displayText += vName;
            displayText += " (" + vRank + " from " + vCourt + " of " + vCountry + ")";
        }
    }
    
    llSetText(displayText, textColor, 1.0);
}

integer isVisitorRegistered(key id) {
    // Check if a visitor is already registered
    integer i;
    integer count = llGetListLength(foreignVisitors) / 6;
    
    for (i = 0; i < count; i++) {
        if (llList2Key(foreignVisitors, i * 6) == id) {
            return TRUE;
        }
    }
    return FALSE;
}

startRegistration(key id) {
    // Begin the registration process for a new visitor
    if (isVisitorRegistered(id)) {
        llInstantMessage(id, "You are already registered as a foreign visitor to the Imperial Russian Court.");
        return;
    }
    
    visitorKey = id;
    registrationStep = 1;
    
    llInstantMessage(id, "Welcome to the Imperial Russian Court of Tsar Nicholas II. As a foreign visitor, you are required to register your credentials.");
    llInstantMessage(id, "Step 1/5: Please provide your full name (as it would appear in diplomatic documents):");
    
    // Set up a listener for this specific visitor
    if (listenerHandle) {
        llListenRemove(listenerHandle);
    }
    listenerHandle = llListen(FOREIGN_VISITOR_CHANNEL, "", id, "");
}

completeRegistration() {
    // Complete the registration process
    // Add the visitor to the list
    foreignVisitors += [visitorKey, visitorName, visitorCountry, visitorCourt, visitorRank, visitorTitle];
    
    // Welcome the visitor
    string welcomeTitle = "";
    if (visitorTitle != "") {
        welcomeTitle = visitorTitle + " ";
    }
    llInstantMessage(visitorKey, "Registration complete. Welcome to the Imperial Russian Court, " + 
                     welcomeTitle + visitorName + ".");
    
    // Announce the visitor's arrival to the court
    string announcementTitle = "";
    if (visitorTitle != "") {
        announcementTitle = visitorTitle + " ";
    }
    llSay(0, "The Imperial Court welcomes " + 
           announcementTitle + visitorName + 
           ", " + visitorRank + " from the " + visitorCourt + " of " + visitorCountry + ".");
    
    // Award the visitor stipend of 3000 rubles
    llInstantMessage(visitorKey, "As a gesture of Imperial hospitality, you have been awarded a diplomatic stipend of 3000 rubles.");
    
    // Send a system message to update the visitor's HUD with rubles
    llMessageLinked(LINK_THIS, HUD_CHANNEL, "RUBLES_UPDATE|" + AUTHENTICATION_KEY + "|" + (string)visitorKey + "|3000", NULL_KEY);
    
    // Update the display
    updateDisplay();
    
    // Reset variables
    visitorName = "";
    visitorCountry = "";
    visitorCourt = "";
    visitorRank = "";
    visitorTitle = "";
    visitorKey = NULL_KEY;
    registrationStep = 0;
    
    // Remove the personal listener
    llListenRemove(listenerHandle);
    listenerHandle = 0;
}

resetModule() {
    // Reset the entire module
    if (listenerHandle) {
        llListenRemove(listenerHandle);
    }
    if (welcomeListenerHandle) {
        llListenRemove(welcomeListenerHandle);
    }
    
    foreignVisitors = [];
    visitorName = "";
    visitorCountry = "";
    visitorCourt = "";
    visitorRank = "";
    visitorTitle = "";
    visitorKey = NULL_KEY;
    registrationStep = 0;
    
    // Re-establish welcome listener
    welcomeListenerHandle = llListen(0, "", NULL_KEY, "/register_visitor");
    
    updateDisplay();
}

default {
    state_entry() {
        // Initialize the module
        llOwnerSay("Initializing Imperial Foreign Visitors Module...");
        
        // Set up listener for registration command
        welcomeListenerHandle = llListen(0, "", NULL_KEY, "/register_visitor");
        
        // Set up system communication listener
        llListen(SYSTEM_CHANNEL, "", NULL_KEY, "");
        
        // Update the display
        updateDisplay();
        
        llOwnerSay("Imperial Foreign Visitors Module activated.");
        llSay(0, "The Imperial Foreign Visitors Registration Bureau is now open. Foreign dignitaries may register by saying \"/register_visitor\".");
    }
    
    touch_start(integer total_number) {
        // When touched, provide information about the module
        key toucher = llDetectedKey(0);
        
        llInstantMessage(toucher, "Imperial Foreign Visitors Registration Bureau");
        llInstantMessage(toucher, "This bureau manages the registration of foreign visitors to the Imperial Russian Court.");
        llInstantMessage(toucher, "Foreign dignitaries can register by saying \"/register_visitor\" in open chat.");
        
        // If the owner touches, offer administrative options
        if (toucher == llGetOwner()) {
            llDialog(llGetOwner(), "Foreign Visitors Module Administration", 
                    ["Reset Module", "List Visitors", "Close"], FOREIGN_VISITOR_CHANNEL);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == 0 && message == "/register_visitor") {
            // Someone wants to register
            startRegistration(id);
        }
        else if (channel == FOREIGN_VISITOR_CHANNEL) {
            if (id == llGetOwner()) {
                // Owner administrative commands
                if (message == "Reset Module") {
                    llOwnerSay("Resetting Foreign Visitors Module...");
                    resetModule();
                    llOwnerSay("Module reset complete.");
                }
                else if (message == "List Visitors") {
                    integer count = llGetListLength(foreignVisitors) / 6;
                    llOwnerSay("=== Registered Foreign Visitors (" + (string)count + ") ===");
                    
                    integer i;
                    integer idx;
                    string vName;
                    string vCountry;
                    string vCourt;
                    string vRank;
                    string vTitle;
                    string displayTitle;
                    
                    for (i = 0; i < count; i++) {
                        idx = i * 6;
                        vName = llList2String(foreignVisitors, idx + 1);
                        vCountry = llList2String(foreignVisitors, idx + 2);
                        vCourt = llList2String(foreignVisitors, idx + 3);
                        vRank = llList2String(foreignVisitors, idx + 4);
                        vTitle = llList2String(foreignVisitors, idx + 5);
                        
                        displayTitle = "";
                        if (vTitle != "") {
                            displayTitle = vTitle + " ";
                        }
                        llOwnerSay((string)(i+1) + ". " + displayTitle + vName + 
                                  " - " + vRank + " from " + vCourt + " of " + vCountry);
                    }
                }
            }
            else if (id == visitorKey && registrationStep > 0) {
                // Registration process steps
                if (registrationStep == 1) {
                    // Name provided
                    visitorName = message;
                    registrationStep = 2;
                    llInstantMessage(id, "Step 2/5: Please provide your country of origin:");
                }
                else if (registrationStep == 2) {
                    // Country provided
                    visitorCountry = message;
                    registrationStep = 3;
                    llInstantMessage(id, "Step 3/5: Please provide the name of your royal court or government:");
                }
                else if (registrationStep == 3) {
                    // Court provided
                    visitorCourt = message;
                    registrationStep = 4;
                    llInstantMessage(id, "Step 4/5: Please provide your rank or position (e.g., Ambassador, Prince, Minister):");
                }
                else if (registrationStep == 4) {
                    // Rank provided
                    visitorRank = message;
                    registrationStep = 5;
                    llInstantMessage(id, "Step 5/5: If you hold a title, please provide it (e.g., Duke, Baron), or type 'none' if you do not:");
                }
                else if (registrationStep == 5) {
                    // Title provided
                    if (llToLower(message) == "none") {
                        visitorTitle = "";
                    } else {
                        visitorTitle = message;
                    }
                    
                    // Complete registration
                    llInstantMessage(id, "Thank you for providing your credentials. Processing registration...");
                    completeRegistration();
                }
            }
        }
        else if (channel == SYSTEM_CHANNEL) {
            // Handle system messages
            list msgParts = llParseString2List(message, ["|"], []);
            string command = llList2String(msgParts, 0);
            string authKey = llList2String(msgParts, 1);
            
            if (authKey == AUTHENTICATION_KEY) {
                if (command == "GLOBAL_RESET") {
                    resetModule();
                }
                else if (command == "REMOVE_VISITOR") {
                    key visitorToRemove = (key)llList2String(msgParts, 2);
                    
                    // Find and remove the visitor
                    integer i;
                    integer count = llGetListLength(foreignVisitors) / 6;
                    integer visitorFound = FALSE;
                    integer idx;
                    
                    for (i = 0; i < count && !visitorFound; i++) {
                        if (llList2Key(foreignVisitors, i * 6) == visitorToRemove) {
                            // Remove this visitor's 6 entries
                            idx = i * 6;
                            foreignVisitors = llDeleteSubList(foreignVisitors, idx, idx + 5);
                            updateDisplay();
                            llSay(0, "A foreign visitor has departed from the Imperial Court.");
                            visitorFound = TRUE;
                        }
                    }
                }
                else if (command == "QUERY_VISITOR_STATUS") {
                    key visitorToQuery = (key)llList2String(msgParts, 2);
                    integer registered = isVisitorRegistered(visitorToQuery);
                    
                    // Reply with visitor status
                    string replyChannel = llList2String(msgParts, 3);
                    string visitorStatus = "UNREGISTERED";
                    if (registered) {
                        visitorStatus = "REGISTERED";
                    }
                    llRegionSay((integer)replyChannel, "VISITOR_STATUS|" + AUTHENTICATION_KEY + "|" + 
                               (string)visitorToQuery + "|" + visitorStatus);
                }
            }
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            // Reset if ownership changes
            llResetScript();
        }
    }
    
    on_rez(integer start_param) {
        // Reset when rezzed
        llResetScript();
    }
}