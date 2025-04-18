// Imperial Russian Court Roleplay System
// Script: Imperial Guard NPC Tsar Recognition
// Version: 1.0
// Description: NPC Imperial Guard that recognizes and protects imperial family members

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei
key TSARINA_UUID = NULL_KEY; // Placeholder for Tsarina Alexandra

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer GUARD_CHANNEL = -8675329; // Specific channel for guard interactions

// Guard types
integer TYPE_COSSACK = 0;       // Cossack of the Imperial Guard
integer TYPE_PREOBRAZHENSKY = 1;  // Preobrazhensky Regiment Guard
integer TYPE_SEMYONOVSKY = 2;     // Semyonovsky Regiment Guard
integer TYPE_HUSSAR = 3;          // Hussar of the Imperial Guard
integer TYPE_CUIRASSIER = 4;      // Cuirassier of the Imperial Guard

// Guard ranks
integer RANK_PRIVATE = 0;        // Private soldier
integer RANK_CORPORAL = 1;       // Corporal
integer RANK_SERGEANT = 2;       // Sergeant
integer RANK_OFFICER = 3;        // Officer

// Guard states
integer STATE_IDLE = 0;          // Standing at attention
integer STATE_ALERT = 1;         // Alert stance
integer STATE_SALUTING = 2;      // Saluting imperial family
integer STATE_REPORTING = 3;     // Reporting to superior
integer STATE_PATROLLING = 4;    // Patrolling area
integer STATE_GUARDING = 5;      // Actively guarding imperial family

// Status variables
integer currentType = TYPE_PREOBRAZHENSKY;
integer currentRank = RANK_SERGEANT;
string guardName = "Sergeant Petrov";
string guardRegiment = "Preobrazhensky Guards";
integer currentState = STATE_IDLE;
key interactingWith = NULL_KEY;     // Who the guard is currently interacting with
integer listenHandle;               // Handle for the listen event
integer scanTimer = 3;              // Seconds between proximity scans

// Animation names
string ANIM_IDLE = "guard_attention";
string ANIM_ALERT = "guard_alert";
string ANIM_SALUTE = "guard_salute";
string ANIM_REPORT = "guard_report";
string ANIM_PATROL = "guard_patrol";
string ANIM_GUARD = "guard_protect";

// Protocol variables
integer protocolLevel = 3;        // How strictly protocol is followed (1-3)
list royalProtocols = [];         // Special protocols for royalty
list securityAlerts = [];         // Current security concerns
integer securityLevel = 1;        // Current security level (1-3)

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to check if an avatar is the Tsarina
integer isTsarina(key avatarKey) {
    return (avatarKey == TSARINA_UUID);
}

// Function to determine if an avatar is imperial family
integer isImperialFamily(key avatarKey) {
    // This would be expanded in a full system to include all Romanovs
    if (isTsar(avatarKey) || isZarevich(avatarKey) || isTsarina(avatarKey)) {
        return TRUE;
    }
    return FALSE;
}

// Function to initialize guard protocols
initializeGuardProtocols() {
    // Initialize royal protocols
    royalProtocols = [
        "Stand at attention and salute when any member of the Imperial family passes.",
        "The Tsar must be addressed as 'Your Imperial Majesty' at all times.",
        "The Tsarina must be addressed as 'Your Imperial Majesty' at all times.",
        "The Zarevich must be addressed as 'Your Imperial Highness' at all times.",
        "Never obstruct the path of Imperial family members.",
        "Maintain a protective perimeter around Imperial family members at all times.",
        "Report any security concerns immediately to the ranking officer.",
        "Maintain absolute silence while on palace duty unless addressed directly.",
        "The Imperial Guard's primary duty is the protection of the Imperial family.",
        "Be prepared to give your life in defense of the Imperial family if necessary."
    ];
    
    // Initialize security alerts
    securityAlerts = [
        "There have been revolutionary pamphlets found near the West Wing.",
        "Exercise increased vigilance during public appearances following recent threats.",
        "An unknown subject attempted to approach the Imperial carriage last week.",
        "Reports of suspicious activity near the palace perimeter must be investigated thoroughly.",
        "The Finnish Regiment has reported unusual movements in the northern quarter.",
        "Several known agitators have been seen in St. Petersburg recently.",
        "The Minister of the Interior has warned of possible revolutionary activities.",
        "Extra patrols have been ordered for the garden area.",
        "All visitors must be thoroughly vetted before approaching Imperial family members.",
        "The winter bridge crossing is to be monitored for unauthorized access."
    ];
}

// Function to recognize and salute a royal person
recognizeRoyalty(key avatarKey, string avatarName, float distance) {
    // Only react if guard is in idle or patrolling state
    if (currentState != STATE_IDLE && currentState != STATE_PATROLLING) {
        return;
    }
    
    // Response depends on who it is and their proximity
    if (distance <= 15.0) { // Close enough to react
        // Set saluting state
        currentState = STATE_SALUTING;
        interactingWith = avatarKey;
        
        // Determine appropriate response and title
        string response = "";
        string title = "";
        
        if (isTsar(avatarKey)) {
            title = "His Imperial Majesty, the Tsar";
            
            if (currentRank >= RANK_SERGEANT) {
                response = "Your Imperial Majesty! " + guardRegiment + " standing ready, sir!";
            }
            else {
                response = ""; // Lower ranks stay silent, just salute
            }
            
            // Play salute animation
            // Would use llStartAnimation(ANIM_SALUTE) in a real implementation
            
            // Public announcement of salute
            llSay(0, guardName + " of the " + guardRegiment + " snaps to attention and presents a formal salute as " + title + " approaches.");
        }
        else if (isTsarina(avatarKey)) {
            title = "Her Imperial Majesty, the Tsarina";
            
            if (currentRank >= RANK_SERGEANT) {
                response = "Your Imperial Majesty! " + guardRegiment + " standing ready, ma'am!";
            }
            else {
                response = ""; // Lower ranks stay silent, just salute
            }
            
            // Play salute animation
            
            // Public announcement of salute
            llSay(0, guardName + " of the " + guardRegiment + " snaps to attention and presents a formal salute as " + title + " approaches.");
        }
        else if (isZarevich(avatarKey)) {
            title = "His Imperial Highness, the Tsarevich";
            
            if (currentRank >= RANK_SERGEANT) {
                response = "Your Imperial Highness! " + guardRegiment + " at your service, sir!";
            }
            else {
                response = ""; // Lower ranks stay silent, just salute
            }
            
            // Play salute animation
            
            // Public announcement of salute
            llSay(0, guardName + " of the " + guardRegiment + " comes to attention and salutes as " + title + " approaches.");
        }
        else if (isImperialFamily(avatarKey)) {
            title = "His/Her Imperial Highness";
            
            if (currentRank >= RANK_SERGEANT) {
                response = "Your Imperial Highness! " + guardRegiment + " at your service!";
            }
            else {
                response = ""; // Lower ranks stay silent, just salute
            }
            
            // Play salute animation
            
            // Public announcement of salute
            llSay(0, guardName + " of the " + guardRegiment + " comes to attention and salutes as a member of the Imperial family approaches.");
        }
        
        // Deliver personal response to royal if appropriate
        if (response != "") {
            llRegionSayTo(avatarKey, 0, response);
        }
        
        // Transition to guarding state if appropriate
        if (isTsar(avatarKey) || isTsarina(avatarKey) || isZarevich(avatarKey)) {
            llSetTimerEvent(3.0); // Short delay before transitioning to guard mode
        }
        else {
            llSetTimerEvent(5.0); // Return to previous state after a delay
        }
    }
    else { // Royalty is at a distance but visible
        // Maintain alert stance but don't salute yet
        if (currentState == STATE_IDLE) {
            currentState = STATE_ALERT;
            
            // Start alert animation
            // Would use llStartAnimation(ANIM_ALERT) in a real implementation
            
            // Set timer to return to idle if royalty doesn't come closer
            llSetTimerEvent(10.0);
        }
    }
}

// Function to guard royal family member
guardRoyalty(key avatarKey, string avatarName) {
    // Set guarding state
    currentState = STATE_GUARDING;
    interactingWith = avatarKey;
    
    // Announce guard duty
    string title = "";
    
    if (isTsar(avatarKey)) {
        title = "His Imperial Majesty, the Tsar";
    }
    else if (isTsarina(avatarKey)) {
        title = "Her Imperial Majesty, the Tsarina";
    }
    else if (isZarevich(avatarKey)) {
        title = "His Imperial Highness, the Tsarevich";
    }
    else {
        title = "the Imperial family";
    }
    
    llSay(0, guardName + " of the " + guardRegiment + " assumes protective stance near " + title + ".");
    
    // Start guard animation/behavior
    // Would use llStartAnimation(ANIM_GUARD) in a real implementation
    
    // Scan for threats regularly while guarding
    scanTimer = 2; // More frequent scans while on guard duty
    
    // Continue guarding until dismissed or royal leaves area
    // Will be handled by sensor events and commands
}

// Function to patrol the area
startPatrol() {
    // Set patrolling state
    currentState = STATE_PATROLLING;
    interactingWith = NULL_KEY;
    
    // Announce patrol
    llSay(0, guardName + " of the " + guardRegiment + " begins a patrol of the area.");
    
    // Start patrol animation/behavior
    // Would use llStartAnimation(ANIM_PATROL) in a real implementation
    
    // In this simulation, we'll just set a timer to patrol for a period
    llSetTimerEvent(30.0);
    
    // Return to regular scan interval
    scanTimer = 3;
}

// Function to return to idle/attention state
returnToAttention() {
    // Reset state
    currentState = STATE_IDLE;
    interactingWith = NULL_KEY;
    
    // Stop any active animations
    // Would use llStopAnimation() for each animation in a real implementation
    
    // Start idle/attention animation
    // Would use llStartAnimation(ANIM_IDLE) in a real implementation
    
    // Announce return to post if appropriate
    if (securityLevel >= 2) {
        llSay(0, guardName + " of the " + guardRegiment + " returns to post and stands at attention.");
    }
    
    // Return to regular scan interval
    scanTimer = 3;
}

// Function to report a security concern
reportSecurityConcern(key avatarKey) {
    // Only officers and sergeants make reports
    if (currentRank < RANK_SERGEANT) {
        return;
    }
    
    // Select a random security alert based on current security level
    integer count = llGetListLength(securityAlerts);
    integer index = llFloor(llFrand(count));
    string alert = llList2String(securityAlerts, index);
    
    // Deliver report
    if (isImperialFamily(avatarKey)) {
        string respectTitle = "";
        
        if (isTsar(avatarKey)) {
            respectTitle = "Your Imperial Majesty";
        }
        else if (isTsarina(avatarKey)) {
            respectTitle = "Your Imperial Majesty";
        }
        else {
            respectTitle = "Your Imperial Highness";
        }
        
        llRegionSayTo(avatarKey, 0, respectTitle + ", I must report a security matter of potential concern. " + alert);
    }
    else {
        // Report to superior officer
        llRegionSayTo(avatarKey, 0, "Sir, I must report a security concern. " + alert);
    }
    
    // Set state to reporting
    currentState = STATE_REPORTING;
    interactingWith = avatarKey;
    
    // Start reporting animation
    // Would use llStartAnimation(ANIM_REPORT) in a real implementation
    
    // Timer to return to previous state
    llSetTimerEvent(10.0);
}

// Function to challenge an approaching avatar
challengeAvatar(key avatarKey, string avatarName) {
    // Only challenge if security level is high enough and not already interacting
    if (securityLevel < 2 || currentState != STATE_IDLE && currentState != STATE_ALERT) {
        return;
    }
    
    // Don't challenge imperial family
    if (isImperialFamily(avatarKey)) {
        return;
    }
    
    // Set alert state
    currentState = STATE_ALERT;
    interactingWith = avatarKey;
    
    // Deliver challenge
    string challenge = "";
    
    if (currentType == TYPE_COSSACK) {
        challenge = "Halt! State your business in the Imperial Palace.";
    }
    else if (currentType == TYPE_PREOBRAZHENSKY || currentType == TYPE_SEMYONOVSKY) {
        challenge = "Halt! Identify yourself and your purpose here.";
    }
    else if (currentType == TYPE_HUSSAR) {
        challenge = "Halt there! This area is under Imperial Guard protection.";
    }
    else {
        challenge = "Stop and identify yourself. This is a restricted area.";
    }
    
    llRegionSayTo(avatarKey, 0, challenge);
    
    // Start alert animation
    // Would use llStartAnimation(ANIM_ALERT) in a real implementation
    
    // Timer to return to idle if no response
    llSetTimerEvent(15.0);
}

// Function to update the guard's display
updateGuardDisplay() {
    string displayText = guardName + "\n";
    displayText += guardRegiment + "\n";
    
    // Show current state
    if (currentState == STATE_IDLE) {
        displayText += "Status: At Attention";
    }
    else if (currentState == STATE_ALERT) {
        displayText += "Status: Alert";
    }
    else if (currentState == STATE_SALUTING) {
        displayText += "Status: Saluting";
    }
    else if (currentState == STATE_REPORTING) {
        displayText += "Status: Reporting";
    }
    else if (currentState == STATE_PATROLLING) {
        displayText += "Status: On Patrol";
    }
    else if (currentState == STATE_GUARDING) {
        if (isTsar(interactingWith)) {
            displayText += "Status: Guarding His Imperial Majesty";
        }
        else if (isTsarina(interactingWith)) {
            displayText += "Status: Guarding Her Imperial Majesty";
        }
        else if (isZarevich(interactingWith)) {
            displayText += "Status: Guarding His Imperial Highness";
        }
        else {
            displayText += "Status: On Guard Duty";
        }
    }
    
    // Show security level if appropriate
    if (currentRank >= RANK_SERGEANT) {
        string secLevel = "";
        
        if (securityLevel == 1) {
            secLevel = "Standard";
        }
        else if (securityLevel == 2) {
            secLevel = "Elevated";
        }
        else {
            secLevel = "High";
        }
        
        displayText += "\nSecurity Level: " + secLevel;
    }
    
    // Set the text with appropriate color based on regiment
    vector textColor = <0.9, 0.9, 0.9>; // White for default
    
    if (currentType == TYPE_PREOBRAZHENSKY) {
        textColor = <0.1, 0.5, 0.1>; // Green for Preobrazhensky
    }
    else if (currentType == TYPE_SEMYONOVSKY) {
        textColor = <0.2, 0.2, 0.8>; // Blue for Semyonovsky
    }
    else if (currentType == TYPE_COSSACK) {
        textColor = <0.7, 0.0, 0.0>; // Red for Cossack
    }
    else if (currentType == TYPE_HUSSAR) {
        textColor = <0.7, 0.5, 0.0>; // Gold for Hussar
    }
    else if (currentType == TYPE_CUIRASSIER) {
        textColor = <0.7, 0.7, 0.0>; // Yellow for Cuirassier
    }
    
    llSetText(displayText, textColor, 1.0);
}

// Function to configure the guard
configureGuard(integer type, integer rank, string name, string regiment) {
    currentType = type;
    currentRank = rank;
    guardName = name;
    guardRegiment = regiment;
    
    // Update display
    updateGuardDisplay();
}

// Process commands from other system components
processGuardCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "PATROL" && (isImperialFamily(senderKey) || currentRank < RANK_SERGEANT)) {
        // Format: PATROL
        startPatrol();
    }
    else if (command == "GUARD" && isImperialFamily(senderKey)) {
        // Format: GUARD
        guardRoyalty(senderKey, llKey2Name(senderKey));
    }
    else if (command == "RETURN" && (isImperialFamily(senderKey) || currentRank < RANK_SERGEANT)) {
        // Format: RETURN
        returnToAttention();
    }
    else if (command == "SECURITY_LEVEL" && (isImperialFamily(senderKey) || currentRank == RANK_OFFICER)) {
        // Format: SECURITY_LEVEL|level
        if (llGetListLength(messageParts) >= 2) {
            integer level = (integer)llList2String(messageParts, 1);
            
            if (level >= 1 && level <= 3) {
                securityLevel = level;
                
                // Acknowledge change
                if (isImperialFamily(senderKey)) {
                    llRegionSayTo(senderKey, 0, "Security level adjusted as commanded, " + 
                                 (isTsar(senderKey) || isTsarina(senderKey) ? "Your Imperial Majesty." : "Your Imperial Highness."));
                }
                else {
                    llRegionSayTo(senderKey, 0, "Security level adjusted as ordered, sir.");
                }
                
                // If security level is high, go to alert state
                if (securityLevel >= 2 && currentState == STATE_IDLE) {
                    currentState = STATE_ALERT;
                }
                
                // Update display
                updateGuardDisplay();
            }
        }
    }
    else if (command == "CONFIGURE" && isTsar(senderKey)) {
        // Format: CONFIGURE|type|rank|name|regiment
        if (llGetListLength(messageParts) >= 5) {
            integer type = (integer)llList2String(messageParts, 1);
            integer rank = (integer)llList2String(messageParts, 2);
            string name = llList2String(messageParts, 3);
            string regiment = llList2String(messageParts, 4);
            
            configureGuard(type, rank, name, regiment);
            llRegionSayTo(senderKey, 0, "Guard configuration updated, Your Imperial Majesty.");
        }
    }
}

// Process chat messages from nearby avatars
processChatMessage(key avatarKey, string avatarName, string message) {
    // Only process if being addressed or in interaction
    if (avatarKey != interactingWith && llSubStringIndex(llToLower(message), "guard") < 0) {
        return;
    }
    
    // Convert to lowercase for easier matching
    string lowerMessage = llToLower(message);
    
    // Check for security inquiries
    if (llSubStringIndex(lowerMessage, "security") >= 0 || 
        llSubStringIndex(lowerMessage, "threat") >= 0 || 
        llSubStringIndex(lowerMessage, "alert") >= 0) {
        
        reportSecurityConcern(avatarKey);
        return;
    }
    
    // Check for patrol commands
    if (llSubStringIndex(lowerMessage, "patrol") >= 0 || 
        llSubStringIndex(lowerMessage, "search") >= 0) {
        
        // Only take orders from imperial family or superior officers
        if (isImperialFamily(avatarKey) || 
           (currentRank < RANK_SERGEANT && llSubStringIndex(avatarName, "Officer") >= 0)) {
            startPatrol();
        }
        else {
            llRegionSayTo(avatarKey, 0, "I can only take such orders from the Imperial family or a superior officer.");
        }
        return;
    }
    
    // Check for return to post commands
    if (llSubStringIndex(lowerMessage, "return") >= 0 || 
        llSubStringIndex(lowerMessage, "attention") >= 0 ||
        llSubStringIndex(lowerMessage, "at ease") >= 0) {
        
        // Only take orders from imperial family or superior officers
        if (isImperialFamily(avatarKey) || 
           (currentRank < RANK_SERGEANT && llSubStringIndex(avatarName, "Officer") >= 0)) {
            returnToAttention();
        }
        else {
            llRegionSayTo(avatarKey, 0, "I can only take such orders from the Imperial family or a superior officer.");
        }
        return;
    }
    
    // General acknowledgment for imperial family
    if (isImperialFamily(avatarKey)) {
        string respectTitle = "";
        
        if (isTsar(avatarKey)) {
            respectTitle = "Your Imperial Majesty";
        }
        else if (isTsarina(avatarKey)) {
            respectTitle = "Your Imperial Majesty";
        }
        else {
            respectTitle = "Your Imperial Highness";
        }
        
        llRegionSayTo(avatarKey, 0, "At your service, " + respectTitle + ".");
        return;
    }
    
    // Default response for others when challenged
    if (currentState == STATE_ALERT && avatarKey == interactingWith) {
        // Reset state since they responded
        returnToAttention();
        llSay(0, guardName + " nods, returning to their post.");
    }
}

default {
    state_entry() {
        // Initialize guard protocols
        initializeGuardProtocols();
        
        // Configure guard defaults
        configureGuard(TYPE_PREOBRAZHENSKY, RANK_SERGEANT, "Sergeant Petrov", "Preobrazhensky Guards");
        
        // Start listening for system events
        listenHandle = llListen(GUARD_CHANNEL, "", NULL_KEY, "");
        
        // Also listen for chat from all sources
        listenHandle = llListen(0, "", NULL_KEY, "");
        
        // Start scanning for avatars
        llSensorRepeat("", NULL_KEY, AGENT, 20.0, PI, scanTimer);
        
        // Set initial state
        returnToAttention();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Different response based on who is touching
        if (isImperialFamily(toucherKey)) {
            // Royal interaction menu
            list options = ["Report Security Status", "Guard Me", "Patrol Area", "Return to Post", "Set Security Level"];
            llDialog(toucherKey, "How may " + guardName + " of the " + guardRegiment + " serve Your Imperial " + 
                     (isTsar(toucherKey) || isTsarina(toucherKey) ? "Majesty" : "Highness") + "?", 
                     options, GUARD_CHANNEL);
        }
        else {
            // Regular person touching - may be suspicious
            if (securityLevel >= 2) {
                challengeAvatar(toucherKey, toucherName);
            }
            else {
                // Still offer limited interaction
                list options = ["Ask About Security", "Speak with Guard"];
                llDialog(toucherKey, "State your business with the Imperial Guard.", options, GUARD_CHANNEL);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Check if this is on the guard special channel
        if (channel == GUARD_CHANNEL) {
            // Process menu selections
            if (message == "Report Security Status" || message == "Ask About Security") {
                reportSecurityConcern(id);
            }
            else if (message == "Guard Me" && isImperialFamily(id)) {
                guardRoyalty(id, name);
            }
            else if (message == "Patrol Area") {
                if (isImperialFamily(id) || 
                   (currentRank < RANK_SERGEANT && llSubStringIndex(name, "Officer") >= 0)) {
                    startPatrol();
                }
                else {
                    llRegionSayTo(id, 0, "I can only take such orders from the Imperial family or a superior officer.");
                }
            }
            else if (message == "Return to Post") {
                if (isImperialFamily(id) || 
                   (currentRank < RANK_SERGEANT && llSubStringIndex(name, "Officer") >= 0)) {
                    returnToAttention();
                }
                else {
                    llRegionSayTo(id, 0, "I can only take such orders from the Imperial family or a superior officer.");
                }
            }
            else if (message == "Set Security Level" && (isImperialFamily(id) || currentRank == RANK_OFFICER)) {
                // Offer security level options
                list levelOptions = ["Standard Security", "Elevated Security", "High Security"];
                llDialog(id, "Select the desired security level:", levelOptions, GUARD_CHANNEL + 1);
            }
            else if (message == "Speak with Guard") {
                llRegionSayTo(id, 0, "The Imperial Guard is on duty and not permitted to engage in casual conversation. If you have official business, please speak with the palace staff.");
            }
            else {
                // Check if it's a system command
                processGuardCommand(message, id);
            }
        }
        else if (channel == GUARD_CHANNEL + 1) {
            // Process security level selection
            integer level = 1; // Default
            
            if (message == "Elevated Security") {
                level = 2;
            }
            else if (message == "High Security") {
                level = 3;
            }
            
            // Apply security level change
            processGuardCommand("SECURITY_LEVEL|" + (string)level, id);
        }
        // Process chat on public channel
        else if (channel == 0) {
            processChatMessage(id, name, message);
        }
    }
    
    sensor(integer num_detected) {
        // First priority - check for royal family members
        integer i;
        for (i = 0; i < num_detected; i++) {
            key detectedKey = llDetectedKey(i);
            string detectedName = llDetectedName(i);
            float detectedDist = llDetectedDist(i);
            
            if (isImperialFamily(detectedKey)) {
                // If already guarding this royal, continue guarding
                if (currentState == STATE_GUARDING && interactingWith == detectedKey) {
                    // Continue guard duty
                    // Reset timer to ensure we stay in guard mode
                    llSetTimerEvent(30.0);
                    return;
                }
                
                // If not already guarding, recognize & potentially salute
                recognizeRoyalty(detectedKey, detectedName, detectedDist);
                
                // Once we've recognized one royal person, stop processing
                return;
            }
        }
        
        // If high security and not already in alert state, check for non-royal avatars
        if (securityLevel >= 2 && currentState == STATE_IDLE) {
            for (i = 0; i < num_detected; i++) {
                key detectedKey = llDetectedKey(i);
                string detectedName = llDetectedName(i);
                float detectedDist = llDetectedDist(i);
                
                if (detectedDist <= 10.0) {
                    challengeAvatar(detectedKey, detectedName);
                    return;
                }
            }
        }
    }
    
    timer() {
        // Behavior depends on current state
        if (currentState == STATE_SALUTING) {
            // After saluting, may transition to guarding (for high-ranking royals)
            if (isTsar(interactingWith) || isTsarina(interactingWith) || isZarevich(interactingWith)) {
                guardRoyalty(interactingWith, llKey2Name(interactingWith));
            }
            else {
                returnToAttention();
            }
        }
        else if (currentState == STATE_GUARDING) {
            // Continue guarding - would check if royal is still present
            // For simulation, we'll just stay in guard mode until explicitly changed
            // or until the next sensor scan doesn't detect the royal
        }
        else if (currentState == STATE_ALERT && interactingWith == NULL_KEY) {
            // Return from alert to idle if not interacting with anyone
            returnToAttention();
        }
        else if (currentState == STATE_PATROLLING) {
            // End patrol
            returnToAttention();
        }
        else if (currentState == STATE_REPORTING) {
            // End report
            returnToAttention();
        }
        else {
            // Default - return to attention
            returnToAttention();
        }
        
        // Stop timer
        llSetTimerEvent(0.0);
        
        // Update display
        updateGuardDisplay();
    }
}