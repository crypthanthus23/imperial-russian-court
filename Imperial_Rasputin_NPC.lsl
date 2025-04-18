// Imperial Russian Court Roleplay System
// Script: Imperial Rasputin NPC
// Version: 1.0
// Description: Interactive Rasputin NPC with healing and prophecy abilities

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei
key TSARINA_UUID = NULL_KEY; // Placeholder for Tsarina Alexandra

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer RASPUTIN_CHANNEL = -8675327; // Specific channel for Rasputin interactions

// Rasputin states
integer STATE_IDLE = 0;       // Default idle state
integer STATE_PRAYING = 1;    // Praying/meditating
integer STATE_HEALING = 2;    // Performing healing
integer STATE_PROPHESYING = 3; // Delivering prophecy
integer STATE_TALKING = 4;    // Conversing with someone

// Status variables
integer currentState = STATE_IDLE;
key interactingWith = NULL_KEY;     // Who is currently interacting with Rasputin
integer lastHealingTime = 0;        // When Rasputin last performed healing
integer healingCooldown = 3600;     // Cooldown between healings (1 hour)
integer lastProphecyTime = 0;       // When Rasputin last gave a prophecy
integer prophecyCooldown = 1800;    // Cooldown between prophecies (30 minutes)
integer listenHandle;               // Handle for the listen event

// Animation names
string ANIM_IDLE = "rasputin_idle";
string ANIM_PRAYING = "rasputin_pray";
string ANIM_HEALING = "rasputin_heal";
string ANIM_PROPHESY = "rasputin_prophesy";
string ANIM_TALK = "rasputin_talk";

// Prophecy variables
list prophecyTexts = [];             // List of possible prophecies
list pastProphecies = [];            // Recently given prophecies
list prophecyRecipients = [];        // Who received each prophecy
integer mysticalModeActive = FALSE;  // Special mystical appearance mode

// Healing variables
integer canHealZarevich = TRUE;      // Special ability to heal Zarevich
integer healingStrength = 3;         // Power of healing (1-5)
list specialPatients = [];           // List of special patients (Zarevich)
list healingTimes = [];              // When each patient was last healed

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

// Function to initialize prophecies
initializeProphecies() {
    prophecyTexts = [
        "I see dark clouds gathering over the Winter Palace. The Romanovs must be vigilant.",
        "The Zarevich's health will improve if he spends time near holy relics.",
        "Beware of conspirators among the nobility. The court hides vipers in its midst.",
        "A foreign power will soon make a diplomatic gesture. It hides ulterior motives.",
        "The military parades will bring good fortune to the Empire this season.",
        "I see a vision of the Tsarina surrounded by white light. Her faith protects the family.",
        "Blood and iron will test Russia. The Tsar must prepare for difficult decisions.",
        "The church bells ring in my vision. A religious ceremony will bring healing.",
        "A traitor wears the uniform of the Imperial Guard. Be watchful.",
        "The Zarevich must not travel east before the next full moon.",
        "Fire and water, the ancient elements, will bring both danger and salvation.",
        "The Tsar's decision in the coming council will echo for generations.",
        "Three ravens circle in my vision. Three challenges approach the throne.",
        "A gift from a foreign dignitary contains both opportunity and danger.",
        "I see a figure moving through shadows in the palace gardens. Not all is as it seems.",
        "The imperial children will find joy in an unexpected celebration.",
        "Trust not the man who speaks most eloquently of loyalty.",
        "The next naval review will coincide with an important revelation.",
        "When snow falls on the feast of St. Nicholas, a miracle will occur.",
        "The eyes of God are upon the Romanovs. Faith will be your shield in dark times."
    ];
}

// Function to get a random prophecy
string getRandomProphecy(key avatarKey) {
    // Special prophecies for imperial family
    if (isTsar(avatarKey)) {
        return "Your Imperial Majesty, the burden of the crown weighs heavily, but Russia's destiny is tied to the Romanovs. I see challenges from within your court that will test your resolve. Trust those who speak plainly, not those who flatter.";
    }
    else if (isTsarina(avatarKey)) {
        return "Your Imperial Majesty, your devotion to family shines like a beacon. A ritual of prayer at midnight for nine consecutive days will bring comfort to the Zarevich. The future is veiled, but faith will guide you through coming darkness.";
    }
    else if (isZarevich(avatarKey)) {
        return "Young Alexei, your suffering has purpose. God has chosen you for a special fate. When you hold the ancient icon of St. Nicholas during your next episode, relief will come more quickly. I see strength growing within you.";
    }
    else if (isImperialFamily(avatarKey)) {
        return "The blood of the Romanovs carries both blessing and burden. I see your role in the dynasty's future growing in importance. A seemingly small decision you make in the coming week will have unforeseen consequences.";
    }
    
    // General prophecies for others
    // Avoid repeating recent prophecies
    list availableProphecies = [];
    integer i;
    integer count = llGetListLength(prophecyTexts);
    
    // Build list of prophecies not recently given
    for (i = 0; i < count; i++) {
        string prophecy = llList2String(prophecyTexts, i);
        if (llListFindList(pastProphecies, [prophecy]) < 0) {
            availableProphecies += [prophecy];
        }
    }
    
    // If all prophecies have been used recently, reset
    if (llGetListLength(availableProphecies) == 0) {
        availableProphecies = prophecyTexts;
    }
    
    // Select random prophecy
    integer index = llFloor(llFrand(llGetListLength(availableProphecies)));
    string chosenProphecy = llList2String(availableProphecies, index);
    
    // Record it as recently used
    pastProphecies += [chosenProphecy];
    if (llGetListLength(pastProphecies) > 5) {
        pastProphecies = llDeleteSubList(pastProphecies, 0, 0);
    }
    
    return chosenProphecy;
}

// Function to deliver a prophecy
deliverProphecy(key avatarKey, string avatarName) {
    // Check cooldown
    integer currentTime = llGetUnixTime();
    if (lastProphecyTime > 0 && currentTime - lastProphecyTime < prophecyCooldown) {
        integer remainingTime = prophecyCooldown - (currentTime - lastProphecyTime);
        integer remainingMinutes = remainingTime / 60;
        
        llRegionSayTo(avatarKey, 0, "The spirits are still revealing their visions to me. I must meditate for " + (string)remainingMinutes + " more minutes before receiving new prophecies.");
        return;
    }
    
    // Set state
    currentState = STATE_PROPHESYING;
    interactingWith = avatarKey;
    lastProphecyTime = currentTime;
    
    // Get a prophecy
    string prophecy = getRandomProphecy(avatarKey);
    
    // Record recipient
    prophecyRecipients += [avatarName];
    if (llGetListLength(prophecyRecipients) > 5) {
        prophecyRecipients = llDeleteSubList(prophecyRecipients, 0, 0);
    }
    
    // Activate mystical effects
    activateMysticalMode();
    
    // Announce the prophecy is being given
    if (isImperialFamily(avatarKey)) {
        string title = "";
        
        if (isTsar(avatarKey)) {
            title = "His Imperial Majesty, the Tsar";
        }
        else if (isTsarina(avatarKey)) {
            title = "Her Imperial Majesty, the Tsarina";
        }
        else if (isZarevich(avatarKey)) {
            title = "His Imperial Highness, the Zarevich";
        }
        else {
            title = "a member of the Imperial family";
        }
        
        llSay(0, "Rasputin's eyes grow distant as he delivers a divine prophecy to " + title + ".");
    }
    else {
        llSay(0, "Rasputin fixes his intense gaze upon " + avatarName + " and begins to speak in a trance-like state.");
    }
    
    // Deliver the prophecy
    llRegionSayTo(avatarKey, 0, "\"" + prophecy + "\"");
    
    // Send stats update for receiving prophecy
    string statUpdate = "RASPUTIN_PROPHECY|MYSTICAL:3|FAITH:2";
    
    // Special bonuses for imperial family
    if (isImperialFamily(avatarKey)) {
        statUpdate += "|INSIGHT:2";
    }
    
    llRegionSayTo(avatarKey, STATS_CHANNEL, statUpdate);
    
    // Set timer to return to normal state
    llSetTimerEvent(10.0);
}

// Function to perform healing
performHealing(key patientKey, string patientName) {
    // Check cooldown
    integer currentTime = llGetUnixTime();
    if (lastHealingTime > 0 && currentTime - lastHealingTime < healingCooldown) {
        integer remainingTime = healingCooldown - (currentTime - lastHealingTime);
        integer remainingMinutes = remainingTime / 60;
        
        llRegionSayTo(patientKey, 0, "My healing powers are temporarily exhausted. I must rest for " + (string)remainingMinutes + " more minutes before I can heal again.");
        return;
    }
    
    // Set state
    currentState = STATE_HEALING;
    interactingWith = patientKey;
    lastHealingTime = currentTime;
    
    // Special case for Zarevich
    if (isZarevich(patientKey)) {
        performZarevichHealing(patientKey, patientName);
        return;
    }
    
    // Activate mystical effects
    activateMysticalMode();
    
    // Announce the healing
    llSay(0, "Rasputin places his hands upon " + patientName + " and begins to pray fervently, his voice rising and falling in mysterious cadence.");
    
    // Calculate healing effectiveness
    integer healingEffect = healingStrength;
    
    // Send effect message to patient
    string effectMessage = "Rasputin's touch feels warm, and a strange calm washes over you. You feel your ailments beginning to subside.";
    llRegionSayTo(patientKey, 0, effectMessage);
    
    // Send stats update to patient's HUD
    string statUpdate = "RASPUTIN_HEALING|HEALTH:" + (string)healingEffect + "|CALM:2|FAITH:2";
    llRegionSayTo(patientKey, STATS_CHANNEL, statUpdate);
    
    // Set timer to return to normal state
    llSetTimerEvent(10.0);
}

// Function to perform special healing for the Zarevich
performZarevichHealing(key patientKey, string patientName) {
    // Highly effective healing for Zarevich's hemophilia
    
    // Extra mystical effects
    activateMysticalMode();
    
    // Announce the special healing
    llSay(0, "Rasputin's countenance changes as he approaches the Zarevich. His eyes burn with inner fire as he places his hands gently on the boy's head and begins to pray in an ancient tongue.");
    
    // Calculate special healing effect
    integer specialHealingEffect = healingStrength * 2;
    
    // Send effect message to Zarevich
    string effectMessage = "As Rasputin prays over you, the pain begins to subside. His voice seems to reach beyond the physical realm, and you feel a mysterious force stabilizing your condition.";
    llRegionSayTo(patientKey, 0, effectMessage);
    
    // Send enhanced stats update for Zarevich's HUD
    string statUpdate = "RASPUTIN_ZAREVICH_HEALING|HEALTH:" + (string)specialHealingEffect + 
                        "|HEMOPHILIA_RELIEF:1|BLEEDING_STOP:1|PAIN_RELIEF:3|FAITH:3";
    
    llRegionSayTo(patientKey, STATS_CHANNEL, statUpdate);
    
    // Record special healing
    integer index = llListFindList(specialPatients, [patientKey]);
    if (index >= 0) {
        healingTimes = llListReplaceList(healingTimes, [llGetUnixTime()], index, index);
    }
    else {
        specialPatients += [patientKey];
        healingTimes += [llGetUnixTime()];
    }
    
    // Set timer to return to normal state
    llSetTimerEvent(15.0); // Longer for special healing
}

// Function to engage in conversation
startConversation(key avatarKey, string avatarName) {
    // Set state
    currentState = STATE_TALKING;
    interactingWith = avatarKey;
    
    // Choose appropriate greeting based on who they are
    string greeting = "";
    
    if (isTsar(avatarKey)) {
        greeting = "Your Imperial Majesty, God's chosen ruler of all Russia. I am humbled by your presence. How may this servant of God assist you today?";
    }
    else if (isTsarina(avatarKey)) {
        greeting = "Your Imperial Majesty, your devotion to family and faith shines like a beacon. What guidance do you seek from Rasputin today?";
    }
    else if (isZarevich(avatarKey)) {
        greeting = "Young Alexei, brave son of Russia. How are you feeling today? Rasputin is here to bring comfort and healing when needed.";
    }
    else if (isImperialFamily(avatarKey)) {
        greeting = "Your Imperial Highness, it is an honor to converse with a member of the Romanov family. How may I be of service?";
    }
    else {
        greeting = avatarName + ", what brings you to speak with Rasputin? Do you seek prophecy, guidance, or simply conversation?";
    }
    
    // Deliver greeting
    llRegionSayTo(avatarKey, 0, greeting);
    
    // Start NPC animation for talking
    // Would use llStartAnimation(ANIM_TALK) in a real implementation
}

// Function to activate mystical appearance
activateMysticalMode() {
    if (!mysticalModeActive) {
        mysticalModeActive = TRUE;
        
        // Apply glow effect to Rasputin
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_GLOW, ALL_SIDES, 0.1,
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE
        ]);
        
        // Create subtle particles for mystical effect
        llParticleSystem([
            PSYS_PART_FLAGS, 
                PSYS_PART_INTERP_COLOR_MASK | 
                PSYS_PART_INTERP_SCALE_MASK | 
                PSYS_PART_EMISSIVE_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR, <0.5, 0.5, 0.9>,
            PSYS_PART_END_COLOR, <0.1, 0.1, 0.5>,
            PSYS_PART_START_ALPHA, 0.3,
            PSYS_PART_END_ALPHA, 0.0,
            PSYS_PART_START_SCALE, <0.05, 0.05, 0.0>,
            PSYS_PART_END_SCALE, <0.2, 0.2, 0.0>,
            PSYS_PART_MAX_AGE, 3.0,
            PSYS_SRC_BURST_RATE, 0.1,
            PSYS_SRC_BURST_PART_COUNT, 2,
            PSYS_SRC_ACCEL, <0.0, 0.0, 0.01>,
            PSYS_SRC_BURST_RADIUS, 0.5,
            PSYS_SRC_BURST_SPEED_MIN, 0.0,
            PSYS_SRC_BURST_SPEED_MAX, 0.05,
            PSYS_SRC_MAX_AGE, 0.0
        ]);
    }
}

// Function to deactivate mystical appearance
deactivateMysticalMode() {
    if (mysticalModeActive) {
        mysticalModeActive = FALSE;
        
        // Remove glow effects
        llSetLinkPrimitiveParamsFast(LINK_THIS, [
            PRIM_GLOW, ALL_SIDES, 0.0,
            PRIM_FULLBRIGHT, ALL_SIDES, FALSE
        ]);
        
        // Stop particles
        llParticleSystem([]);
    }
}

// Function to return to idle state
returnToIdle() {
    // Reset state
    currentState = STATE_IDLE;
    interactingWith = NULL_KEY;
    
    // Stop any active animations
    // Would use llStopAnimation() for each animation in a real implementation
    
    // Start idle animation
    // Would use llStartAnimation(ANIM_IDLE) in a real implementation
    
    // Deactivate mystical effects
    deactivateMysticalMode();
}

// Process commands from other system components
processRasputinCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "SUMMON" && isImperialFamily(senderKey)) {
        // Format: SUMMON|location
        if (llGetListLength(messageParts) >= 2) {
            string location = llList2String(messageParts, 1);
            llSay(0, "Rasputin is summoned to " + location + " by the Imperial family.");
            
            // In a full implementation, would teleport or navigate to location
        }
    }
    else if (command == "DISMISS" && isImperialFamily(senderKey)) {
        returnToIdle();
        llSay(0, "Rasputin bows deeply and withdraws as commanded by the Imperial family.");
    }
}

// Function to determine appropriate response to user interactions
processInteraction(key avatarKey, string avatarName, string message) {
    // Convert to lowercase for easier matching
    string lowerMessage = llToLower(message);
    
    // Check for healing requests
    if (llSubStringIndex(lowerMessage, "heal") >= 0 || 
        llSubStringIndex(lowerMessage, "cure") >= 0 || 
        llSubStringIndex(lowerMessage, "treatment") >= 0 ||
        llSubStringIndex(lowerMessage, "better") >= 0) {
        
        performHealing(avatarKey, avatarName);
        return;
    }
    
    // Check for prophecy requests
    if (llSubStringIndex(lowerMessage, "prophecy") >= 0 || 
        llSubStringIndex(lowerMessage, "future") >= 0 || 
        llSubStringIndex(lowerMessage, "predict") >= 0 ||
        llSubStringIndex(lowerMessage, "vision") >= 0 ||
        llSubStringIndex(lowerMessage, "foresee") >= 0) {
        
        deliverProphecy(avatarKey, avatarName);
        return;
    }
    
    // Check for greetings
    if (llSubStringIndex(lowerMessage, "hello") >= 0 || 
        llSubStringIndex(lowerMessage, "greetings") >= 0 || 
        llSubStringIndex(lowerMessage, "good day") >= 0) {
        
        startConversation(avatarKey, avatarName);
        return;
    }
    
    // General response for other queries
    string response = "";
    
    // Special responses for imperial family
    if (isTsar(avatarKey)) {
        response = "Your Imperial Majesty, Rasputin is ever your loyal servant. I pray daily for the Tsar and the future of Holy Russia.";
    }
    else if (isTsarina(avatarKey)) {
        response = "Your Imperial Majesty, your faith gives strength to all around you. Rasputin is honored to serve the Tsarina.";
    }
    else if (isZarevich(avatarKey)) {
        response = "Young Alexei, God has special plans for you. Your suffering will make you strong, and Rasputin will always be here to help.";
    }
    else {
        response = "The will of God moves in mysterious ways. Rasputin sees both light and darkness in the days ahead. Stay faithful, and you will find your path.";
    }
    
    llRegionSayTo(avatarKey, 0, response);
}

default {
    state_entry() {
        // Initialize prophecies
        initializeProphecies();
        
        // Start listening for chat
        listenHandle = llListen(0, "", NULL_KEY, "");
        
        // Also listen on Rasputin channel for system commands
        listenHandle = llListen(RASPUTIN_CHANNEL, "", NULL_KEY, "");
        
        // Set initial state
        returnToIdle();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Show interaction menu
        list options = ["Speak with Rasputin"];
        
        // Add special options based on who is touching
        if (isZarevich(toucherKey)) {
            options = ["Request Healing", "Ask for Prophecy", "Speak with Rasputin"];
        }
        else if (isImperialFamily(toucherKey)) {
            options = ["Request Prophecy", "Speak with Rasputin", "Dismiss Rasputin"];
        }
        else {
            // Regular person
            options = ["Ask for Guidance", "Request Prophecy", "Speak with Rasputin"];
        }
        
        // Present dialog to select interaction
        llDialog(toucherKey, "How do you wish to interact with Rasputin?", options, RASPUTIN_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Check if this is on the Rasputin special channel
        if (channel == RASPUTIN_CHANNEL) {
            // Process menu selections
            if (message == "Request Healing" || message == "Ask for Healing") {
                performHealing(id, name);
            }
            else if (message == "Request Prophecy" || message == "Ask for Prophecy") {
                deliverProphecy(id, name);
            }
            else if (message == "Speak with Rasputin" || message == "Ask for Guidance") {
                startConversation(id, name);
            }
            else if (message == "Dismiss Rasputin" && isImperialFamily(id)) {
                returnToIdle();
                llSay(0, "Rasputin bows deeply and withdraws as commanded by " + name + ".");
            }
            else {
                // Check if it's a system command
                processRasputinCommand(message, id);
            }
        }
        // Listen for direct chat messages to Rasputin
        else if (channel == 0) {
            // Check if Rasputin is mentioned
            if (llSubStringIndex(llToLower(message), "rasputin") >= 0) {
                processInteraction(id, name, message);
            }
        }
    }
    
    timer() {
        // Return to idle state after timer expires
        returnToIdle();
        
        // Stop timer
        llSetTimerEvent(0.0);
    }
}