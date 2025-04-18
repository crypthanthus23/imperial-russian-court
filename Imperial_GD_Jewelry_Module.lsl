// Imperial Grand Duchess Maria Pavlovna Sr. - Jewelry Collection Module

// Channel for communication
integer MARIA_PAVLOVNA_SR_CHANNEL = -8765432;
integer JEWELRY_MODULE_CHANNEL = -8765437;

// Jewelry Collection Data
list jewelCollection = [
    "Vladimir Tiara", "Romanov Treasury", "State Functions and Court Balls",
    "Sapphire Parure", "Wedding Gift", "Formal Occasions and Diplomatic Receptions",
    "Emerald Diadem", "Personal Commission", "Gala Events and Theatre Premieres",
    "Pearl Necklace", "Family Heirloom", "Daily Court Appearances",
    "Diamond Rivière", "Ancestral Legacy", "Special Royal Occasions"
];

// Player information
string playerFullTitle = "Her Imperial Highness Grand Duchess Maria Pavlovna of Russia";

// Generate jewelry report
string generateJewelryReport() {
    string report = "Jewelry Collection:\n\n";
    
    integer i;
    integer count = llGetListLength(jewelCollection);
    
    for(i = 0; i < count; i += 3) {
        string piece = llList2String(jewelCollection, i);
        string origin = llList2String(jewelCollection, i+1);
        string significance = llList2String(jewelCollection, i+2);
        
        report += piece + "\n";
        report += "   Origin: " + origin + "\n";
        report += "   Significance: " + significance + "\n\n";
    }
    
    return report;
}

// Wear jewelry piece
integer wearJewelry(string piece) {
    integer idx = llListFindList(jewelCollection, [piece]);
    
    if(idx != -1) {
        string origin = llList2String(jewelCollection, idx + 1);
        string significance = llList2String(jewelCollection, idx + 2);
        
        llSay(0, playerFullTitle + " wears her magnificent " + piece + " from " + origin + ", appropriate for " + significance + ".");
        
        // Send update to core HUD
        llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "CHARM=+3", NULL_KEY);
        
        // Special effects for certain pieces
        if(piece == "Vladimir Tiara") {
            llSay(0, "The Grand Duchess's appearance in her iconic tiara creates a sensation, reinforcing her status as the preeminent hostess of St. Petersburg.");
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "INFLUENCE=+3", NULL_KEY);
        }
        else if(piece == "Sapphire Parure") {
            llSay(0, "The Grand Duchess's sapphire suite dazzles at the formal occasion, rivaling the imperial jewels in splendor.");
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
        }
        else if(piece == "Emerald Diadem") {
            llSay(0, "The Grand Duchess's emerald diadem accentuates her regal bearing, drawing admiring glances and whispers of appreciation.");
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
        }
        else if(piece == "Pearl Necklace") {
            llSay(0, "The Grand Duchess's elegant pearl necklace complements her refined appearance, a subtle statement of timeless aristocratic taste.");
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "CHARM=+1", NULL_KEY);
        }
        else if(piece == "Diamond Rivière") {
            llSay(0, "The Grand Duchess's spectacular diamond necklace catches the light magnificently, establishing her as one of the most brilliantly adorned figures at court.");
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "INFLUENCE=+2", NULL_KEY);
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "CHARM=+2", NULL_KEY);
        }
        
        // Chance to commission new piece
        if(llFrand(100.0) > 80.0) {
            integer cost = (integer)(llFrand(5000.0)) + 3000;
            llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "RUBLES=-" + (string)cost, NULL_KEY);
            
            llSay(0, "The Grand Duchess commissions a new jewel from the court jeweler, adding to her legendary collection.");
            llOwnerSay("You have spent " + (string)cost + " rubles on a new jewelry commission.");
        }
    }
    
    return idx != -1;
}

default {
    state_entry() {
        llListen(JEWELRY_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == JEWELRY_MODULE_CHANNEL) {
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "GENERATE_REPORT") {
                string report = generateJewelryReport();
                llMessageLinked(LINK_SET, JEWELRY_MODULE_CHANNEL, "REPORT=" + report, id);
            }
            else if(cmd == "WEAR_JEWELRY") {
                wearJewelry(value);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == JEWELRY_MODULE_CHANNEL) {
            // Process direct commands through chat
            list parts = llParseString2List(message, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "WEAR") {
                wearJewelry(value);
            }
        }
    }
}