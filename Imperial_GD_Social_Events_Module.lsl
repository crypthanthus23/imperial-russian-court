// Imperial Grand Duchess Maria Pavlovna Sr. - Social Events Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer SOCIAL_EVENTS_MODULE_CHANNEL = -8765438;

// Social Events Data
list socialEvents = [
    "Grand Balls", "Seasonal", "High Society Gathering Point",
    "Musical Evenings", "Monthly", "Cultural Patronage Display",
    "Diplomatic Receptions", "Quarterly", "International Relations Nexus",
    "Charity Galas", "Bi-Annual", "Philanthropic Reputation Building",
    "Hunt Parties", "Autumn Season", "Noble Networking Opportunity"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate social events report
string generateSocialReport() {
    string report = "Social Events:\n\n";
    
    integer i;
    integer count = llGetListLength(socialEvents);
    
    for(i = 0; i < count; i += 3) {
        string eventName = llList2String(socialEvents, i);
        string frequency = llList2String(socialEvents, i+1);
        string purpose = llList2String(socialEvents, i+2);
        
        report += eventName + "\n";
        report += "   Frequency: " + frequency + "\n";
        report += "   Purpose: " + purpose + "\n\n";
    }
    
    return report;
}

// Host social event
integer hostSocialEvent(string eventType) {
    integer idx = llListFindList(socialEvents, [eventType]);
    
    if(idx != -1) {
        string frequency = llList2String(socialEvents, idx + 1);
        string purpose = llList2String(socialEvents, idx + 2);
        
        llSay(0, playerFullTitle + " hosts " + frequency + " " + eventType + " at Vladimir Palace, serving as " + purpose + ".");
        
        // Send updates to core HUD
        llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
        llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
        llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "STRESS=+15", NULL_KEY);
        
        // Entertainment expenses
        integer expenses = (integer)(llFrand(2000.0)) + 1000;
        llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "RUBLES=-" + (string)expenses, NULL_KEY);
        
        llOwnerSay("Your social event has cost " + (string)expenses + " rubles to host.");
        
        // Special effects for certain events
        if(eventType == "Grand Balls") {
            llSay(0, "The Grand Duchess's ball is the highlight of the social season, drawing the elite of Russian society and diplomatic corps.");
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
            
            // Chance for imperial attendance
            if(llFrand(100.0) > 75.0) {
                llSay(0, "The Tsar himself makes an appearance, elevating the social gathering to the pinnacle of social success.");
                llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
            }
        }
        else if(eventType == "Diplomatic Receptions") {
            llSay(0, "The Grand Duchess showcases her diplomatic skills, facilitating unofficial connections that complement official state relations.");
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
        }
        else if(eventType == "Musical Evenings") {
            llSay(0, "The Grand Duchess highlights emerging musical talents, earning gratitude from artists and admiration from cultural circles.");
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "CHARM=+3", NULL_KEY);
        }
        else if(eventType == "Charity Galas") {
            llSay(0, "The Grand Duchess demonstrates her benevolence, raising funds for worthy causes while enhancing her public reputation.");
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+1", NULL_KEY);
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "CHARM=+3", NULL_KEY);
            
            // Additional charitable donation
            integer donation = (integer)(llFrand(3000.0)) + 1000;
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "RUBLES=-" + (string)donation, NULL_KEY);
            llOwnerSay("You have personally donated an additional " + (string)donation + " rubles to charity.");
        }
        else if(eventType == "Hunt Parties") {
            llSay(0, "The Grand Duchess organizes an aristocratic hunt, providing opportunities for informal political discussions away from the capital.");
            llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        }
    }
    
    return TRUE;
}

default {
    state_entry() {
        llListen(SOCIAL_EVENTS_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == SOCIAL_EVENTS_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateSocialReport();
                llMessageLinked(LINK_SET, SOCIAL_EVENTS_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "HOST_EVENT") {
                hostSocialEvent(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == SOCIAL_EVENTS_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "HOST") {
                hostSocialEvent(value);
            }
        }
    }
}