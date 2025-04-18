// Imperial Grand Duchess Maria Pavlovna Sr. - Family Relations Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer FAMILY_MODULE_CHANNEL = -8765433;

// Family Relations Data
list familyRelations = [
    "Grand Duke Vladimir Alexandrovich", "Husband", "Political Partnership",
    "Kyrill Vladimirovich", "Son", "Dynastic Ambitions",
    "Boris Vladimirovich", "Son", "Social Support",
    "Andrei Vladimirovich", "Son", "Maternal Affection",
    "Elena Vladimirovna", "Daughter", "Marital Prospects",
    "Nicholas II", "Nephew (Tsar)", "Formal Deference, Private Rivalry",
    "Alexandra Feodorovna", "Niece-in-law (Tsarina)", "Cold Antagonism",
    "Maria Feodorovna", "Sister-in-law (Dowager Empress)", "Rival Court Faction"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate family report
string generateFamilyReport() {
    string report = "Family Relations:\n\n";
    
    integer i;
    integer count = llGetListLength(familyRelations);
    
    for(i = 0; i < count; i += 3) {
        string member = llList2String(familyRelations, i);
        string relation = llList2String(familyRelations, i+1);
        string status = llList2String(familyRelations, i+2);
        
        report += member + "\n";
        report += "   Relation: " + relation + "\n";
        report += "   Status: " + status + "\n\n";
    }
    
    return report;
}

// Meet with family member
integer meetFamilyMember(string member) {
    integer idx = llListFindList(familyRelations, [member]);
    
    if(idx != -1) {
        string relation = llList2String(familyRelations, idx + 1);
        string status = llList2String(familyRelations, idx + 2);
        
        llSay(0, playerFullTitle + " meets with " + member + ", her " + relation + ". They have a " + status + " relationship.");
        
        // Special cases for certain family members
        if(member == "Grand Duke Vladimir Alexandrovich") {
            llSay(0, "The Grand Duchess discusses court politics and their social strategy with her husband, coordinating their influential position.");
            // Notify main script to update influence
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        }
        else if(member == "Kyrill Vladimirovich") {
            llSay(0, "The Grand Duchess has a private conversation with her eldest son about his position in the imperial succession and dynastic prospects.");
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "STRESS=+10", NULL_KEY);
        }
        else if(member == "Nicholas II") {
            llSay(0, "The Grand Duchess pays a formal visit to the Tsar, maintaining the appropriate deference while subtly asserting her status.");
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "STRESS=+15", NULL_KEY);
        }
        else if(member == "Alexandra Feodorovna") {
            llSay(0, "The Grand Duchess exchanges cool pleasantries with the Tsarina, their mutual antipathy barely concealed beneath formal courtesies.");
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "INFLUENCE=-1", NULL_KEY);
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "STRESS=+20", NULL_KEY);
        }
        else if(member == "Maria Feodorovna") {
            llSay(0, "The Grand Duchess and the Dowager Empress engage in a subtle contest of precedence and influence, each leading rival court factions.");
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
            llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "STRESS=+15", NULL_KEY);
        }
    }
    
    return idx != -1;
}

default {
    state_entry() {
        llListen(FAMILY_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == FAMILY_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateFamilyReport();
                llMessageLinked(LINK_SET, FAMILY_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "MEET_MEMBER") {
                meetFamilyMember(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == FAMILY_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "MEET") {
                meetFamilyMember(value);
            }
        }
    }
}