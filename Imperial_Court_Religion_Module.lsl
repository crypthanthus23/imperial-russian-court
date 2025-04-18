// Imperial Russian Court HUD - Religion Module
// Handles faith, religious activities, sacred relics, and church functions
// This module communicates with the main HUD

// ============= CONSTANTS =============
// Communication Channels
integer MAIN_HUD_CHANNEL = -9876543; // Channel to communicate with main HUD
integer RELIGION_CHANNEL = -98014;   // Channel for religious activities
integer RELIC_CHANNEL = -98018;      // Channel for relics and icons

// Sacred Relics and Icons
list SACRED_RELICS = [
    "Icon of Christ Pantocrator",
    "Icon of the Theotokos",
    "Relic of St. Andrew",
    "Icon of St. Nicholas",
    "Relic of the True Cross",
    "Icon of St. Seraphim of Sarov",
    "Iveron Icon of the Mother of God",
    "Relic of St. Alexander Nevsky",
    "Kazan Icon of the Mother of God",
    "Kursk Root Icon"
];

// Miracle powers of relics
list RELIC_POWERS = [
    "health_restore",     // Full health restoration
    "faith_increase",     // Major faith increase
    "wealth_blessing",    // Economic blessing (rubles)
    "resurrection",       // Resurrect from death
    "imperial_favor",     // Increase imperial favor
    "family_blessing",    // Blesses entire family
    "fertility_blessing", // Increases chance of children
    "protection",         // Temporary immunity to illness
    "wisdom",             // Temporary boost to influence
    "forgiveness"         // Clear all sins/bad reputation
];

// ============= VARIABLES =============
// Basic Character Data
key ownerID;
string firstName = "";
string familyName = "";
integer playerClass = -1; 
integer rank = 0;
integer faith = 15; // Faith stat for religious participation (0-100)
integer isDead = FALSE; // Whether player is dead (0 health)

// Church and Religion
list ownedRelics = []; // Sacred relics/icons owned by player
list venerated = []; // Relics player has venerated (daily cooldown)
integer confessionDate = 0; // Last confession timestamp
integer lastCommunion = 0; // Last communion timestamp
list miracles = []; // Miracles experienced (healing, etc.)
integer hasPilgrimage = FALSE; // Whether completed pilgrimage
integer churchDonations = 0; // Total donations to church
integer religiousRank = 0; // Religious title/rank in church

// System Variables
list activeListeners = []; // Track active listeners
string currentState = "INIT"; // Track current menu/state
integer lastFaithUpdate = 0; // Last faith update timestamp
integer dayInSeconds = 86400; // 24 hours in seconds

// ============= FUNCTIONS =============
// Function to show religion menu
showReligionMenu() {
    string menuText = "\n=== ORTHODOX CHURCH ===\n\n";
    menuText += "Faith: " + (string)faith + "/100\n";
    
    if (playerClass == 2) { // Clergy
        menuText += "Religious Rank: " + getClericRankName(religiousRank) + "\n";
    }
    
    menuText += "Owned Relics: " + (string)llGetListLength(ownedRelics) + "\n\n";
    menuText += "What would you like to do?";
    
    list buttons = ["Pray", "Confession", "Communion", "Donate", "Cathedral", "Back"];
    
    if (playerClass == 2) { // Clergy
        buttons += ["Bless"];
    }
    
    llDialog(ownerID, menuText, buttons, RELIGION_CHANNEL);
    currentState = "RELIGION_MENU";
}

// Function to get cleric rank name
string getClericRankName(integer rankNum) {
    if (rankNum == 0) return "Patriarch";
    else if (rankNum == 1) return "Metropolitan";
    else if (rankNum == 2) return "Archbishop";
    else if (rankNum == 3) return "Bishop";
    else if (rankNum == 4) return "Priest";
    else return "Acolyte";
}

// Function to show relics menu
showRelicsMenu() {
    string menuText = "\n=== SACRED RELICS & ICONS ===\n\n";
    
    if (llGetListLength(ownedRelics) > 0) {
        menuText += "Your Sacred Items:\n";
        integer i;
        for (i = 0; i < llGetListLength(ownedRelics); i++) {
            menuText += "- " + llList2String(ownedRelics, i) + "\n";
        }
    } else {
        menuText += "You do not own any sacred relics or icons.\n";
    }
    
    if (isDead) {
        menuText += "\nAs you are deceased, you may pray to a relic for resurrection.\n";
    }
    
    menuText += "\nSelect a relic to venerate:";
    
    // Only show a few relics at a time (dialog has limited buttons)
    list buttons = [];
    integer startIndex = 0;
    
    // Calculate the minimum value between startIndex + 9 and list length
    integer maxPossibleIndex = startIndex + 9;
    integer listLength = llGetListLength(SACRED_RELICS);
    integer endIndex;
    
    if (maxPossibleIndex < listLength) {
        endIndex = maxPossibleIndex;
    } else {
        endIndex = listLength;
    }
    
    integer i;
    for (i = startIndex; i < endIndex; i++) {
        buttons += [llList2String(SACRED_RELICS, i)];
    }
    
    // Add navigation buttons
    if (endIndex < llGetListLength(SACRED_RELICS)) {
        buttons += ["Next"];
    }
    buttons += ["Back"];
    
    llDialog(ownerID, menuText, buttons, RELIC_CHANNEL);
    currentState = "RELICS_MENU";
}

// Function to venerate a relic
venerateRelic(string relicName) {
    // Check if already venerated today
    integer relicIndex = llListFindList(venerated, [relicName]);
    
    if (relicIndex != -1) {
        llOwnerSay("You have already venerated the " + relicName + " today. Please return tomorrow.");
        showRelicsMenu();
        return;
    }
    
    // Add to venerated list
    venerated += [relicName];
    
    // Basic faith increase
    integer faithIncrease = 5 + llFloor(llFrand(6.0)); // 5-10 faith points
    
    // Check for owned relic bonus
    integer ownedIndex = llListFindList(ownedRelics, [relicName]);
    if (ownedIndex != -1) {
        faithIncrease += 5; // Extra faith for venerating your own relic
    }
    
    // Update faith
    faith += faithIncrease;
    if (faith > 100) faith = 100;
    
    // Send faith update to main HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
    
    llOwnerSay("You venerate the " + relicName + " with great devotion.");
    llOwnerSay("Your faith has increased by " + (string)faithIncrease + " points.");
    
    // Check for miracle (small chance)
    if (llFrand(100.0) < 5.0 + (faith * 0.1)) { // 5-15% chance based on faith
        // Get power index for this relic
        integer powerIndex = llListFindList(SACRED_RELICS, [relicName]);
        if (powerIndex != -1 && powerIndex < llGetListLength(RELIC_POWERS)) {
            string power = llList2String(RELIC_POWERS, powerIndex);
            miracleEffect(power, relicName);
        }
    }
    
    // Return to relics menu
    showRelicsMenu();
}

// Function for miracle effects
miracleEffect(string power, string relicName) {
    // Record miracle
    miracles += [power + "|" + relicName + "|" + (string)llGetUnixTime()];
    
    // Apply miracle effect
    if (power == "health_restore") {
        llMessageLinked(LINK_SET, 0, "MIRACLE_HEALTH_RESTORE", NULL_KEY);
        llOwnerSay("MIRACLE: The " + relicName + " glows with divine light, and you feel your health fully restored!");
    }
    else if (power == "faith_increase") {
        faith += 25;
        if (faith > 100) faith = 100;
        llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
        llOwnerSay("MIRACLE: The " + relicName + " imparts a profound spiritual revelation, greatly increasing your faith!");
    }
    else if (power == "wealth_blessing") {
        integer blessing = 100 + llFloor(llFrand(901.0)); // 100-1000 rubles
        llMessageLinked(LINK_SET, 0, "ADD_RUBLES|" + (string)blessing, NULL_KEY);
        llOwnerSay("MIRACLE: After venerating the " + relicName + ", you discover a purse containing " + (string)blessing + " rubles!");
    }
    else if (power == "resurrection" && isDead) {
        llMessageLinked(LINK_SET, 0, "MIRACLE_RESURRECTION", NULL_KEY);
        llOwnerSay("MIRACLE: Through the divine power of the " + relicName + ", your soul is restored to your body!");
    }
    // Other miracle effects would be implemented here
}

// Function to make a confession
makeConfession() {
    integer currentTime = llGetUnixTime();
    
    // Check if already confessed recently (1 day cooldown)
    if (currentTime - confessionDate < dayInSeconds) {
        llOwnerSay("You have already made your confession today. Return tomorrow.");
        showReligionMenu();
        return;
    }
    
    // Update confession date
    confessionDate = currentTime;
    
    // Faith benefit
    integer faithIncrease = 10 + llFloor(llFrand(6.0)); // 10-15 faith points
    faith += faithIncrease;
    if (faith > 100) faith = 100;
    
    // Send faith update to main HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
    
    llOwnerSay("You have made your confession to the priest, who grants you absolution.");
    llOwnerSay("Your faith has increased by " + (string)faithIncrease + " points.");
    llOwnerSay("Your reputation has been restored in the eyes of the Church.");
    
    // Reputation benefit
    llMessageLinked(LINK_SET, 0, "INCREASE_REPUTATION|10", NULL_KEY);
    
    showReligionMenu();
}

// Function to take communion
takeCommunion() {
    integer currentTime = llGetUnixTime();
    
    // Check if already took communion recently (1 day cooldown)
    if (currentTime - lastCommunion < dayInSeconds) {
        llOwnerSay("You have already taken communion today. Return tomorrow.");
        showReligionMenu();
        return;
    }
    
    // Update communion date
    lastCommunion = currentTime;
    
    // Faith benefit
    integer faithIncrease = 15 + llFloor(llFrand(11.0)); // 15-25 faith points
    faith += faithIncrease;
    if (faith > 100) faith = 100;
    
    // Health benefit
    llMessageLinked(LINK_SET, 0, "INCREASE_HEALTH|5", NULL_KEY);
    
    // Send faith update to main HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
    
    llOwnerSay("You receive the Holy Sacrament with reverence.");
    llOwnerSay("Your faith has increased by " + (string)faithIncrease + " points.");
    llOwnerSay("Your body and soul feel refreshed by the communion.");
    
    showReligionMenu();
}

// Function to make a donation
makeDonation() {
    string menuText = "\n=== CHURCH DONATION ===\n\n";
    menuText += "How much would you like to donate to the Church?";
    
    list buttons = ["5", "10", "25", "50", "100", "Cancel"];
    
    llDialog(ownerID, menuText, buttons, RELIGION_CHANNEL);
    currentState = "DONATION";
}

// Process donation
processDonation(string amount) {
    if (amount == "Cancel") {
        showReligionMenu();
        return;
    }
    
    integer donationAmount = (integer)amount;
    
    // Check with main HUD if player has enough rubles
    llMessageLinked(LINK_SET, 0, "CHECK_RUBLES|" + (string)donationAmount + "|DONATION", NULL_KEY);
}

// Initialize the module
initialize() {
    // Get owner key
    ownerID = llGetOwner();
    
    // Reset dialog listeners
    integer i;
    for (i = 0; i < llGetListLength(activeListeners); i++) {
        llListenRemove(llList2Integer(activeListeners, i));
    }
    activeListeners = [];
    
    // Set up listeners
    activeListeners += [llListen(RELIGION_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(RELIC_CHANNEL, "", NULL_KEY, "")];
    
    // Request data from main HUD
    llMessageLinked(LINK_SET, 0, "REQUEST_RELIGION_DATA", NULL_KEY);
    
    llOwnerSay("Religion Module initialized.");
}

default {
    state_entry() {
        initialize();
    }
    
    touch_start(integer total_number) {
        if (llDetectedKey(0) == llGetOwner()) {
            showReligionMenu();
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (id != ownerID) return;
        
        if (channel == RELIGION_CHANNEL) {
            if (currentState == "RELIGION_MENU") {
                if (message == "Pray") {
                    // Simple prayer
                    integer faithIncrease = 2 + llFloor(llFrand(4.0)); // 2-5 faith points
                    faith += faithIncrease;
                    if (faith > 100) faith = 100;
                    
                    // Send faith update to main HUD
                    llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
                    
                    llOwnerSay("You pray fervently for a moment.");
                    llOwnerSay("Your faith has increased by " + (string)faithIncrease + " points.");
                    showReligionMenu();
                }
                else if (message == "Confession") {
                    makeConfession();
                }
                else if (message == "Communion") {
                    takeCommunion();
                }
                else if (message == "Donate") {
                    makeDonation();
                }
                else if (message == "Cathedral") {
                    showRelicsMenu();
                }
                else if (message == "Back") {
                    // Tell main HUD to show main menu
                    llMessageLinked(LINK_SET, 0, "SHOW_MAIN_MENU", NULL_KEY);
                }
            }
            else if (currentState == "DONATION") {
                processDonation(message);
            }
        }
        else if (channel == RELIC_CHANNEL) {
            if (currentState == "RELICS_MENU") {
                if (message == "Back") {
                    showReligionMenu();
                }
                else if (message == "Next") {
                    // This would implement pagination for a large list of relics
                    // Simplified version for now
                    showRelicsMenu();
                }
                else {
                    // Check if selected relic exists
                    integer relicIndex = llListFindList(SACRED_RELICS, [message]);
                    if (relicIndex != -1) {
                        venerateRelic(message);
                    }
                }
            }
        }
    }
    
    link_message(integer sender_num, integer num, string message, key id) {
        list msgParts = llParseString2List(message, ["|"], []);
        string command = llList2String(msgParts, 0);
        
        if (command == "RELIGION_DATA") {
            // Receiving religion data from main HUD
            if (llGetListLength(msgParts) >= 6) {
                firstName = llList2String(msgParts, 1);
                familyName = llList2String(msgParts, 2);
                playerClass = (integer)llList2String(msgParts, 3);
                rank = (integer)llList2String(msgParts, 4);
                faith = (integer)llList2String(msgParts, 5);
                isDead = (integer)llList2String(msgParts, 6);
                
                // Process owned relics if present
                if (llGetListLength(msgParts) >= 8) {
                    string relicString = llList2String(msgParts, 7);
                    ownedRelics = llParseString2List(relicString, [";"], []);
                    
                    string veneratedString = llList2String(msgParts, 8);
                    venerated = llParseString2List(veneratedString, [";"], []);
                }
            }
        }
        else if (command == "SHOW_RELIGION_MENU") {
            showReligionMenu();
        }
        else if (command == "SHOW_RELICS_MENU") {
            showRelicsMenu();
        }
        else if (command == "DONATION_RESULT") {
            // Process donation result
            if (llGetListLength(msgParts) >= 3) {
                string result = llList2String(msgParts, 1);
                integer amount = (integer)llList2String(msgParts, 2);
                
                if (result == "SUCCESS") {
                    // Record donation
                    churchDonations += amount;
                    
                    // Faith benefit
                    integer faithIncrease = llFloor(amount / 10.0) + 1; // 1 faith per 10 rubles
                    faith += faithIncrease;
                    if (faith > 100) faith = 100;
                    
                    // Send faith update to main HUD
                    llMessageLinked(LINK_SET, 0, "UPDATE_FAITH|" + (string)faith, NULL_KEY);
                    
                    llOwnerSay("You donate " + (string)amount + " rubles to the Church.");
                    llOwnerSay("Your faith has increased by " + (string)faithIncrease + " points.");
                    llOwnerSay("The Church appreciates your generosity.");
                    
                    // Reputation benefit
                    llMessageLinked(LINK_SET, 0, "INCREASE_REPUTATION|" + (string)(amount / 20), NULL_KEY);
                }
                else {
                    llOwnerSay("You don't have enough rubles to make this donation.");
                }
                
                showReligionMenu();
            }
        }
    }
}