// Imperial Russian Court Roleplay System
// Script: Imperial Banquet System
// Version: 1.0
// Description: Comprehensive food system with social and health effects for formal banquets

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer BANQUET_CHANNEL = -8675319; // Specific channel for banquet and food events

// Food and banquet constants
integer FOOD_TYPE_APPETIZER = 0;    // Zakuski (appetizers)
integer FOOD_TYPE_SOUP = 1;         // Soups (borscht, ukha, etc.)
integer FOOD_TYPE_FISH = 2;         // Fish dishes
integer FOOD_TYPE_MEAT = 3;         // Meat dishes
integer FOOD_TYPE_POULTRY = 4;      // Poultry dishes
integer FOOD_TYPE_DESSERT = 5;      // Desserts
integer FOOD_TYPE_DRINK = 6;        // Beverages (tea, wine, vodka)

// Quality levels
integer QUALITY_COMMON = 0;         // Common household food
integer QUALITY_FINE = 1;           // Fine dining quality
integer QUALITY_LUXURY = 2;         // Luxury banquet quality
integer QUALITY_IMPERIAL = 3;       // Imperial court quality

// Status variables
integer currentFoodType = FOOD_TYPE_APPETIZER;
integer currentQuality = QUALITY_FINE;
string itemName = "Imperial Banquet Platter";
string itemDescription = "A selection of fine Russian cuisine";
integer isBanquetActive = FALSE;    // Is a formal banquet in progress
integer banquetStartTime = 0;       // When the banquet started
integer banquetHostKey = NULL_KEY;  // Who is hosting the banquet
integer lastServeTime = 0;          // Time of last food serving
integer serveCooldown = 300;        // Cooldown between servings (5 minutes)
integer listenHandle;               // Handle for the listen event

// Banquet participation
list banquetAttendees = [];         // List of avatars attending
list attendeeServings = [];         // How many servings each has had
integer maxServingsPerPerson = 3;   // Maximum servings per banquet
integer formalBanquet = FALSE;      // Is this a formal imperial banquet

// Food details
list foodNames = [];                // Names of available food items
list foodTypes = [];                // Corresponding food types
list foodQualities = [];            // Corresponding food qualities
list foodEffects = [];              // Health/status effects of each food

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to check if an avatar is attending the banquet
integer isAttending(key avatarKey) {
    return (llListFindList(banquetAttendees, [avatarKey]) >= 0);
}

// Function to add an avatar to the banquet
addAttendee(key avatarKey) {
    // Only add if not already attending
    if (!isAttending(avatarKey)) {
        banquetAttendees += [avatarKey];
        attendeeServings += [0]; // Initialize servings count
    }
}

// Function to get the index of an attendee
integer getAttendeeIndex(key avatarKey) {
    return llListFindList(banquetAttendees, [avatarKey]);
}

// Function to get number of servings for an attendee
integer getServingCount(key avatarKey) {
    integer index = getAttendeeIndex(avatarKey);
    if (index >= 0) {
        return llList2Integer(attendeeServings, index);
    }
    return 0;
}

// Function to increment serving count for an attendee
incrementServingCount(key avatarKey) {
    integer index = getAttendeeIndex(avatarKey);
    if (index >= 0) {
        integer currentCount = llList2Integer(attendeeServings, index);
        attendeeServings = llListReplaceList(attendeeServings, [currentCount + 1], index, index);
    }
}

// Function to initialize available foods
initializeFoods() {
    // Clear existing lists
    foodNames = [];
    foodTypes = [];
    foodQualities = [];
    foodEffects = [];
    
    // Add appetizers
    foodNames += ["Caviar on Blini"];
    foodTypes += [FOOD_TYPE_APPETIZER];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["SOCIAL:3|TASTE:5"];
    
    foodNames += ["Smoked Salmon Canapés"];
    foodTypes += [FOOD_TYPE_APPETIZER];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["SOCIAL:2|TASTE:4"];
    
    foodNames += ["Pickled Vegetables"];
    foodTypes += [FOOD_TYPE_APPETIZER];
    foodQualities += [QUALITY_COMMON];
    foodEffects += ["HEALTH:1|TASTE:2"];
    
    // Add soups
    foodNames += ["Borscht with Sour Cream"];
    foodTypes += [FOOD_TYPE_SOUP];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HEALTH:3|WARMTH:4|TASTE:3"];
    
    foodNames += ["Ukha (Fish Soup)"];
    foodTypes += [FOOD_TYPE_SOUP];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HEALTH:4|WARMTH:3|TASTE:3"];
    
    foodNames += ["Imperial Consommé"];
    foodTypes += [FOOD_TYPE_SOUP];
    foodQualities += [QUALITY_IMPERIAL];
    foodEffects += ["HEALTH:3|SOCIAL:3|TASTE:5"];
    
    // Add fish dishes
    foodNames += ["Poached Sturgeon"];
    foodTypes += [FOOD_TYPE_FISH];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["HEALTH:4|SOCIAL:4|TASTE:4"];
    
    foodNames += ["Smoked Trout"];
    foodTypes += [FOOD_TYPE_FISH];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HEALTH:3|TASTE:3"];
    
    // Add meat dishes
    foodNames += ["Beef Stroganoff"];
    foodTypes += [FOOD_TYPE_MEAT];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HEALTH:4|STRENGTH:3|TASTE:4"];
    
    foodNames += ["Roast Venison"];
    foodTypes += [FOOD_TYPE_MEAT];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["HEALTH:4|STRENGTH:4|SOCIAL:3|TASTE:4"];
    
    foodNames += ["Imperial Veal"];
    foodTypes += [FOOD_TYPE_MEAT];
    foodQualities += [QUALITY_IMPERIAL];
    foodEffects += ["HEALTH:5|SOCIAL:5|TASTE:5"];
    
    // Add poultry dishes
    foodNames += ["Roast Duck with Apples"];
    foodTypes += [FOOD_TYPE_POULTRY];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["HEALTH:4|SOCIAL:3|TASTE:5"];
    
    foodNames += ["Chicken Kiev"];
    foodTypes += [FOOD_TYPE_POULTRY];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HEALTH:3|TASTE:4"];
    
    // Add desserts
    foodNames += ["Pavlova"];
    foodTypes += [FOOD_TYPE_DESSERT];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["HAPPINESS:5|SOCIAL:3|TASTE:5"];
    
    foodNames += ["Charlotte Russe"];
    foodTypes += [FOOD_TYPE_DESSERT];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HAPPINESS:4|TASTE:4"];
    
    foodNames += ["Imperial Fabergé Dessert"];
    foodTypes += [FOOD_TYPE_DESSERT];
    foodQualities += [QUALITY_IMPERIAL];
    foodEffects += ["HAPPINESS:5|SOCIAL:5|PRESTIGE:3|TASTE:5"];
    
    // Add drinks
    foodNames += ["Imperial Tea Blend"];
    foodTypes += [FOOD_TYPE_DRINK];
    foodQualities += [QUALITY_IMPERIAL];
    foodEffects += ["HEALTH:2|WARMTH:4|SOCIAL:4"];
    
    foodNames += ["Fine Champagne"];
    foodTypes += [FOOD_TYPE_DRINK];
    foodQualities += [QUALITY_LUXURY];
    foodEffects += ["HAPPINESS:4|SOCIAL:4|INTOXICATION:2"];
    
    foodNames += ["Crimean Wine"];
    foodTypes += [FOOD_TYPE_DRINK];
    foodQualities += [QUALITY_FINE];
    foodEffects += ["HAPPINESS:3|SOCIAL:2|INTOXICATION:1"];
    
    foodNames += ["Imperial Vodka"];
    foodTypes += [FOOD_TYPE_DRINK];
    foodQualities += [QUALITY_IMPERIAL];
    foodEffects += ["WARMTH:5|SOCIAL:3|INTOXICATION:4"];
}

// Function to get food items of a specific type and minimum quality
list getFoodsByTypeAndQuality(integer type, integer minQuality) {
    list results = [];
    integer i;
    integer count = llGetListLength(foodNames);
    
    for (i = 0; i < count; i++) {
        integer foodType = llList2Integer(foodTypes, i);
        integer quality = llList2Integer(foodQualities, i);
        
        if (foodType == type && quality >= minQuality) {
            results += [i]; // Store the index
        }
    }
    
    return results;
}

// Function to start a banquet
startBanquet(key hostKey, string hostName, integer formal) {
    // Only one banquet at a time
    if (isBanquetActive) {
        llRegionSayTo(hostKey, 0, "A banquet is already in progress.");
        return;
    }
    
    // Check if host has appropriate status for formal banquet
    if (formal && !isTsar(hostKey)) {
        llRegionSayTo(hostKey, 0, "Only the Tsar can host a formal Imperial banquet.");
        return;
    }
    
    // Initialize banquet
    isBanquetActive = TRUE;
    banquetStartTime = llGetUnixTime();
    banquetHostKey = hostKey;
    formalBanquet = formal;
    
    // Clear attendee lists
    banquetAttendees = [];
    attendeeServings = [];
    
    // Add host as first attendee
    addAttendee(hostKey);
    
    // Announce the banquet
    string banquetType = formalBanquet ? "formal Imperial" : "noble";
    
    string announcement = "";
    if (isTsar(hostKey)) {
        announcement = "His Imperial Majesty " + hostName + " has commenced a " + 
                      banquetType + " banquet.";
    }
    else {
        announcement = hostName + " has commenced a " + banquetType + " banquet.";
    }
    
    llSay(0, announcement);
    llSay(0, "Touch the banquet table to join and be served from the selection of " + 
          "Russian cuisine.");
    
    // Set up the banquet display
    updateBanquetDisplay();
    
    // Start timer for banquet duration
    llSetTimerEvent(300.0); // Check every 5 minutes
}

// Function to end a banquet
endBanquet() {
    if (isBanquetActive) {
        isBanquetActive = FALSE;
        
        // Count attendees
        integer attendeeCount = llGetListLength(banquetAttendees);
        
        // Announce the end of the banquet
        string banquetType = formalBanquet ? "Imperial" : "noble";
        string hostName = "Unknown";
        
        if (banquetHostKey != NULL_KEY) {
            hostName = llKey2Name(banquetHostKey);
        }
        
        llSay(0, "The " + banquetType + " banquet hosted by " + hostName + 
              " has concluded with " + (string)attendeeCount + " attendees.");
        
        // Reset banquet variables
        banquetHostKey = NULL_KEY;
        banquetAttendees = [];
        attendeeServings = [];
        formalBanquet = FALSE;
        
        // Update display
        updateBanquetDisplay();
        
        // Stop timer
        llSetTimerEvent(0.0);
    }
}

// Function to serve food to an attendee
serveFood(key avatarKey, string avatarName) {
    // Check if banquet is active
    if (!isBanquetActive) {
        llRegionSayTo(avatarKey, 0, "There is no active banquet. Touch to begin one.");
        return;
    }
    
    // Add to attendees if not already attending
    if (!isAttending(avatarKey)) {
        addAttendee(avatarKey);
        
        // Announce new attendee
        string announcement = "";
        if (isTsar(avatarKey)) {
            announcement = "His Imperial Majesty " + avatarName + " has joined the banquet.";
        }
        else if (isZarevich(avatarKey)) {
            announcement = "His Imperial Highness " + avatarName + " has joined the banquet.";
        }
        else {
            announcement = avatarName + " has joined the banquet.";
        }
        
        llSay(0, announcement);
    }
    
    // Check if they've reached their serving limit
    integer servings = getServingCount(avatarKey);
    if (servings >= maxServingsPerPerson) {
        llRegionSayTo(avatarKey, 0, "You have already been served the maximum number of courses for this banquet.");
        return;
    }
    
    // Check cooldown
    integer currentTime = llGetUnixTime();
    if (lastServeTime > 0 && currentTime - lastServeTime < serveCooldown) {
        integer remainingTime = serveCooldown - (currentTime - lastServeTime);
        integer remainingMinutes = remainingTime / 60;
        
        llRegionSayTo(avatarKey, 0, "The next course is being prepared. Please wait " + 
                     (string)remainingMinutes + " minutes.");
        return;
    }
    
    // Determine food quality based on banquet type and guest
    integer minQuality = QUALITY_FINE;
    
    if (formalBanquet) {
        minQuality = QUALITY_LUXURY;
    }
    
    // The Tsar and Zarevich always get Imperial quality
    if (isTsar(avatarKey) || isZarevich(avatarKey)) {
        minQuality = QUALITY_IMPERIAL;
    }
    
    // Determine food type based on current serving
    integer courseType = servings;
    
    // Simplified course progression
    if (courseType >= FOOD_TYPE_DESSERT) {
        courseType = FOOD_TYPE_DESSERT;
    }
    
    // Get available foods of appropriate type and quality
    list availableFoods = getFoodsByTypeAndQuality(courseType, minQuality);
    
    // If nothing available, try lower quality
    if (llGetListLength(availableFoods) == 0 && minQuality > QUALITY_COMMON) {
        availableFoods = getFoodsByTypeAndQuality(courseType, minQuality - 1);
    }
    
    // If still nothing, offer a different course
    if (llGetListLength(availableFoods) == 0) {
        integer altCourse = (courseType + 1) % (FOOD_TYPE_DRINK + 1);
        availableFoods = getFoodsByTypeAndQuality(altCourse, minQuality);
        courseType = altCourse;
    }
    
    // If we found something, serve it
    if (llGetListLength(availableFoods) > 0) {
        // Choose a random food from available options
        integer foodIndex = llList2Integer(availableFoods, llFloor(llFrand(llGetListLength(availableFoods))));
        string foodName = llList2String(foodNames, foodIndex);
        string effectString = llList2String(foodEffects, foodIndex);
        
        // Update serving count
        incrementServingCount(avatarKey);
        lastServeTime = currentTime;
        
        // Construct effect message
        string effectMessage = "You are served " + foodName + ".\n";
        
        // Parse effects
        list effects = llParseString2List(effectString, ["|"], []);
        integer i;
        for (i = 0; i < llGetListLength(effects); i++) {
            list effectParts = llParseString2List(llList2String(effects, i), [":"], []);
            if (llGetListLength(effectParts) == 2) {
                string effectName = llList2String(effectParts, 0);
                integer effectValue = (integer)llList2String(effectParts, 1);
                
                // Add to message
                effectMessage += effectName + ": +" + (string)effectValue + "\n";
            }
        }
        
        // Tell the attendee about the effects
        llRegionSayTo(avatarKey, 0, effectMessage);
        
        // Send stats update to attendee's HUD
        llRegionSayTo(avatarKey, STATS_CHANNEL, "BANQUET_FOOD|" + effectString);
        
        // Announce the serving
        string courseTypeName = "course";
        if (courseType == FOOD_TYPE_APPETIZER) courseTypeName = "appetizer";
        else if (courseType == FOOD_TYPE_SOUP) courseTypeName = "soup";
        else if (courseType == FOOD_TYPE_FISH) courseTypeName = "fish course";
        else if (courseType == FOOD_TYPE_MEAT) courseTypeName = "meat course";
        else if (courseType == FOOD_TYPE_POULTRY) courseTypeName = "poultry course";
        else if (courseType == FOOD_TYPE_DESSERT) courseTypeName = "dessert";
        else if (courseType == FOOD_TYPE_DRINK) courseTypeName = "beverage";
        
        string announcement = "";
        if (isTsar(avatarKey)) {
            announcement = "His Imperial Majesty " + avatarName + " is served " + 
                          foodName + " for the " + courseTypeName + ".";
        }
        else if (isZarevich(avatarKey)) {
            announcement = "His Imperial Highness " + avatarName + " is served " + 
                          foodName + " for the " + courseTypeName + ".";
        }
        else {
            announcement = avatarName + " is served " + foodName + " for the " + courseTypeName + ".";
        }
        
        llSay(0, announcement);
    }
    else {
        // No suitable food found
        llRegionSayTo(avatarKey, 0, "The kitchen regrets that they cannot prepare an appropriate dish at this time.");
    }
}

// Function to update the banquet display
updateBanquetDisplay() {
    string displayText = itemName + "\n";
    
    if (isBanquetActive) {
        // Display banquet status
        string banquetType = formalBanquet ? "Imperial" : "Noble";
        string hostName = "Unknown";
        
        if (banquetHostKey != NULL_KEY) {
            hostName = llKey2Name(banquetHostKey);
        }
        
        displayText += banquetType + " Banquet in Progress\n";
        displayText += "Host: " + hostName + "\n";
        displayText += "Attendees: " + (string)llGetListLength(banquetAttendees) + "\n";
        
        // Calculate banquet duration
        integer currentTime = llGetUnixTime();
        integer elapsedTime = currentTime - banquetStartTime;
        integer elapsedMinutes = elapsedTime / 60;
        
        displayText += "Duration: " + (string)elapsedMinutes + " minutes\n";
        
        // Show next course time
        if (lastServeTime > 0) {
            integer timeSinceServe = currentTime - lastServeTime;
            integer timeToNextCourse = serveCooldown - timeSinceServe;
            
            if (timeToNextCourse > 0) {
                integer nextCourseMinutes = timeToNextCourse / 60;
                displayText += "Next course in: " + (string)nextCourseMinutes + " min";
            }
            else {
                displayText += "Next course: Available";
            }
        }
        else {
            displayText += "First course: Available";
        }
    }
    else {
        // Display inactive status
        displayText += "No Active Banquet\n";
        displayText += "Touch to Host a Banquet";
    }
    
    // Set the text with appropriate color
    vector textColor = <0.8, 0.7, 0.3>; // Gold for banquet
    
    llSetText(displayText, textColor, 1.0);
}

// Process commands from other system components
processBanquetCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "END_BANQUET") {
        if (senderKey == banquetHostKey || isTsar(senderKey)) {
            endBanquet();
        }
        else {
            llRegionSayTo(senderKey, 0, "Only the banquet host or the Tsar can end the banquet.");
        }
    }
    else if (command == "ADD_FOOD" && isTsar(senderKey)) {
        // Format: ADD_FOOD|name|type|quality|effects
        string name = llList2String(messageParts, 1);
        integer type = (integer)llList2String(messageParts, 2);
        integer quality = (integer)llList2String(messageParts, 3);
        string effects = llList2String(messageParts, 4);
        
        // Add to food lists
        foodNames += [name];
        foodTypes += [type];
        foodQualities += [quality];
        foodEffects += [effects];
        
        llRegionSayTo(senderKey, 0, "Added " + name + " to the banquet menu.");
    }
}

default {
    state_entry() {
        // Initialize food items
        initializeFoods();
        
        // Start listening for system events
        listenHandle = llListen(BANQUET_CHANNEL, "", NULL_KEY, "");
        
        // Update the display
        updateBanquetDisplay();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // If banquet is active, try to serve food
        if (isBanquetActive) {
            serveFood(toucherKey, toucherName);
            return;
        }
        
        // No active banquet, show host options
        list options = ["Host Noble Banquet"];
        
        // Only the Tsar can host a formal Imperial banquet
        if (isTsar(toucherKey)) {
            options += ["Host Imperial Banquet"];
        }
        
        llDialog(toucherKey, "What type of banquet would you like to host?", options, BANQUET_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == BANQUET_CHANNEL) {
            // Process banquet commands
            if (message == "Host Noble Banquet") {
                startBanquet(id, name, FALSE);
            }
            else if (message == "Host Imperial Banquet" && isTsar(id)) {
                startBanquet(id, name, TRUE);
            }
            else {
                processBanquetCommand(message, id);
            }
        }
    }
    
    timer() {
        if (isBanquetActive) {
            // Check banquet duration - auto-end after 3 hours
            integer currentTime = llGetUnixTime();
            integer elapsedTime = currentTime - banquetStartTime;
            
            if (elapsedTime > 10800) { // 3 hours
                llSay(0, "The banquet has concluded after three hours of feasting.");
                endBanquet();
            } else {
                // Just update the display
                updateBanquetDisplay();
            }
        } else {
            // No need for timer if no banquet
            llSetTimerEvent(0.0);
        }
    }
    
    on_rez(integer start_param) {
        // Reset when rezzed
        llResetScript();
    }
}