// Imperial Arts and Culture Module - Core Script
// Core controller for arts and culture system - coordinates all arts sub-modules

// Communication channels
integer ARTS_CORE_CHANNEL = -7654321;
integer BALLET_MODULE_CHANNEL = -7654322;
integer LITERATURE_MODULE_CHANNEL = -7654323;
integer PAINTING_MODULE_CHANNEL = -7654324;
integer MUSIC_MODULE_CHANNEL = -7654325;

// Player information
string playerName = "";
string playerTitle = "";
integer playerArtAppreciation = 0;
integer playerCulturalInfluence = 0;
string playerPreferredArt = "";

// Initialization function
integer initArtsSystem() {
    // Get player name
    playerName = llGetDisplayName(llGetOwner());
    llOwnerSay("Imperial Arts and Culture System initialized for " + playerName);
    
    // Request data from all sub-modules
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "INIT", NULL_KEY);
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "INIT", NULL_KEY);
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "INIT", NULL_KEY);
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "INIT", NULL_KEY);
    
    return TRUE;
}

// Display main arts menu
integer displayArtsMenu(key id) {
    llDialog(id, "Imperial Arts and Culture System\n\nSelect a category:",
        ["Ballet", "Literature", "Painting", "Music", "Patronize Arts", "Host Salon", "Back"], ARTS_CORE_CHANNEL);
    return TRUE;
}

// Patronize the arts
integer patronizeArts() {
    llOwnerSay("As a member of the imperial court, you have chosen to patronize the arts. Which artistic discipline would you like to support?");
    
    llDialog(llGetOwner(), "Select an artistic discipline to patronize:",
        ["Ballet Company", "Literary Society", "Art Exhibition", "Orchestra", "Cancel"], ARTS_CORE_CHANNEL);
    
    return TRUE;
}

// Host artistic salon
integer hostArtisticSalon() {
    llSay(0, playerName + " hosts an elegant cultural salon, inviting notable artists, writers, and musicians to showcase their talents.");
    
    // Effect on player stats
    playerCulturalInfluence += 3;
    
    // Social influence
    integer prestigeGain = (integer)(5 + llFrand(5));
    
    llOwnerSay("Your artistic salon has increased your cultural influence and prestige in court society.");
    llOwnerSay("Cultural Influence: " + (string)playerCulturalInfluence + " (+3)");
    llOwnerSay("Court Prestige: +" + (string)prestigeGain);
    
    // Random artistic event
    integer eventType = (integer)(llFrand(4.0));
    
    if(eventType == 0) {
        llSay(0, "A promising young ballet dancer performs an exquisite solo, captivating the guests.");
    }
    else if(eventType == 1) {
        llSay(0, "A celebrated poet recites verses composed in honor of the occasion, drawing appreciative applause.");
    }
    else if(eventType == 2) {
        llSay(0, "An up-and-coming painter unveils a striking new work, generating animated discussion among the connoisseurs present.");
    }
    else {
        llSay(0, "A talented pianist performs a technically challenging piece, demonstrating remarkable skill and sensitivity.");
    }
    
    return TRUE;
}

// Update player's art stats
integer updateArtStats(integer appreciationChange, integer influenceChange) {
    playerArtAppreciation += appreciationChange;
    playerCulturalInfluence += influenceChange;
    
    // Cap values
    if(playerArtAppreciation > 100) playerArtAppreciation = 100;
    if(playerCulturalInfluence > 100) playerCulturalInfluence = 100;
    
    llOwnerSay("Your artistic knowledge has been updated:\nArt Appreciation: " + (string)playerArtAppreciation + "/100\nCultural Influence: " + (string)playerCulturalInfluence + "/100");
    return TRUE;
}

default {
    state_entry() {
        llListen(ARTS_CORE_CHANNEL, "", NULL_KEY, "");
        initArtsSystem();
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        
        if(toucherId == llGetOwner()) {
            displayArtsMenu(toucherId);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(id != llGetOwner()) return;
        
        if(channel == ARTS_CORE_CHANNEL) {
            if(message == "Ballet") {
                llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Literature") {
                llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Painting") {
                llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Music") {
                llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "DISPLAY_MENU", id);
            }
            else if(message == "Patronize Arts") {
                patronizeArts();
            }
            else if(message == "Host Salon") {
                hostArtisticSalon();
                llSleep(3.0);
                displayArtsMenu(id);
            }
            else if(message == "Back") {
                // If this is part of a larger system, send a message to return to main menu
                // For now, just redisplay our menu
                displayArtsMenu(id);
            }
            // Patronage options
            else if(message == "Ballet Company") {
                llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "PATRONIZE", id);
            }
            else if(message == "Literary Society") {
                llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "PATRONIZE", id);
            }
            else if(message == "Art Exhibition") {
                llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "PATRONIZE", id);
            }
            else if(message == "Orchestra") {
                llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "PATRONIZE", id);
            }
            else if(message == "Cancel") {
                displayArtsMenu(id);
            }
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == BALLET_MODULE_CHANNEL || num == LITERATURE_MODULE_CHANNEL || 
           num == PAINTING_MODULE_CHANNEL || num == MUSIC_MODULE_CHANNEL) {
            
            list parts = llParseString2List(str, ["="], []);
            string cmd = llList2String(parts, 0);
            string value = llList2String(parts, 1);
            
            if(cmd == "UPDATE_APPRECIATION") {
                updateArtStats((integer)value, 0);
            }
            else if(cmd == "UPDATE_INFLUENCE") {
                updateArtStats(0, (integer)value);
            }
            else if(cmd == "DISPLAY_CORE_MENU") {
                displayArtsMenu(id);
            }
            else if(cmd == "SET_PREFERENCE") {
                playerPreferredArt = value;
                llOwnerSay("You have developed a preference for " + value + ".");
            }
        }
    }
}