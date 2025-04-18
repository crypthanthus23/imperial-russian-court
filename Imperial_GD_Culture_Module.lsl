// Imperial Grand Duchess Maria Pavlovna Sr. - Cultural Patronage Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer CULTURE_MODULE_CHANNEL = -8765435;

// Cultural Patronage Data
list culturalPatronage = [
    "Imperial Ballet", "Distinguished Patroness", "Premieres and Ballet Education",
    "Conservatory of Music", "Influential Supporter", "Concert Series and Scholarships",
    "Imperial Academy of Arts", "Honorary Member", "Exhibitions and Acquisitions",
    "Literary Society", "Occasional Sponsor", "Salons and Publications"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate cultural report
string generateCulturalReport() {
    string report = "Cultural Patronage:\n\n";
    
    integer i;
    integer count = llGetListLength(culturalPatronage);
    
    for(i = 0; i < count; i += 3) {
        string institution = llList2String(culturalPatronage, i);
        string role = llList2String(culturalPatronage, i+1);
        string activities = llList2String(culturalPatronage, i+2);
        
        report += institution + "\n";
        report += "   Role: " + role + "\n";
        report += "   Activities: " + activities + "\n\n";
    }
    
    return report;
}

// Patronize cultural institution
integer patronizeCulture(string institution) {
    integer idx = llListFindList(culturalPatronage, [institution]);
    
    if(idx != -1) {
        string role = llList2String(culturalPatronage, idx + 1);
        string activities = llList2String(culturalPatronage, idx + 2);
        
        llSay(0, playerFullTitle + " fulfills her role as " + role + " of the " + institution + ", focusing on " + activities + ".");
        
        // Send updates to core HUD
        llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
        llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "STRESS=+8", NULL_KEY);
        
        // Cultural donation
        integer donation = (integer)(llFrand(1000.0)) + 500;
        llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "RUBLES=-" + (string)donation, NULL_KEY);
        
        llOwnerSay("You have donated " + (string)donation + " rubles to " + institution + ".");
        
        // Special cases for certain institutions
        if(institution == "Imperial Ballet") {
            llSay(0, "The Grand Duchess attends a premiere performance at the Mariinsky Theatre, her presence and approval essential to the cultural season.");
            llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
        }
        else if(institution == "Conservatory of Music") {
            llSay(0, "The Grand Duchess hosts a musical evening featuring talented students from the Conservatory, enhancing their careers and her cultural standing.");
            llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "CHARM=+1", NULL_KEY);
        }
        else if(institution == "Imperial Academy of Arts") {
            llSay(0, "The Grand Duchess commissions works from promising artists at the Academy, establishing herself as a discerning art patron.");
            llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
            
            // Additional expense for art
            integer artCost = (integer)(llFrand(1500.0)) + 800;
            llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "RUBLES=-" + (string)artCost, NULL_KEY);
            llOwnerSay("You have spent an additional " + (string)artCost + " rubles on art acquisitions.");
        }
        else if(institution == "Literary Society") {
            llSay(0, "The Grand Duchess hosts literary discussions and readings, cultivating relationships with influential intellectual circles.");
            llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
        }
    }
    
    return idx != -1;
}

default {
    state_entry() {
        llListen(CULTURE_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == CULTURE_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateCulturalReport();
                llMessageLinked(LINK_SET, CULTURE_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "PATRONIZE_CULTURE") {
                patronizeCulture(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == CULTURE_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "PATRONIZE") {
                patronizeCulture(value);
            }
        }
    }
}