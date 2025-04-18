// Imperial Court Etiquette Core Module
// Core controller for etiquette system - coordinates all etiquette sub-modules

// Communication channels
integer ETIQUETTE_CORE_CHANNEL = -9876543;
integer ETIQUETTE_FORMS_CHANNEL = -9876544;
integer ETIQUETTE_PRECEDENCE_CHANNEL = -9876545;
integer ETIQUETTE_CUSTOMS_CHANNEL = -9876546;

// Player information
string playerName = "";
string playerTitle = "";
integer playerEtiquetteRank = 0;
integer playerProtocolMastery = 0;
string playerCurrentAddress = "";

// Function to initialize the etiquette system
integer initEtiquetteSystem() {
    // Get player name
    playerName = llGetDisplayName(llGetOwner());
    llOwnerSay("Imperial Court Protocol and Etiquette System initialized for " + playerName);
    
    // Request data from all sub-modules
    llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "INIT", NULL_KEY);
    llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "INIT", NULL_KEY);
    llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "INIT", NULL_KEY);
    
    return TRUE;
}

// Display main etiquette menu
integer displayEtiquetteMenu(key id) {
    llDialog(id, "Imperial Court Protocol and Etiquette System\n\nSelect a category:",
        ["Forms of Address", "Order of Precedence", "Court Customs", "Request Instruction", "Back"], ETIQUETTE_CORE_CHANNEL);
    return TRUE;
}

// Request proper etiquette instruction
integer requestInstruction() {
    // Calculate which area needs most improvement
    if(playerEtiquetteRank < 3) {
        llOwnerSay("The Court Chamberlain suggests you study the basic Forms of Address first.");
        llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "STUDY_BASIC", NULL_KEY);
    }
    else if(playerProtocolMastery < 5) {
        llOwnerSay("The Court Chamberlain recommends focusing on Order of Precedence for your next studies.");
        llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "STUDY_INTERMEDIATE", NULL_KEY);
    }
    else {
        llOwnerSay("The Court Chamberlain suggests you refine your knowledge of Court Customs and Ceremonies.");
        llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "STUDY_ADVANCED", NULL_KEY);
    }
    return TRUE;
}

// Update player's etiquette stats
integer updateEtiquetteStats(integer rankChange, integer masteryChange) {
    playerEtiquetteRank += rankChange;
    playerProtocolMastery += masteryChange;
    
    // Cap values
    if(playerEtiquetteRank > 10) playerEtiquetteRank = 10;
    if(playerProtocolMastery > 10) playerProtocolMastery = 10;
    
    llOwnerSay("Your etiquette knowledge has been updated:\nRank: " + (string)playerEtiquetteRank + "/10\nProtocol Mastery: " + (string)playerProtocolMastery + "/10");
    return TRUE;
}

default {
    state_entry() {
        llListen(ETIQUETTE_CORE_CHANNEL, "", NULL_KEY, "");
        initEtiquetteSystem();
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        
        if(toucherId == llGetOwner()) {
            displayEtiquetteMenu(toucherId);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(id != llGetOwner()) return;
        
        if(channel == ETIQUETTE_CORE_CHANNEL) {
            if(message == "Forms of Address") {
                llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Order of Precedence") {
                llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Court Customs") {
                llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Request Instruction") {
                requestInstruction();
                displayEtiquetteMenu(id);
            }
            else if(message == "Back") {
                // If this is part of a larger system, send a message to return to main menu
                // For now, just redisplay our menu
                displayEtiquetteMenu(id);
            }
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == ETIQUETTE_FORMS_CHANNEL || num == ETIQUETTE_PRECEDENCE_CHANNEL || num == ETIQUETTE_CUSTOMS_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "UPDATE_RANK") {
                updateEtiquetteStats((integer)value, 0);
            }
            else if(cmd == "UPDATE_MASTERY") {
                updateEtiquetteStats(0, (integer)value);
            }
            else if(cmd == "DISPLAY_CORE_MENU") {
                displayEtiquetteMenu(id);
            }
        }
    }
}