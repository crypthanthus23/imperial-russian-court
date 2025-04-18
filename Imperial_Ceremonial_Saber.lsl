// Imperial Russian Court Roleplay System
// Script: Imperial Ceremonial Saber
// Version: 1.0
// Description: Interactive ceremonial saber that allows duels of honor and recognizes military ranks

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer COMBAT_CHANNEL = -8675314; // Channel for combat-related messages
integer DUEL_CHANNEL = -8675315;  // Specific channel for duels

// Saber type constants
integer SABER_TYPE_STANDARD = 0;  // Regular officer's saber
integer SABER_TYPE_COSSACK = 1;   // Cossack shashka (slightly curved)
integer SABER_TYPE_CAVALRY = 2;   // Cavalry saber (more curved)
integer SABER_TYPE_GUARD = 3;     // Imperial Guard ceremonial saber (ornate)
integer SABER_TYPE_IMPERIAL = 4;  // Imperial presentation saber (highest quality)

// Military rank constants
integer RANK_CIVILIAN = 0;        // Non-military
integer RANK_ENLISTED = 1;        // Enlisted soldier
integer RANK_JUNIOR_OFFICER = 2;  // Lieutenant, etc.
integer RANK_SENIOR_OFFICER = 3;  // Captain, Major
integer RANK_COLONEL = 4;         // Colonel
integer RANK_GENERAL = 5;         // General
integer RANK_IMPERIAL = 6;        // Tsar, Imperial Family

// Status variables
integer currentSaberType = SABER_TYPE_STANDARD;
string saberName = "Imperial Officer's Ceremonial Saber";
string saberDescription = "Standard ceremonial saber of the Imperial Russian Army";
integer saberQuality = 5;         // Quality level from 1-10
integer combatEnabled = FALSE;    // Is this saber allowed for actual combat/duels
integer permissionMask = 7;       // Binary mask of who can use: 1=civilian, 2=officer, 4=noble
integer minRankRequired = RANK_JUNIOR_OFFICER; // Minimum rank to use properly
integer listenHandle;             // Handle for the listen event

// Duel variables
key duelChallengerKey = NULL_KEY; // Person who initiated a duel
key duelOpponentKey = NULL_KEY;   // Person who was challenged
integer duelAccepted = FALSE;     // Has the duel been accepted
integer duelInProgress = FALSE;   // Is a duel currently happening
integer duelRounds = 3;           // Number of rounds in the duel
integer duelType = 0;             // 0=honor (non-lethal), 1=blood (damage)

// Animation names
string ANIM_GUARD = "saber_guard";           // Ready stance
string ANIM_SALUTE = "saber_salute";         // Military salute with saber
string ANIM_SLASH = "saber_slash";           // Attack - slash
string ANIM_PARRY = "saber_parry";           // Defense - parry
string ANIM_FLOURISH = "saber_flourish";     // Ceremonial flourish

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to get the military rank of an avatar (would connect to HUD system)
// For demonstration, simplified to recognize Tsar and Zarevich
integer getMilitaryRank(key avatarKey) {
    // Special case for the Tsar
    if (isTsar(avatarKey)) {
        return RANK_IMPERIAL; // Tsar is Commander-in-Chief
    }
    
    // Special case for the Zarevich
    if (isZarevich(avatarKey)) {
        return RANK_IMPERIAL; // Imperial family
    }
    
    // In a real implementation, would query the Core HUD
    // For demonstration, assume junior officer rank
    return RANK_JUNIOR_OFFICER;
}

// Function to check if an avatar can properly use this saber
integer canUseSaber(key avatarKey) {
    integer rank = getMilitaryRank(avatarKey);
    
    // The Tsar can use any saber
    if (rank == RANK_IMPERIAL) return TRUE;
    
    // Check if their rank meets the minimum
    if (rank >= minRankRequired) {
        
        // Check if their type is allowed by the permission mask
        if (rank == RANK_CIVILIAN && (permissionMask & 1)) return TRUE;
        if (rank >= RANK_JUNIOR_OFFICER && rank <= RANK_GENERAL && (permissionMask & 2)) return TRUE;
        // Nobles would be checked with permissionMask & 4
    }
    
    return FALSE;
}

// Function to execute a ceremonial salute
performSalute(key avatarKey) {
    // Request permission to animate the avatar
    llRequestPermissions(avatarKey, PERMISSION_TRIGGER_ANIMATION);
    
    // When granted in run_time_permissions, we'll play ANIM_SALUTE
    
    // Announce the salute
    integer rank = getMilitaryRank(avatarKey);
    string rankTitle = "";
    
    if (rank == RANK_IMPERIAL) {
        rankTitle = "His Imperial Majesty";
    }
    else if (rank == RANK_GENERAL) {
        rankTitle = "General";
    }
    else if (rank == RANK_COLONEL) {
        rankTitle = "Colonel";
    }
    else if (rank == RANK_SENIOR_OFFICER) {
        rankTitle = "Captain";
    }
    else if (rank == RANK_JUNIOR_OFFICER) {
        rankTitle = "Lieutenant";
    }
    else {
        rankTitle = "Citizen";
    }
    
    llSay(0, rankTitle + " " + llKey2Name(avatarKey) + " performs a military salute with " + saberName + ".");
}

// Function to perform a ceremonial flourish
performFlourish(key avatarKey) {
    // Request permission to animate the avatar
    llRequestPermissions(avatarKey, PERMISSION_TRIGGER_ANIMATION);
    
    // When granted in run_time_permissions, we'll play ANIM_FLOURISH
    
    // Announce the flourish
    llSay(0, llKey2Name(avatarKey) + " performs a ceremonial flourish with " + saberName + ".");
}

// Function to start a duel challenge
startDuelChallenge(key challengerKey, key opponentKey, integer duelStyle) {
    // Only one duel challenge at a time
    if (duelChallengerKey != NULL_KEY) {
        llRegionSayTo(challengerKey, 0, "There is already a duel challenge pending.");
        return;
    }
    
    // Store the duel information
    duelChallengerKey = challengerKey;
    duelOpponentKey = opponentKey;
    duelAccepted = FALSE;
    duelInProgress = FALSE;
    duelType = duelStyle;
    
    // Announce the challenge
    string challengerName = llKey2Name(challengerKey);
    string opponentName = llKey2Name(opponentKey);
    string duelTypeText = (duelType == 0) ? "honor (non-lethal)" : "blood (with damage)";
    
    llSay(0, challengerName + " has challenged " + opponentName + " to a duel of " + duelTypeText + "!");
    llRegionSayTo(opponentKey, 0, "You have been challenged to a duel by " + challengerName + ". Touch the saber to accept or decline.");
    
    // Create a dialog for the opponent to accept or decline
    llDialog(opponentKey, "You have been challenged to a duel of " + duelTypeText + " by " + challengerName + ". Do you accept?", ["Accept", "Decline"], DUEL_CHANNEL);
}

// Function to process a duel response
processDuelResponse(key responderKey, string response) {
    // Ignore if not the challenged opponent
    if (responderKey != duelOpponentKey) return;
    
    if (response == "Accept") {
        // Duel accepted
        duelAccepted = TRUE;
        
        // Announce acceptance
        string challengerName = llKey2Name(duelChallengerKey);
        string opponentName = llKey2Name(duelOpponentKey);
        
        llSay(0, opponentName + " has accepted the duel challenge from " + challengerName + "!");
        
        // Start the duel
        startDuel();
    }
    else if (response == "Decline") {
        // Duel declined
        string challengerName = llKey2Name(duelChallengerKey);
        string opponentName = llKey2Name(duelOpponentKey);
        
        llSay(0, opponentName + " has declined the duel challenge from " + challengerName + ".");
        
        // Apply social consequences of declining (potential loss of honor)
        if (duelType == 1) { // Blood duel (serious)
            llRegionSayTo(duelOpponentKey, STATS_CHANNEL, "DUEL_DECLINED|HONOR:-5|SOCIAL:-3");
            llRegionSayTo(duelOpponentKey, 0, "Declining a blood duel has damaged your honor and social standing.");
        }
        
        // Reset duel variables
        duelChallengerKey = NULL_KEY;
        duelOpponentKey = NULL_KEY;
        duelAccepted = FALSE;
    }
}

// Function to start a duel
startDuel() {
    // Only start if a duel has been accepted
    if (!duelAccepted) return;
    
    duelInProgress = TRUE;
    
    // Announce the start of the duel
    string challengerName = llKey2Name(duelChallengerKey);
    string opponentName = llKey2Name(duelOpponentKey);
    string duelTypeText = (duelType == 0) ? "honor" : "blood";
    
    llSay(0, "A duel of " + duelTypeText + " begins between " + challengerName + " and " + opponentName + "!");
    llSay(0, "The duel will consist of " + (string)duelRounds + " rounds. Participants, draw your sabers!");
    
    // Request permissions for the animations
    llRequestPermissions(duelChallengerKey, PERMISSION_TRIGGER_ANIMATION);
    llRequestPermissions(duelOpponentKey, PERMISSION_TRIGGER_ANIMATION);
    
    // Create dialog menus for the participants to select their actions
    string actionPrompt = "Select your action for the first round:";
    list actionOptions = ["Slash", "Parry", "Feint"];
    
    llDialog(duelChallengerKey, actionPrompt, actionOptions, DUEL_CHANNEL + 1);
    llDialog(duelOpponentKey, actionPrompt, actionOptions, DUEL_CHANNEL + 2);
}

// Function to update the display text
updateSaberDisplay() {
    string displayText = saberName + "\n";
    
    // Display type and quality
    displayText += "Type: ";
    
    if (currentSaberType == SABER_TYPE_STANDARD) {
        displayText += "Standard Officer's";
    }
    else if (currentSaberType == SABER_TYPE_COSSACK) {
        displayText += "Cossack Shashka";
    }
    else if (currentSaberType == SABER_TYPE_CAVALRY) {
        displayText += "Cavalry";
    }
    else if (currentSaberType == SABER_TYPE_GUARD) {
        displayText += "Imperial Guard";
    }
    else if (currentSaberType == SABER_TYPE_IMPERIAL) {
        displayText += "Imperial Presentation";
    }
    
    displayText += "\n";
    
    // Show minimum rank
    displayText += "Required Rank: ";
    
    if (minRankRequired == RANK_CIVILIAN) {
        displayText += "Any";
    }
    else if (minRankRequired == RANK_ENLISTED) {
        displayText += "Enlisted";
    }
    else if (minRankRequired == RANK_JUNIOR_OFFICER) {
        displayText += "Junior Officer";
    }
    else if (minRankRequired == RANK_SENIOR_OFFICER) {
        displayText += "Senior Officer";
    }
    else if (minRankRequired == RANK_COLONEL) {
        displayText += "Colonel+";
    }
    else if (minRankRequired == RANK_GENERAL) {
        displayText += "General";
    }
    else if (minRankRequired == RANK_IMPERIAL) {
        displayText += "Imperial Family";
    }
    
    displayText += "\n";
    
    // Quality indicator
    displayText += "Quality: ";
    integer i;
    for (i = 0; i < saberQuality && i < 5; i++) {
        displayText += "★";
    }
    for (i = saberQuality; i < 5; i++) {
        displayText += "☆";
    }
    
    // Set the text with appropriate color
    vector textColor = <0.8, 0.8, 0.8>; // Silver
    
    // Adjust color based on saber type
    if (currentSaberType == SABER_TYPE_IMPERIAL) {
        textColor = <0.9, 0.8, 0.2>; // Gold for imperial
    } 
    else if (currentSaberType == SABER_TYPE_GUARD) {
        textColor = <0.7, 0.7, 0.9>; // Blue-silver for guard
    }
    
    llSetText(displayText, textColor, 1.0);
}

// Function to configure the saber
configureSaber(integer type, string name, string desc, integer quality, integer minRank, integer permissions) {
    currentSaberType = type;
    saberName = name;
    saberDescription = desc;
    saberQuality = quality;
    minRankRequired = minRank;
    permissionMask = permissions;
    
    // Update the display
    updateSaberDisplay();
}

// Process commands from other system components
processCombatCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "CHALLENGE_DUEL") {
        // Format: CHALLENGE_DUEL|opponentKey|duelType
        key opponentKey = (key)llList2String(messageParts, 1);
        integer duelStyle = (integer)llList2String(messageParts, 2);
        
        startDuelChallenge(senderKey, opponentKey, duelStyle);
    }
    else if (command == "CONFIGURE" && isTsar(senderKey)) {
        // Only the Tsar can reconfigure the saber
        // Format: CONFIGURE|type|name|desc|quality|minRank|permissions
        integer type = (integer)llList2String(messageParts, 1);
        string name = llList2String(messageParts, 2);
        string desc = llList2String(messageParts, 3);
        integer quality = (integer)llList2String(messageParts, 4);
        integer minRank = (integer)llList2String(messageParts, 5);
        integer permissions = (integer)llList2String(messageParts, 6);
        
        configureSaber(type, name, desc, quality, minRank, permissions);
    }
}

default {
    state_entry() {
        // Initialize the saber
        configureSaber(SABER_TYPE_STANDARD, "Imperial Officer's Ceremonial Saber", 
                      "Standard ceremonial saber of the Imperial Russian Army", 5, 
                      RANK_JUNIOR_OFFICER, 7);
        
        // Start listening for system events
        listenHandle = llListen(COMBAT_CHANNEL, "", NULL_KEY, "");
        
        // Listen for duel responses
        llListen(DUEL_CHANNEL, "", NULL_KEY, "");
        llListen(DUEL_CHANNEL + 1, "", NULL_KEY, "");
        llListen(DUEL_CHANNEL + 2, "", NULL_KEY, "");
        
        // Update the display
        updateSaberDisplay();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Check if this is a duel participant
        if (duelInProgress && (toucherKey == duelChallengerKey || toucherKey == duelOpponentKey)) {
            // If in a duel, touching refreshes the action dialog
            string actionPrompt = "Select your duel action:";
            list actionOptions = ["Slash", "Parry", "Feint"];
            
            if (toucherKey == duelChallengerKey) {
                llDialog(toucherKey, actionPrompt, actionOptions, DUEL_CHANNEL + 1);
            } else {
                llDialog(toucherKey, actionPrompt, actionOptions, DUEL_CHANNEL + 2);
            }
            return;
        }
        
        // Check if this avatar can use the saber
        if (!canUseSaber(toucherKey)) {
            llRegionSayTo(toucherKey, 0, "You lack the proper rank or authority to use " + saberName + ".");
            return;
        }
        
        // Regular interaction - show menu
        list options = ["Salute", "Flourish"];
        
        // Only offer dueling if combat enabled and not in a duel
        if (combatEnabled && duelChallengerKey == NULL_KEY) {
            options += ["Challenge to Duel"];
        }
        
        // The Tsar can configure the saber
        if (isTsar(toucherKey)) {
            options += ["Configure"];
        }
        
        llDialog(toucherKey, "Select an action to perform with " + saberName, options, DUEL_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == COMBAT_CHANNEL) {
            // Process combat commands
            processCombatCommand(message, id);
        }
        else if (channel == DUEL_CHANNEL) {
            // Main saber menu selections
            if (message == "Salute") {
                performSalute(id);
            }
            else if (message == "Flourish") {
                performFlourish(id);
            }
            else if (message == "Challenge to Duel") {
                // Open a dialog to select opponent and duel type
                llDialog(id, "Select duel type:", ["Honor Duel", "Blood Duel"], DUEL_CHANNEL);
            }
            else if (message == "Honor Duel" || message == "Blood Duel") {
                // User selected duel type, now ask for opponent
                integer duelStyle = (message == "Honor Duel") ? 0 : 1;
                
                // In a full implementation, would show a list of nearby avatars
                // For simplicity, we'll use text input
                llTextBox(id, "Enter the name of your opponent:", DUEL_CHANNEL);
            }
            else if (message == "Configure" && isTsar(id)) {
                // Allow the Tsar to configure the saber
                llTextBox(id, "Enter configuration string (type|name|quality|minRank|permissions):", DUEL_CHANNEL);
            }
            else if (message == "Accept" || message == "Decline") {
                // Process duel response
                processDuelResponse(id, message);
            }
        }
        else if (channel == DUEL_CHANNEL + 1 || channel == DUEL_CHANNEL + 2) {
            // This is a duel action from one of the participants
            if (duelInProgress) {
                key actionKey = id;
                string action = message;
                
                // Process the duel action (for a true implementation)
                // For demonstration, just announce the action
                llSay(0, llKey2Name(actionKey) + " performs a " + llToLower(action) + " with their saber!");
                
                // In a full implementation, this would compare actions between participants
                // and determine the outcome of each round
            }
        }
    }
    
    run_time_permissions(integer perm) {
        // Process animation permissions
        if (perm & PERMISSION_TRIGGER_ANIMATION) {
            // For demonstration, we would play the appropriate animation here
            // llStartAnimation(ANIM_SALUTE) or llStartAnimation(ANIM_FLOURISH)
        }
    }
    
    on_rez(integer start_param) {
        // Reset when rezzed
        llResetScript();
    }
}