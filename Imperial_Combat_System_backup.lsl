// Imperial Russian Court Combat System
// Place this script in weapons, dueling pistols, etc.

// Combat parameters
string weaponName = "Dueling Pistol";   // Default name
integer baseDamage = 20;                // Base damage
float accuracy = 0.7;                   // Accuracy (0.0 to 1.0)
integer cooldownSeconds = 30;           // Cooldown between uses
integer lethalMode = FALSE;             // Whether weapon can be lethal
integer requireConsent = TRUE;          // Whether target must agree to combat
string damageType = "physical";         // Type: physical, poison, etc.
integer honorChange = -5;               // Honor/reputation change on use

// Range parameters
float maxRange = 10.0;                  // Maximum range in meters
integer allowMelee = FALSE;             // Whether weapon can be used in melee
float meleeRange = 2.0;                 // Melee range in meters

// Social parameters
integer restrictedClass = -1;           // Class restriction (-1 = any)
integer restrictedRank = -1;            // Rank restriction (-1 = any)
integer militaryOnly = FALSE;           // Whether only military can use

integer COMBAT_CHANNEL;
integer CONFIRM_CHANNEL; 
integer TARGET_CHANNEL;

// Stats channel
integer METER_STATS_CHANNEL = -987654321;

// Combat state tracking
list cooldowns = [];                    // Format: [userID, timestamp, ...]
list pendingChallenges = [];            // Format: [challenger, target, timestamp, ...]
integer challengeTimeout = 60;          // Seconds before challenge expires

// Global action tracking
string currentAction = "";              // Current action being performed

// Initialize the weapon
initialize() {
    // Set object name if not already set
    if (llGetObjectName() == "Object") {
        llSetObjectName(weaponName);
    } else {
        weaponName = llGetObjectName();
    }
    
    // Set up random channels for dialog menus
    COMBAT_CHANNEL = -6000000 - (integer)llFrand(999999);
    CONFIRM_CHANNEL = COMBAT_CHANNEL - 1;
    TARGET_CHANNEL = COMBAT_CHANNEL - 2;
    
    // Set up listeners
    llListen(COMBAT_CHANNEL, "", NULL_KEY, "");
    llListen(CONFIRM_CHANNEL, "", NULL_KEY, "");
    llListen(TARGET_CHANNEL, "", NULL_KEY, "");
    
    // Set up hover text
    string damageText = "Damage: " + (string)baseDamage;
    string accuracyText = "Accuracy: " + (string)((integer)(accuracy * 100)) + "%";
    string lethalText = "";
    if (lethalMode) {
        lethalText = "\nLethal";
    }
    
    llSetText(weaponName + "\n" + damageText + "\n" + accuracyText + lethalText, <0.8, 0.2, 0.2>, 1.0);
    
    // Set up object description for configuration
    string desc = "Weapon: " + damageType + " | Damage: " + (string)baseDamage + 
        " | Accuracy: " + (string)((integer)(accuracy * 100)) + 
        " | Range: " + (string)((integer)maxRange) + 
        " | Cooldown: " + (string)cooldownSeconds;
    
    if (lethalMode) desc += " | Lethal: YES";
    if (requireConsent) desc += " | Consent: YES";
    if (militaryOnly) desc += " | Military: YES";
    if (restrictedClass >= 0) desc += " | Class: " + (string)restrictedClass;
    if (restrictedRank >= 0) desc += " | Rank: " + (string)restrictedRank;
    
    llSetObjectDesc(desc);
}

// Show weapon menu to user
showWeaponMenu(key userID) {
    // Check if on cooldown
    integer index = llListFindList(cooldowns, [userID]);
    
    if (index != -1) {
        integer lastUseTime = llList2Integer(cooldowns, index + 1);
        integer currentTime = llGetUnixTime();
        integer timeRemaining = (lastUseTime + cooldownSeconds) - currentTime;
        
        if (timeRemaining > 0) {
            // Still on cooldown
            llRegionSayTo(userID, 0, "This weapon is still cooling down. Please wait " + 
                (string)timeRemaining + " seconds before using it again.");
            return;
        } else {
            // Remove cooldown
            cooldowns = llDeleteSubList(cooldowns, index, index + 1);
        }
    }
    
    string menuText = "\n=== " + weaponName + " ===\n\n";
    menuText += "Damage: " + (string)baseDamage + "\n";
    menuText += "Accuracy: " + (string)((integer)(accuracy * 100)) + "%\n";
    menuText += "Range: " + (string)((integer)maxRange) + "m\n";
    
    if (lethalMode) {
        menuText += "WARNING: This weapon can be lethal!\n";
    }
    
    menuText += "\nWhat would you like to do?";
    
    list buttons = ["Attack", "Challenge to Duel", "Examine Weapon", "Cancel"];
    
    llDialog(userID, menuText, buttons, COMBAT_CHANNEL);
}

// Show target selection menu
showTargetMenu(key userID, string action) {
    // Scan for potential targets
    llSensor("", "", AGENT, maxRange, PI);
    
    // Store the action for when sensor returns
    currentAction = action;
}

// Process attack request
processAttack(key attackerID, key targetID) {
    // Check if attacker has restrictions
    if (militaryOnly) {
        // Would check player class here with HUD query
        llRegionSayTo(attackerID, 0, "This weapon can only be used by military personnel.");
        return;
    }
    
    if (restrictedClass >= 0 || restrictedRank >= 0) {
        // Would check player class/rank here with HUD query
        llRegionSayTo(attackerID, 0, "You lack the proper standing to use this weapon.");
        return;
    }
    
    // Calculate hit success based on accuracy
    integer hitSuccess = (llFrand(1.0) <= accuracy);
    
    // Process immediate attack result
    if (hitSuccess) {
        // Calculate damage
        integer damage = baseDamage;
        
        // Apply some randomness to damage
        damage = damage - 5 + llFloor(llFrand(11)); // +/- 5 damage
        
        // Send damage command to target's HUD
        llRegionSayTo(targetID, METER_STATS_CHANNEL, "TAKE_DAMAGE|" + (string)damage + "|" + 
            llKey2Name(attackerID) + "|" + damageType);
        
        // Notify attacker
        llRegionSayTo(attackerID, 0, "You successfully hit " + llKey2Name(targetID) + 
            " with your " + weaponName + " for " + (string)damage + " damage!");
        
        // Notify target
        llRegionSayTo(targetID, 0, "You have been hit by " + llKey2Name(attackerID) + 
            "'s " + weaponName + " for " + (string)damage + " damage!");
        
        // Apply honor/reputation change to attacker if not in a duel
        if (llListFindList(pendingChallenges, [attackerID, targetID]) == -1 &&
            llListFindList(pendingChallenges, [targetID, attackerID]) == -1) {
            
            llRegionSayTo(attackerID, METER_STATS_CHANNEL, "DECREASE_REPUTATION|" + (string)llAbs(honorChange));
            llRegionSayTo(attackerID, 0, "Your honor has been affected by this unprovoked attack.");
        }
    } else {
        // Attack missed
        llRegionSayTo(attackerID, 0, "Your attack with the " + weaponName + " missed " + 
            llKey2Name(targetID) + "!");
        
        // Notify target
        llRegionSayTo(targetID, 0, llKey2Name(attackerID) + " tried to attack you with a " + 
            weaponName + " but missed!");
    }
    
    // Apply cooldown
    integer index = llListFindList(cooldowns, [attackerID]);
    
    if (index != -1) {
        // Update cooldown
        cooldowns = llListReplaceList(cooldowns, [attackerID, llGetUnixTime()], index, index + 1);
    } else {
        // Add new cooldown
        cooldowns += [attackerID, llGetUnixTime()];
    }
}

// Process duel challenge
processDuelChallenge(key challengerID, key targetID) {
    // Check if already challenged
    integer index = llListFindList(pendingChallenges, [challengerID, targetID]);
    
    if (index != -1) {
        llRegionSayTo(challengerID, 0, "You have already challenged " + llKey2Name(targetID) + 
            " to a duel. Please wait for their response.");
        return;
    }
    
    // Add challenge to pending list
    pendingChallenges += [challengerID, targetID, llGetUnixTime()];
    
    // Send challenge to target
    llRegionSayTo(targetID, 0, llKey2Name(challengerID) + " has challenged you to a duel with " + 
        weaponName + "! Do you accept?");
    
    string confirmText = "\n=== DUEL CHALLENGE ===\n\n";
    confirmText += llKey2Name(challengerID) + " has challenged you to a duel using " + weaponName + ".\n\n";
    
    if (lethalMode) {
        confirmText += "WARNING: This is a lethal duel and may result in death!\n\n";
    }
    
    confirmText += "Do you accept this challenge?";
    
    list buttons = ["Accept", "Decline", "Negotiate"];
    
    llDialog(targetID, confirmText, buttons, CONFIRM_CHANNEL);
    
    // Set timer to clean up expired challenges
    llSetTimerEvent(30.0);
}

// Process duel acceptance
processDuelAcceptance(key targetID, key challengerID) {
    // Check if challenge exists and is valid
    integer index = llListFindList(pendingChallenges, [challengerID, targetID]);
    
    if (index == -1) {
        llRegionSayTo(targetID, 0, "There is no active duel challenge from " + 
            llKey2Name(challengerID) + ".");
        return;
    }
    
    // Check challenge timeout
    integer challengeTime = llList2Integer(pendingChallenges, index + 2);
    integer currentTime = llGetUnixTime();
    
    if (currentTime - challengeTime > challengeTimeout) {
        // Challenge expired
        pendingChallenges = llDeleteSubList(pendingChallenges, index, index + 2);
        
        llRegionSayTo(targetID, 0, "The duel challenge from " + llKey2Name(challengerID) + 
            " has expired.");
        return;
    }
    
    // Remove challenge from pending list
    pendingChallenges = llDeleteSubList(pendingChallenges, index, index + 2);
    
    // Notify both parties
    string duelText = "The duel between " + llKey2Name(challengerID) + " and " + 
        llKey2Name(targetID) + " has been accepted!";
    
    llRegionSayTo(challengerID, 0, duelText);
    llRegionSayTo(targetID, 0, duelText);
    llSay(0, duelText);
    
    // Process immediate attacks - this is simplified, real duels would have more ceremony
    // First, challenger attacks
    processAttack(challengerID, targetID);
    
    // Then, target attacks back
    llSleep(1.5); // Brief delay between attacks
    processAttack(targetID, challengerID);
}

// Process duel decline
processDuelDecline(key targetID, key challengerID) {
    // Check if challenge exists
    integer index = llListFindList(pendingChallenges, [challengerID, targetID]);
    
    if (index == -1) {
        llRegionSayTo(targetID, 0, "There is no active duel challenge from " + 
            llKey2Name(challengerID) + ".");
        return;
    }
    
    // Remove challenge from pending list
    pendingChallenges = llDeleteSubList(pendingChallenges, index, index + 2);
    
    // Notify both parties
    llRegionSayTo(challengerID, 0, llKey2Name(targetID) + " has declined your duel challenge.");
    llRegionSayTo(targetID, 0, "You have declined the duel challenge from " + llKey2Name(challengerID) + ".");
    
    // Apply honor penalty to target for declining
    llRegionSayTo(targetID, METER_STATS_CHANNEL, "DECREASE_REPUTATION|2");
    llRegionSayTo(targetID, 0, "Your honor has been slightly affected by declining a formal duel.");
}

default {
    state_entry() {
        initialize();
    }
    
    on_rez(integer start_param) {
        initialize();
    }
    
    touch_start(integer num_detected) {
        key toucher = llDetectedKey(0);
        
        // Show weapon menu
        showWeaponMenu(toucher);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == COMBAT_CHANNEL) {
            if (message == "Cancel") {
                return;
            }
            else if (message == "Attack") {
                // Show target selection menu
                showTargetMenu(id, "attack");
            }
            else if (message == "Challenge to Duel") {
                // Show target selection menu for duel
                showTargetMenu(id, "duel");
            }
            else if (message == "Examine Weapon") {
                // Provide detailed description
                string examineText = "You examine the " + weaponName + " closely.\n\n";
                
                examineText += "This is a " + damageType + " weapon that deals " + 
                    (string)baseDamage + " base damage with " + 
                    (string)((integer)(accuracy * 100)) + "% accuracy.\n";
                
                examineText += "It has an effective range of " + (string)((integer)maxRange) + " meters";
                
                if (allowMelee) {
                    examineText += " and can be used in melee combat within " + 
                        (string)((integer)meleeRange) + " meters";
                }
                
                examineText += ".\n";
                
                if (lethalMode) {
                    examineText += "WARNING: This weapon is capable of inflicting lethal damage!\n";
                }
                
                if (requireConsent) {
                    examineText += "This weapon can only be used in consensual combat through formal challenges.\n";
                }
                
                if (militaryOnly) {
                    examineText += "This weapon can only be used by military personnel.\n";
                }
                
                if (restrictedClass >= 0) {
                    examineText += "This weapon is restricted to those of Class " + 
                        (string)restrictedClass + " or higher.\n";
                }
                
                if (restrictedRank >= 0) {
                    examineText += "This weapon is restricted to those of Rank " + 
                        (string)restrictedRank + " or higher.\n";
                }
                
                examineText += "Using this weapon outside of formal duels will affect your honor.";
                
                llRegionSayTo(id, 0, examineText);
            }
        }
        // Handle target selection for attacks and duels
        else if (channel == TARGET_CHANNEL) {
            list parts = llParseString2List(message, ["|"], []);
            
            if (llGetListLength(parts) >= 2) {
                string targetName = llList2String(parts, 0);
                key targetID = (key)llList2String(parts, 1);
                string action = currentAction;
                string lethalIndicator = "";
                if (lethalMode) {
                    lethalIndicator = "\nLethal";
                }
                
                llSetText(weaponName + "\nDamage: " + (string)baseDamage + "\nAccuracy: " + 
                    (string)((integer)(accuracy * 100)) + "%" + lethalIndicator, <0.8, 0.2, 0.2>, 1.0);
                
                if (action == "attack") {
                    if (requireConsent) {
                        // Need consent for attacks, so issue a duel challenge instead
                        llRegionSayTo(id, 0, "This weapon requires formal challenges. Converting to duel request.");
                        processDuelChallenge(id, targetID);
                    } else {
                        // Direct attack allowed
                        processAttack(id, targetID);
                    }
                }
                else if (action == "duel") {
                    // Issue duel challenge
                    processDuelChallenge(id, targetID);
                }
            }
        }
        // Handle duel acceptance/declination
        else if (channel == CONFIRM_CHANNEL) {
            if (message == "Accept") {
                // Find the challenger for this target
                integer i;
                for (i = 0; i < llGetListLength(pendingChallenges); i += 3) {
                    if (llList2Key(pendingChallenges, i + 1) == id) {
                        key challengerID = llList2Key(pendingChallenges, i);
                        processDuelAcceptance(id, challengerID);
                        return;
                    }
                }
            }
            else if (message == "Decline") {
                // Find the challenger for this target
                integer i;
                for (i = 0; i < llGetListLength(pendingChallenges); i += 3) {
                    if (llList2Key(pendingChallenges, i + 1) == id) {
                        key challengerID = llList2Key(pendingChallenges, i);
                        processDuelDecline(id, challengerID);
                        return;
                    }
                }
            }
            else if (message == "Negotiate") {
                // Find the challenger for this target
                integer i;
                for (i = 0; i < llGetListLength(pendingChallenges); i += 3) {
                    if (llList2Key(pendingChallenges, i + 1) == id) {
                        key challengerID = llList2Key(pendingChallenges, i);
                        
                        // Notify both parties
                        string negotiateText = llKey2Name(id) + " wishes to negotiate the terms of the duel.";
                        llRegionSayTo(challengerID, 0, negotiateText);
                        llRegionSayTo(id, 0, "You have requested to negotiate the duel terms. Please use local chat to discuss terms.");
                        return;
                    }
                }
            }
        }
    }
    
    sensor(integer num_detected) {
        // Get the action type from our global variable
        string action = currentAction;
        
        // Create a list of nearby targets
        list targets = [];
        list buttons = [];
        
        // Get the owner key - we should exclude the owner from targets
        key owner = llGetOwner();
        
        integer i;
        for (i = 0; i < num_detected; i++) {
            string targetName = llDetectedName(i);
            key targetID = llDetectedKey(i);
            
            // Skip the owner who initiated the action
            if (targetID != owner) {
                targets += [targetName + "|" + (string)targetID];
                buttons += [targetName];
            }
        }
        
        buttons += ["Cancel"];
        
        // Store targets in object description temporarily
        llSetObjectDesc(llDumpList2String(targets, "^"));
        
        // Show target selection dialog
        string menuText = "\n=== Select Target ===\n\n";
        
        if (action == "attack") {
            menuText += "Select a target to attack:";
        } else if (action == "duel") {
            menuText += "Select someone to challenge to a duel:";
        }
        
        llDialog(llGetOwner(), menuText, buttons, TARGET_CHANNEL);
    }
    
    no_sensor(integer not_used) {
        // No targets found
        string action = currentAction;
        string lethalIndicator = "";
        if (lethalMode) {
            lethalIndicator = "\nLethal";
        }
        
        llSetText(weaponName + "\nDamage: " + (string)baseDamage + "\nAccuracy: " + 
            (string)((integer)(accuracy * 100)) + "%" + lethalIndicator, <0.8, 0.2, 0.2>, 1.0);
        
        // Cannot use llDetectedKey() in no_sensor since there's nothing detected
        // Instead, we'll use the public chat channel
        llSay(0, "No valid targets found within range.");
    }
    
    timer() {
        // Clean up expired challenges
        integer currentTime = llGetUnixTime();
        integer i = 0;
        
        while (i < llGetListLength(pendingChallenges)) {
            integer challengeTime = llList2Integer(pendingChallenges, i + 2);
            
            if (currentTime - challengeTime > challengeTimeout) {
                // Challenge expired, notify parties
                key challengerID = llList2Key(pendingChallenges, i);
                key targetID = llList2Key(pendingChallenges, i + 1);
                
                llRegionSayTo(challengerID, 0, "Your duel challenge to " + llKey2Name(targetID) + 
                    " has expired.");
                
                // Remove expired challenge
                pendingChallenges = llDeleteSubList(pendingChallenges, i, i + 2);
                // Don't increment i since we removed elements
            } else {
                i += 3; // Move to next challenge
            }
        }
        
        // Stop timer if no more challenges
        if (llGetListLength(pendingChallenges) == 0) {
            llSetTimerEvent(0.0);
        }
    }
    
    changed(integer change) {
        // If object description is changed, update parameters
        if (change & CHANGED_INVENTORY) {
            // Only update if not storing temporary target data
            if (llSubStringIndex(llGetObjectDesc(), "^") == -1) {
                string desc = llGetObjectDesc();
                
                if (llSubStringIndex(desc, "Weapon:") == 0) {
                    list params = llParseString2List(desc, ["|"], []);
                    
                    // Extract weapon type
                    list typeParts = llParseString2List(llList2String(params, 0), [":"], []);
                    if (llGetListLength(typeParts) >= 2) {
                        damageType = llStringTrim(llList2String(typeParts, 1), STRING_TRIM);
                    }
                    
                    // Extract other parameters
                    integer i;
                    for (i = 1; i < llGetListLength(params); i++) {
                        string param = llStringTrim(llList2String(params, i), STRING_TRIM);
                        list parts = llParseString2List(param, [":"], []);
                        
                        if (llGetListLength(parts) >= 2) {
                            string paramKey = llStringTrim(llList2String(parts, 0), STRING_TRIM);
                            string value = llStringTrim(llList2String(parts, 1), STRING_TRIM);
                            
                            if (paramKey == "Damage") {
                                baseDamage = (integer)value;
                            }
                            else if (paramKey == "Accuracy") {
                                accuracy = (integer)value / 100.0;
                            }
                            else if (paramKey == "Range") {
                                maxRange = (float)value;
                            }
                            else if (paramKey == "Cooldown") {
                                cooldownSeconds = (integer)value;
                            }
                            else if (paramKey == "Lethal") {
                                lethalMode = (value == "YES");
                            }
                            else if (paramKey == "Consent") {
                                requireConsent = (value == "YES");
                            }
                            else if (paramKey == "Military") {
                                militaryOnly = (value == "YES");
                            }
                            else if (paramKey == "Class") {
                                restrictedClass = (integer)value;
                            }
                            else if (paramKey == "Rank") {
                                restrictedRank = (integer)value;
                            }
                        }
                    }
                    
                    // Update hover text
                    string damageText = "Damage: " + (string)baseDamage;
                    string accuracyText = "Accuracy: " + (string)((integer)(accuracy * 100)) + "%";
                    string lethalText = "";
                    if (lethalMode) {
                        lethalText = "\nLethal";
                    }
                    
                    llSetText(weaponName + "\n" + damageText + "\n" + accuracyText + lethalText, <0.8, 0.2, 0.2>, 1.0);
                }
            }
        }
    }
}