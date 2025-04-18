// Imperial Russian Court Food Item
// Place this script in food objects to restore health when consumed

// Food parameters
string foodName = "Imperial Meal";  // Default name
integer healthValue = 10;           // Health restored when consumed
integer luxuryLevel = 1;            // 0=peasant, 1=common, 2=refined, 3=luxurious, 4=royal
integer portionCount = 1;           // Number of servings/portions
string foodType = "meal";           // Type: meal, snack, dessert, beverage, etc.
integer deletesWhenEmpty = TRUE;    // Whether the item deletes itself when all portions are used

// Appearance parameters
vector textColor = <0.8, 0.6, 0.2>; // Default text color
float textAlpha = 1.0;              // Text transparency

// Channels
integer METER_STATS_CHANNEL = -987654321;
integer FOOD_CHANNEL = -4567890; // Fixed channel instead of random

// Initialize the food item
initialize() {
    // Set object name if not already set
    if (llGetObjectName() == "Object") {
        llSetObjectName(foodName);
    } else {
        foodName = llGetObjectName();
    }
    
    // First remove any existing listeners to avoid duplicates
    llListenRemove(llListen(FOOD_CHANNEL, "", NULL_KEY, ""));
    
    // Set up listeners on both channels
    llListen(FOOD_CHANNEL, "", NULL_KEY, "");
    llListen(FOOD_CHANNEL + 1, "", NULL_KEY, "");
    
    // Debug message to confirm script is working
    llOwnerSay("Food item initialized: " + foodName);
    
    // Make sure script permissions are set
    llSetStatus(STATUS_PHANTOM, FALSE);
    
    // Set up hover text
    string healthText;
    if (healthValue >= 25) {
        healthText = "Substantial Health Restoration";
    }
    else if (healthValue >= 15) {
        healthText = "Good Health Restoration";
    }
    else if (healthValue >= 5) {
        healthText = "Modest Health Restoration";
    }
    else {
        healthText = "Minor Health Restoration";
    }
    
    string luxuryText;
    if (luxuryLevel == 4) {
        luxuryText = "Royal Quality";
    }
    else if (luxuryLevel == 3) {
        luxuryText = "Luxurious Quality";
    }
    else if (luxuryLevel == 2) {
        luxuryText = "Refined Quality";
    }
    else if (luxuryLevel == 1) {
        luxuryText = "Common Quality";
    }
    else {
        luxuryText = "Peasant Quality";
    }
    
    string portionsText = "";
    if (portionCount > 1) {
        portionsText = "\nPortions: " + (string)portionCount;
    }
    
    llSetText(foodName + "\n" + healthText + "\n" + luxuryText + portionsText, textColor, textAlpha);
    
    // Set the description for configuration
    llSetObjectDesc("Food: " + foodType + " | Health: " + (string)healthValue + 
        " | Luxury: " + (string)luxuryLevel + " | Portions: " + (string)portionCount);
}

// Show food menu to user
showFoodMenu(key userID) {
    string menuText = "\n=== " + foodName + " ===\n\n";
    menuText += "Type: " + foodType + "\n";
    string qualityText;
    if (luxuryLevel == 4) {
        qualityText = "Royal";
    }
    else if (luxuryLevel == 3) {
        qualityText = "Luxurious";
    }
    else if (luxuryLevel == 2) {
        qualityText = "Refined";
    }
    else if (luxuryLevel == 1) {
        qualityText = "Common";
    }
    else {
        qualityText = "Peasant";
    }
    menuText += "Quality: " + qualityText + "\n";
    menuText += "Health Restoration: " + (string)healthValue + " points\n";
    
    if (portionCount > 1) {
        menuText += "Portions Remaining: " + (string)portionCount + "\n";
    }
    
    menuText += "\nWhat would you like to do?";
    
    list buttons = ["Consume", "Examine", "Share", "Cancel"];
    
    llDialog(userID, menuText, buttons, FOOD_CHANNEL);
}

// Process food consumption
consumeFood(key userID) {
    // Increase user's health via their HUD
    llRegionSayTo(userID, METER_STATS_CHANNEL, "INCREASE_HEALTH|" + (string)healthValue);
    
    // Send a message to the user
    llRegionSayTo(userID, 0, "You consume the " + foodName + " and feel your health improve.");
    
    // Decrease portion count
    portionCount--;
    
    // Update hover text
    string healthText;
    if (healthValue >= 25) {
        healthText = "Substantial Health Restoration";
    }
    else if (healthValue >= 15) {
        healthText = "Good Health Restoration";
    }
    else if (healthValue >= 5) {
        healthText = "Modest Health Restoration";
    }
    else {
        healthText = "Minor Health Restoration";
    }
    
    string luxuryText;
    if (luxuryLevel == 4) {
        luxuryText = "Royal Quality";
    }
    else if (luxuryLevel == 3) {
        luxuryText = "Luxurious Quality";
    }
    else if (luxuryLevel == 2) {
        luxuryText = "Refined Quality";
    }
    else if (luxuryLevel == 1) {
        luxuryText = "Common Quality";
    }
    else {
        luxuryText = "Peasant Quality";
    }
    
    string portionsText = "";
    if (portionCount > 1) {
        portionsText = "\nPortions: " + (string)portionCount;
    }
    
    llSetText(foodName + "\n" + healthText + "\n" + luxuryText + portionsText, textColor, textAlpha);
    
    // Check if empty
    if (portionCount <= 0 && deletesWhenEmpty) {
        // Item is now empty, clean up
        llRegionSayTo(userID, 0, "You have consumed all of the " + foodName + ".");
        llDie();
    }
}

// Target selection for sharing food
showShareMenu(key userID) {
    // Scan for nearby targets
    llSensor("", "", AGENT, 10.0, PI);
    
    // Will be continued in sensor event
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
        
        // Debug message to verify touch is detected
        llOwnerSay("Food item touched by: " + llKey2Name(toucher));
        
        // Show food menu
        showFoodMenu(toucher);
        
        // Explicit call to ensure proper hover text display
        string healthText;
        if (healthValue >= 25) {
            healthText = "Substantial Health Restoration";
        }
        else if (healthValue >= 15) {
            healthText = "Good Health Restoration";
        }
        else if (healthValue >= 5) {
            healthText = "Modest Health Restoration";
        }
        else {
            healthText = "Minor Health Restoration";
        }
        
        string luxuryText;
        if (luxuryLevel == 4) {
            luxuryText = "Royal Quality";
        }
        else if (luxuryLevel == 3) {
            luxuryText = "Luxurious Quality";
        }
        else if (luxuryLevel == 2) {
            luxuryText = "Refined Quality";
        }
        else if (luxuryLevel == 1) {
            luxuryText = "Common Quality";
        }
        else {
            luxuryText = "Peasant Quality";
        }
        
        string portionsText = "";
        if (portionCount > 1) {
            portionsText = "\nPortions: " + (string)portionCount;
        }
        
        llSetText(foodName + "\n" + healthText + "\n" + luxuryText + portionsText, textColor, textAlpha);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == FOOD_CHANNEL) {
            if (message == "Cancel") {
                return;
            }
            else if (message == "Consume") {
                consumeFood(id);
            }
            else if (message == "Examine") {
                // Provide detailed description
                string examineText = "You examine the " + foodName + " closely.\n\n";
                
                if (luxuryLevel == 4) {
                    examineText += "This is a royal delicacy of the highest quality, fit for the Tsar himself. ";
                }
                else if (luxuryLevel == 3) {
                    examineText += "This is a luxurious food item of exceptional quality, suitable for nobility. ";
                }
                else if (luxuryLevel == 2) {
                    examineText += "This is a refined food of good quality, enjoyed by the upper classes. ";
                }
                else if (luxuryLevel == 1) {
                    examineText += "This is a common food of decent quality, typical of middle-class households. ";
                }
                else {
                    examineText += "This is a simple peasant food of basic quality, but filling nonetheless. ";
                }
                
                if (foodType == "meal") {
                    examineText += "It is a complete meal that would leave one satisfied. ";
                }
                else if (foodType == "snack") {
                    examineText += "It is a small snack that would tide one over between meals. ";
                }
                else if (foodType == "dessert") {
                    examineText += "It is a sweet dessert that would conclude a meal pleasantly. ";
                }
                else if (foodType == "beverage") {
                    examineText += "It is a drink that would quench one's thirst. ";
                }
                
                examineText += "Consuming it would restore approximately " + (string)healthValue + " points of health.";
                
                llRegionSayTo(id, 0, examineText);
            }
            else if (message == "Share") {
                showShareMenu(id);
            }
        }
        // Handle target selection from sensor results
        else if (channel == FOOD_CHANNEL + 1) { // Fixed share channel
            // Find target in list
            list parts = llParseString2List(message, ["|"], []);
            
            if (llGetListLength(parts) >= 2) {
                string targetName = llList2String(parts, 0);
                key targetID = (key)llList2String(parts, 1);
                
                llRegionSayTo(id, 0, "You share the " + foodName + " with " + targetName + ".");
                
                // Split health benefit
                integer sharedHealth = healthValue / 2;
                
                // Increase sharer's health (half benefit)
                llRegionSayTo(id, METER_STATS_CHANNEL, "INCREASE_HEALTH|" + (string)sharedHealth);
                llRegionSayTo(id, 0, "You gain " + (string)sharedHealth + " health points.");
                
                // Increase target's health (half benefit)
                llRegionSayTo(targetID, METER_STATS_CHANNEL, "INCREASE_HEALTH|" + (string)sharedHealth);
                llRegionSayTo(targetID, 0, llKey2Name(id) + " shares " + foodName + " with you. You gain " + 
                    (string)sharedHealth + " health points.");
                
                // Decrease portion count
                portionCount--;
                
                // Update hover text
                string healthText;
                if (healthValue >= 25) {
                    healthText = "Substantial Health Restoration";
                }
                else if (healthValue >= 15) {
                    healthText = "Good Health Restoration";
                }
                else if (healthValue >= 5) {
                    healthText = "Modest Health Restoration";
                }
                else {
                    healthText = "Minor Health Restoration";
                }
                
                string luxuryText;
                if (luxuryLevel == 4) {
                    luxuryText = "Royal Quality";
                }
                else if (luxuryLevel == 3) {
                    luxuryText = "Luxurious Quality";
                }
                else if (luxuryLevel == 2) {
                    luxuryText = "Refined Quality";
                }
                else if (luxuryLevel == 1) {
                    luxuryText = "Common Quality";
                }
                else {
                    luxuryText = "Peasant Quality";
                }
                
                string portionsText = "";
                if (portionCount > 1) {
                    portionsText = "\nPortions: " + (string)portionCount;
                }
                
                llSetText(foodName + "\n" + healthText + "\n" + luxuryText + portionsText, textColor, textAlpha);
                
                // Check if empty
                if (portionCount <= 0 && deletesWhenEmpty) {
                    // Item is now empty, clean up
                    llRegionSayTo(id, 0, "You have used all of the " + foodName + ".");
                    llDie();
                }
            }
        }
    }
    
    sensor(integer num_detected) {
        // Create a list of nearby avatars for sharing
        list buttons = [];
        list targets = [];
        
        integer i;
        for (i = 0; i < num_detected && i < 9; i++) {
            string targetName = llDetectedName(i);
            key targetID = llDetectedKey(i);
            
            // Skip the user who initiated sharing
            if (targetID != llDetectedKey(0)) {
                buttons += [targetName];
                targets += [targetName + "|" + (string)targetID];
            }
        }
        
        buttons += ["Cancel"];
        
        // Store targets in object description temporarily
        llSetObjectDesc(llDumpList2String(targets, "^"));
        
        // Show dialog to select target
        string menuText = "\n=== Share " + foodName + " ===\n\n";
        menuText += "Who would you like to share with?";
        
        // Use fixed channel + 1 for sharing dialog
        integer SHARE_CHANNEL = FOOD_CHANNEL + 1;
        llDialog(llDetectedKey(0), menuText, buttons, SHARE_CHANNEL);
    }
    
    no_sensor(integer not_used) {
        // No targets found
        llOwnerSay("There is no one nearby to share with.");
    }
    
    changed(integer change) {
        // If the object description is changed, update the food parameters
        // Only process if not temporary target storage
        if (change & CHANGED_INVENTORY) {
            if (llSubStringIndex(llGetObjectDesc(), "^") == -1) {
                string desc = llGetObjectDesc();
                
                if (llSubStringIndex(desc, "Food:") == 0) {
                    list params = llParseString2List(desc, ["|"], []);
                    
                    // Extract food type
                    list typeParts = llParseString2List(llList2String(params, 0), [":"], []);
                    if (llGetListLength(typeParts) >= 2) {
                        foodType = llStringTrim(llList2String(typeParts, 1), STRING_TRIM);
                    }
                    
                    // Extract other parameters
                    integer i;
                    for (i = 1; i < llGetListLength(params); i++) {
                        string param = llStringTrim(llList2String(params, i), STRING_TRIM);
                        list parts = llParseString2List(param, [":"], []);
                        
                        if (llGetListLength(parts) >= 2) {
                            string paramKey = llStringTrim(llList2String(parts, 0), STRING_TRIM);
                            string value = llStringTrim(llList2String(parts, 1), STRING_TRIM);
                            
                            if (paramKey == "Health") {
                                healthValue = (integer)value;
                            }
                            else if (paramKey == "Luxury") {
                                luxuryLevel = (integer)value;
                            }
                            else if (paramKey == "Portions") {
                                portionCount = (integer)value;
                            }
                        }
                    }
                    
                    // Update hover text
                    string healthText;
                    if (healthValue >= 25) {
                        healthText = "Substantial Health Restoration";
                    }
                    else if (healthValue >= 15) {
                        healthText = "Good Health Restoration";
                    }
                    else if (healthValue >= 5) {
                        healthText = "Modest Health Restoration";
                    }
                    else {
                        healthText = "Minor Health Restoration";
                    }
                    
                    string luxuryText;
                    if (luxuryLevel == 4) {
                        luxuryText = "Royal Quality";
                    }
                    else if (luxuryLevel == 3) {
                        luxuryText = "Luxurious Quality";
                    }
                    else if (luxuryLevel == 2) {
                        luxuryText = "Refined Quality";
                    }
                    else if (luxuryLevel == 1) {
                        luxuryText = "Common Quality";
                    }
                    else {
                        luxuryText = "Peasant Quality";
                    }
                    
                    string portionsText = "";
                    if (portionCount > 1) {
                        portionsText = "\nPortions: " + (string)portionCount;
                    }
                
                    llSetText(foodName + "\n" + healthText + "\n" + luxuryText + portionsText, textColor, textAlpha);
                }
            }
        }
    }
}