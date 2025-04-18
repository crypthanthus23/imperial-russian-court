// Imperial Russian Court Ruble Giver
// Place this script in an object to dispense rubles through various means

// Ruble parameters
string giverName = "Imperial Treasury";  // Default name
integer baseAmount = 100;                // Base amount to give
integer minAmount = 50;                  // Minimum amount for random
integer maxAmount = 150;                 // Maximum amount for random
string giveMethod = "fixed";             // Method: fixed, random, scaled
integer ownerOnlyAccess = FALSE;         // Whether only the owner can use
integer singleUse = FALSE;               // Whether it can only be used once
integer cooldownSeconds = 0;             // Cooldown between uses (0 = no cooldown)

// Social parameters
integer requireVerification = FALSE;     // Whether user needs to verify noble status
integer minimumRank = -1;                // Minimum rank required (-1 = any)
integer minimumClass = -1;               // Minimum class required (-1 = any)
integer trackRecipients = TRUE;          // Whether to track who received rubles

// Appearance parameters
vector textColor = <0.8, 0.6, 0.2>;      // Gold color for text
float textAlpha = 1.0;                   // Text opacity
integer particleEffect = TRUE;           // Whether to use particle effects

// Channels
integer METER_STATS_CHANNEL = -987654321;
integer GIVER_CHANNEL;

// Lists for tracking
list recipients = [];         // List of users who have received rubles
list cooldowns = [];          // List of cooldown times for users

// Initialize the giver
initialize() {
    // Set object name if not already set
    if (llGetObjectName() == "Object") {
        llSetObjectName(giverName);
    } else {
        giverName = llGetObjectName();
    }
    
    // Set up random channel for dialog menus
    GIVER_CHANNEL = -5000000 - (integer)llFrand(999999);
    
    // Set up listener
    llListen(GIVER_CHANNEL, "", NULL_KEY, "");
    
    // Set up the hover text
    string methodText;
    if (giveMethod == "fixed") {
        methodText = (string)baseAmount + " Rubles";
    } else if (giveMethod == "random") {
        methodText = (string)minAmount + "-" + (string)maxAmount + " Rubles";
    } else { // scaled
        methodText = "Scaled Rubles";
    }
    
    string restrictedText = "";
    if (ownerOnlyAccess) {
        restrictedText = "\nOwner Only";
    } else if (requireVerification || minimumRank >= 0 || minimumClass >= 0) {
        restrictedText = "\nRestricted Access";
    }
    
    llSetText(giverName + "\n" + methodText + restrictedText, textColor, textAlpha);
    
    // Set up the description for configuration
    string desc = "Giver: " + giveMethod + " | Base: " + (string)baseAmount;
    if (giveMethod == "random") {
        desc += " | Min: " + (string)minAmount + " | Max: " + (string)maxAmount;
    }
    if (cooldownSeconds > 0) {
        desc += " | Cooldown: " + (string)cooldownSeconds;
    }
    if (ownerOnlyAccess) {
        desc += " | OwnerOnly: YES";
    }
    if (requireVerification) {
        desc += " | Verify: YES";
    }
    if (minimumRank >= 0) {
        desc += " | MinRank: " + (string)minimumRank;
    }
    if (minimumClass >= 0) {
        desc += " | MinClass: " + (string)minimumClass;
    }
    
    llSetObjectDesc(desc);
}

// Show giver menu to user
showGiverMenu(key userID) {
    // First check restrictions
    if (ownerOnlyAccess && userID != llGetOwner()) {
        llRegionSayTo(userID, 0, "This " + giverName + " is only accessible to its owner.");
        return;
    }
    
    // Check cooldowns
    integer index = llListFindList(cooldowns, [userID]);
    
    if (index != -1 && cooldownSeconds > 0) {
        integer lastUseTime = llList2Integer(cooldowns, index + 1);
        integer currentTime = llGetUnixTime();
        integer timeRemaining = (lastUseTime + cooldownSeconds) - currentTime;
        
        if (timeRemaining > 0) {
            // Still on cooldown
            llRegionSayTo(userID, 0, "You must wait " + (string)timeRemaining + 
                " more seconds before using this " + giverName + " again.");
            return;
        } else {
            // Update cooldown time
            cooldowns = llListReplaceList(cooldowns, [userID, currentTime], index, index + 1);
        }
    } else if (cooldownSeconds > 0) {
        // Add new cooldown entry
        cooldowns += [userID, llGetUnixTime()];
    }
    
    // Check if previously received and single use
    if (singleUse && llListFindList(recipients, [userID]) != -1) {
        llRegionSayTo(userID, 0, "You have already received rubles from this " + giverName + ", and it is single-use only.");
        return;
    }
    
    string menuText = "\n=== " + giverName + " ===\n\n";
    
    if (giveMethod == "fixed") {
        menuText += "This treasury contains " + (string)baseAmount + " rubles.\n";
    } else if (giveMethod == "random") {
        menuText += "This treasury contains between " + (string)minAmount + 
            " and " + (string)maxAmount + " rubles.\n";
    } else { // scaled
        menuText += "This treasury contains rubles scaled to your rank and status.\n";
    }
    
    menuText += "\nWould you like to receive these funds?";
    
    list buttons = ["Accept Rubles"];
    
    // Add verification if required
    if (requireVerification || minimumRank >= 0 || minimumClass >= 0) {
        buttons += ["Verify Status"];
    }
    
    buttons += ["Information", "Cancel"];
    
    llDialog(userID, menuText, buttons, GIVER_CHANNEL);
}

// Process giving rubles
giveRubles(key userID) {
    integer amountToGive;
    
    // Determine amount based on method
    if (giveMethod == "fixed") {
        amountToGive = baseAmount;
    } else if (giveMethod == "random") {
        amountToGive = minAmount + llFloor(llFrand(maxAmount - minAmount + 1));
    } else { // scaled - would normally check player stats
        amountToGive = baseAmount; // Default until we get player info
        
        // Request status check from player's HUD
        llRegionSayTo(userID, METER_STATS_CHANNEL, "CHECK_STATUS|SCALE_RUBLES|" + (string)llGetKey());
        return; // Will continue when we get status response
    }
    
    // Add user to recipients list if tracking
    if (trackRecipients && llListFindList(recipients, [userID]) == -1) {
        recipients += [userID];
    }
    
    // Send rubles to user's HUD
    llRegionSayTo(userID, METER_STATS_CHANNEL, "ADD_RUBLES|" + (string)amountToGive);
    
    // Send a message to the user
    llRegionSayTo(userID, 0, "You have received " + (string)amountToGive + " rubles from the " + giverName + ".");
    
    // Visual effects if enabled
    if (particleEffect) {
        // Gold particle effect
        llParticleSystem([
            PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_FOLLOW_VELOCITY_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR, <0.9, 0.8, 0.1>,
            PSYS_PART_END_COLOR, <0.9, 0.9, 0.5>,
            PSYS_PART_START_SCALE, <0.05, 0.05, 0>,
            PSYS_PART_END_SCALE, <0.02, 0.02, 0>,
            PSYS_PART_START_ALPHA, 1.0,
            PSYS_PART_END_ALPHA, 0.3,
            PSYS_SRC_BURST_RATE, 0.1,
            PSYS_SRC_BURST_PART_COUNT, 30,
            PSYS_SRC_BURST_RADIUS, 0.0,
            PSYS_SRC_BURST_SPEED_MIN, 0.5,
            PSYS_SRC_BURST_SPEED_MAX, 1.5,
            PSYS_SRC_MAX_AGE, 0.0,
            PSYS_PART_MAX_AGE, 5.0,
            PSYS_SRC_ACCEL, <0.0, 0.0, -0.3>
        ]);
        
        // Turn off particles after a brief time
        llSetTimerEvent(2.0);
    }
    
    // Check if single use and delete if needed
    if (singleUse) {
        llRegionSayTo(userID, 0, "This " + giverName + " has served its purpose and is now empty.");
        llDie();
    }
}

// Process giving scaled rubles based on status
giveScaledRubles(key userID, integer playerClass, integer playerRank, integer imperialFavor) {
    integer amountToGive = baseAmount;
    
    // Scale amount based on class (0=Imperial, 1=Noble, etc.)
    if (playerClass == 0) { // Imperial
        amountToGive *= 3;
    } else if (playerClass == 1) { // Noble
        amountToGive *= 2;
    }
    
    // Scale amount based on rank (lower number = higher rank)
    if (playerRank <= 1) {
        amountToGive += 100;
    } else if (playerRank <= 3) {
        amountToGive += 50;
    }
    
    // Scale based on imperial favor
    amountToGive += imperialFavor;
    
    // Add user to recipients list if tracking
    if (trackRecipients && llListFindList(recipients, [userID]) == -1) {
        recipients += [userID];
    }
    
    // Send rubles to user's HUD
    llRegionSayTo(userID, METER_STATS_CHANNEL, "ADD_RUBLES|" + (string)amountToGive);
    
    // Send a message to the user
    llRegionSayTo(userID, 0, "Based on your station, you have received " + 
        (string)amountToGive + " rubles from the " + giverName + ".");
    
    // Visual effects if enabled
    if (particleEffect) {
        // Gold particle effect
        llParticleSystem([
            PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_FOLLOW_VELOCITY_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR, <0.9, 0.8, 0.1>,
            PSYS_PART_END_COLOR, <0.9, 0.9, 0.5>,
            PSYS_PART_START_SCALE, <0.05, 0.05, 0>,
            PSYS_PART_END_SCALE, <0.02, 0.02, 0>,
            PSYS_PART_START_ALPHA, 1.0,
            PSYS_PART_END_ALPHA, 0.3,
            PSYS_SRC_BURST_RATE, 0.1,
            PSYS_SRC_BURST_PART_COUNT, 30,
            PSYS_SRC_BURST_RADIUS, 0.0,
            PSYS_SRC_BURST_SPEED_MIN, 0.5,
            PSYS_SRC_BURST_SPEED_MAX, 1.5,
            PSYS_SRC_MAX_AGE, 0.0,
            PSYS_PART_MAX_AGE, 5.0,
            PSYS_SRC_ACCEL, <0.0, 0.0, -0.3>
        ]);
        
        // Turn off particles after a brief time
        llSetTimerEvent(2.0);
    }
    
    // Check if single use and delete if needed
    if (singleUse) {
        llRegionSayTo(userID, 0, "This " + giverName + " has served its purpose and is now empty.");
        llDie();
    }
}

// Verify user status
verifyStatus(key userID) {
    // Request status check from player's HUD
    llRegionSayTo(userID, METER_STATS_CHANNEL, "CHECK_STATUS|VERIFY|" + (string)llGetKey());
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
        
        // Show giver menu
        showGiverMenu(toucher);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == GIVER_CHANNEL) {
            if (message == "Cancel") {
                return;
            }
            else if (message == "Accept Rubles") {
                // Check if verification is needed
                if (requireVerification || minimumRank >= 0 || minimumClass >= 0) {
                    verifyStatus(id);
                } else {
                    giveRubles(id);
                }
            }
            else if (message == "Verify Status") {
                verifyStatus(id);
            }
            else if (message == "Information") {
                // Provide detailed info
                string infoText = "The " + giverName + " provides financial support to the court.\n\n";
                
                if (giveMethod == "fixed") {
                    infoText += "It dispenses a fixed amount of " + (string)baseAmount + " rubles per use.\n";
                } else if (giveMethod == "random") {
                    infoText += "It dispenses a random amount between " + (string)minAmount + 
                        " and " + (string)maxAmount + " rubles.\n";
                } else { // scaled
                    infoText += "It dispenses an amount of rubles based on your rank, class, and imperial favor.\n";
                }
                
                if (cooldownSeconds > 0) {
                    infoText += "There is a cooldown of " + (string)cooldownSeconds + " seconds between uses.\n";
                }
                
                if (singleUse) {
                    infoText += "Note that this is a single-use treasury and will be depleted after use.\n";
                }
                
                if (requireVerification) {
                    infoText += "You must verify your status before receiving funds.\n";
                }
                
                if (minimumRank >= 0) {
                    infoText += "A minimum rank of " + (string)minimumRank + " is required to receive funds.\n";
                }
                
                if (minimumClass >= 0) {
                    infoText += "A minimum class of " + (string)minimumClass + " is required to receive funds.\n";
                }
                
                llRegionSayTo(id, 0, infoText);
            }
        }
    }
    
    timer() {
        // Turn off particles
        llParticleSystem([]);
        llSetTimerEvent(0.0);
    }
    
    dataserver(key query_id, string data) {
        // Process status check responses
        list parts = llParseString2List(data, ["|"], []);
        
        if (llGetListLength(parts) >= 2) {
            string command = llList2String(parts, 0);
            key userID = (key)llList2String(parts, 1);
            
            if (command == "STATUS_VERIFIED") {
                // User passed verification
                integer playerClass = (integer)llList2String(parts, 2);
                integer playerRank = (integer)llList2String(parts, 3);
                
                // Check minimum requirements
                if (minimumClass >= 0 && playerClass > minimumClass) {
                    llRegionSayTo(userID, 0, "Your social class is insufficient to receive funds from this " + giverName + ".");
                    return;
                }
                
                if (minimumRank >= 0 && playerRank > minimumRank) {
                    llRegionSayTo(userID, 0, "Your rank is insufficient to receive funds from this " + giverName + ".");
                    return;
                }
                
                // User passed checks, give rubles
                giveRubles(userID);
            }
            else if (command == "STATUS_SCALED") {
                // For scaled giving
                integer playerClass = (integer)llList2String(parts, 2);
                integer playerRank = (integer)llList2String(parts, 3);
                integer imperialFavor = (integer)llList2String(parts, 4);
                
                // Give scaled rubles
                giveScaledRubles(userID, playerClass, playerRank, imperialFavor);
            }
            else if (command == "STATUS_VERIFICATION_FAILED") {
                llRegionSayTo(userID, 0, "Verification failed. You must be registered with a valid HUD to receive funds.");
            }
        }
    }
    
    changed(integer change) {
        // If object description is changed, update parameters
        if (change & CHANGED_INVENTORY) {
            string desc = llGetObjectDesc();
            
            if (llSubStringIndex(desc, "Giver:") == 0) {
                list params = llParseString2List(desc, ["|"], []);
                
                integer i;
                for (i = 0; i < llGetListLength(params); i++) {
                    string param = llStringTrim(llList2String(params, i), STRING_TRIM);
                    list parts = llParseString2List(param, [":"], []);
                    
                    if (llGetListLength(parts) >= 2) {
                        string paramKey = llStringTrim(llList2String(parts, 0), STRING_TRIM);
                        string value = llStringTrim(llList2String(parts, 1), STRING_TRIM);
                        
                        if (paramKey == "Giver") {
                            giveMethod = value;
                        }
                        else if (paramKey == "Base") {
                            baseAmount = (integer)value;
                        }
                        else if (paramKey == "Min") {
                            minAmount = (integer)value;
                        }
                        else if (paramKey == "Max") {
                            maxAmount = (integer)value;
                        }
                        else if (paramKey == "Cooldown") {
                            cooldownSeconds = (integer)value;
                        }
                        else if (paramKey == "OwnerOnly") {
                            ownerOnlyAccess = (value == "YES");
                        }
                        else if (paramKey == "Verify") {
                            requireVerification = (value == "YES");
                        }
                        else if (paramKey == "MinRank") {
                            minimumRank = (integer)value;
                        }
                        else if (paramKey == "MinClass") {
                            minimumClass = (integer)value;
                        }
                        else if (paramKey == "SingleUse") {
                            singleUse = (value == "YES");
                        }
                    }
                }
                
                // Update the hover text
                string methodText;
                if (giveMethod == "fixed") {
                    methodText = (string)baseAmount + " Rubles";
                } else if (giveMethod == "random") {
                    methodText = (string)minAmount + "-" + (string)maxAmount + " Rubles";
                } else { // scaled
                    methodText = "Scaled Rubles";
                }
                
                string restrictedText = "";
                if (ownerOnlyAccess) {
                    restrictedText = "\nOwner Only";
                } else if (requireVerification || minimumRank >= 0 || minimumClass >= 0) {
                    restrictedText = "\nRestricted Access";
                }
                
                llSetText(giverName + "\n" + methodText + restrictedText, textColor, textAlpha);
            }
        }
    }
}