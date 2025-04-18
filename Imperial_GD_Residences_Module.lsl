// Imperial Grand Duchess Maria Pavlovna Sr. - Residences Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer RESIDENCES_MODULE_CHANNEL = -8765436;

// Residences Data
list residences = [
    "Vladimir Palace", "St. Petersburg", "Primary Residence",
    "Villa Vladimir", "Tsarskoye Selo", "Summer Residence",
    "Château de Beaulieu", "France", "European Estate",
    "Hunting Lodge", "Gatchina", "Seasonal Retreat"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate residences report
string generateResidencesReport() {
    string report = "Residences:\n\n";
    
    integer i;
    integer count = llGetListLength(residences);
    
    for(i = 0; i < count; i += 3) {
        string residence = llList2String(residences, i);
        string location = llList2String(residences, i+1);
        string status = llList2String(residences, i+2);
        
        report += residence + "\n";
        report += "   Location: " + location + "\n";
        report += "   Status: " + status + "\n\n";
    }
    
    return report;
}

// Visit a residence
integer visitResidence(string residence) {
    integer idx = llListFindList(residences, [residence]);
    
    if(idx != -1) {
        string location = llList2String(residences, idx + 1);
        string status = llList2String(residences, idx + 2);
        
        llSay(0, playerFullTitle + " visits her " + status + ", " + residence + " in " + location + ".");
        
        // Send update to reduce stress to core HUD
        llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "STRESS=-15", NULL_KEY);
        
        // Special activities based on residence
        if(residence == "Vladimir Palace") {
            llSay(0, "The Grand Duchess holds court at her magnificent palace on the Palace Embankment, the center of her social and political influence.");
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "STRESS=+10", NULL_KEY);
        }
        else if(residence == "Villa Vladimir") {
            llSay(0, "The Grand Duchess retreats to her country villa, planning her next social season and political moves away from the public eye.");
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "STRESS=-20", NULL_KEY);
        }
        else if(residence == "Château de Beaulieu") {
            llSay(0, "The Grand Duchess enjoys her French estate, connecting with European nobility and escaping the constraints of Russian court life.");
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "STRESS=-25", NULL_KEY);
            
            // Expenses for foreign travel
            integer expenses = (integer)(llFrand(5000.0)) + 3000;
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "RUBLES=-" + (string)expenses, NULL_KEY);
            
            llOwnerSay("Your European sojourn has cost " + (string)expenses + " rubles in expenses.");
        }
        else if(residence == "Hunting Lodge") {
            llSay(0, "The Grand Duchess enjoys a brief respite at the hunting lodge, away from the demands of court life.");
            llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "STRESS=-30", NULL_KEY);
            
            // Chance for social encounter
            if(llFrand(100.0) > 60.0) {
                llSay(0, "By fortunate coincidence, other nobles are present, providing an opportunity for informal connections.");
                llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
            }
        }
    }
    
    return idx != -1;
}

default {
    state_entry() {
        llListen(RESIDENCES_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == RESIDENCES_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateResidencesReport();
                llMessageLinked(LINK_SET, RESIDENCES_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "VISIT_RESIDENCE") {
                visitResidence(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == RESIDENCES_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "VISIT") {
                visitResidence(value);
            }
        }
    }
}