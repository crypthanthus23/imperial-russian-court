// Imperial Grand Duchess Maria Pavlovna Sr. - Court Factions Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer COURT_MODULE_CHANNEL = -8765434;

// Court Factions Data
list courtFactions = [
    "Conservative Nobility", "Strong Connections", "Significant Influence",
    "Military Leadership", "Husband's Connections", "Notable Influence",
    "Foreign Dignitaries", "International Background", "Diplomatic Connections",
    "Russian Orthodox Church", "Formal Relationship", "Limited Influence",
    "Liberal Aristocrats", "Cautious Distance", "Minimal Association"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate court report
string generateCourtReport() {
    string report = "Court Factions:\n\n";
    
    integer i;
    integer count = llGetListLength(courtFactions);
    
    for(i = 0; i < count; i += 3) {
        string faction = llList2String(courtFactions, i);
        string relationship = llList2String(courtFactions, i+1);
        string influence = llList2String(courtFactions, i+2);
        
        report += faction + "\n";
        report += "   Relationship: " + relationship + "\n";
        report += "   Influence: " + influence + "\n\n";
    }
    
    return report;
}

// Engage with court faction
integer engageCourtFaction(string faction) {
    integer idx = llListFindList(courtFactions, [faction]);
    
    if(idx != -1) {
        string relationship = llList2String(courtFactions, idx + 1);
        string influence = llList2String(courtFactions, idx + 2);
        
        llSay(0, playerFullTitle + " engages with the " + faction + ", where she has " + relationship + " and " + influence + ".");
        
        // Send updates to core HUD
        llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "STRESS=+10", NULL_KEY);
        
        // Special cases for certain factions
        if(faction == "Conservative Nobility") {
            llSay(0, "The Grand Duchess holds court with aristocratic families, reinforcing her position as a social leader and opinion-maker.");
            llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
        }
        else if(faction == "Military Leadership") {
            llSay(0, "The Grand Duchess hosts senior military officers, leveraging her husband's connections to maintain influence in military circles.");
            llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        }
        else if(faction == "Foreign Dignitaries") {
            llSay(0, "The Grand Duchess entertains ambassadors and foreign visitors, utilizing her international background and languages to great effect.");
            llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
            llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "CHARM=+3", NULL_KEY);
            
            // Chance to gain intelligence
            if(llFrand(100.0) > 70.0) {
                llOwnerSay("You have gained valuable diplomatic intelligence through your social connections.");
                llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
            }
        }
    }
    
    return idx != -1;
}

default {
    state_entry() {
        llListen(COURT_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == COURT_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateCourtReport();
                llMessageLinked(LINK_SET, COURT_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "ENGAGE_FACTION") {
                engageCourtFaction(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == COURT_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "ENGAGE") {
                engageCourtFaction(value);
            }
        }
    }
}