// Imperial Russian Court Roleplay System
// Script: Imperial Candelabra Reactive
// Version: 1.0
// Description: Ornate candelabra that reacts to the presence of imperial family members

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei
key TSARINA_UUID = NULL_KEY; // Placeholder for Tsarina Alexandra

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer CANDELABRA_CHANNEL = -8675330; // Specific channel for candelabra

// Candelabra types
integer TYPE_SILVER = 0;       // Silver candelabra (standard)
integer TYPE_GOLD = 1;         // Gold candelabra (royal rooms)
integer TYPE_CRYSTAL = 2;      // Crystal candelabra (ballroom/throne room)
integer TYPE_IMPERIAL = 3;     // Imperial candelabra (Tsar's personal chambers)

// Candelabra states
integer STATE_UNLIT = 0;       // Candles unlit
integer STATE_LIT = 1;         // Candles normally lit
integer STATE_ENHANCED = 2;    // Enhanced lighting (royal presence)
integer STATE_DIMMED = 3;      // Dimmed lighting (evening/night)

// Status variables
integer currentType = TYPE_SILVER;
integer currentState = STATE_UNLIT;
integer candleCount = 5;       // Number of candles in this candelabra
integer candlesLit = 0;        // Number currently lit
string locationName = "Grand Corridor"; // Where this candelabra is located
integer autoLightingEnabled = TRUE; // Whether it lights automatically at night
integer royalPresenceDetected = FALSE; // Whether royalty is nearby
integer scanTimer = 5;         // Seconds between proximity scans
float scanRange = 15.0;        // Range to detect avatars

// Lighting variables
vector normalFlameColor = <1.0, 0.75, 0.45>; // Standard flame color
vector royalFlameColor = <1.0, 0.85, 0.6>;   // Brighter for royalty
float normalGlow = 0.2;         // Standard glow amount
float royalGlow = 0.3;          // Enhanced glow for royalty
float normalIntensity = 0.8;    // Standard light intensity
float royalIntensity = 1.0;     // Enhanced intensity for royalty
integer particleCount = 2;      // Particles per emission
integer particleCountRoyal = 3; // Enhanced particles for royalty

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

// Function to light the candelabra
lightCandles() {
    // Check current state
    if (currentState == STATE_LIT || currentState == STATE_ENHANCED) {
        return; // Already lit
    }
    
    // Set to lit state
    currentState = STATE_LIT;
    candlesLit = candleCount;
    
    // Apply standard lighting effects
    applyLightingEffects(normalFlameColor, normalGlow, normalIntensity, particleCount);
    
    // Trigger lighting sound
    llPlaySound("candle_light", 0.3);
    
    // Update description
    updateCandelabraDisplay();
}

// Function to enhance lighting for royalty
enhanceLighting() {
    // Set to enhanced state
    currentState = STATE_ENHANCED;
    candlesLit = candleCount;
    
    // Apply enhanced lighting effects
    applyLightingEffects(royalFlameColor, royalGlow, royalIntensity, particleCountRoyal);
    
    // Update description
    updateCandelabraDisplay();
}

// Function to dim the candelabra
dimCandles() {
    // Check current state
    if (currentState == STATE_UNLIT) {
        return; // Already unlit
    }
    
    // Set to dimmed state
    currentState = STATE_DIMMED;
    candlesLit = llCeil(candleCount * 0.6); // About 60% of candles remain lit
    
    // Apply dimmed lighting effects
    vector dimColor = normalFlameColor * 0.8;
    applyLightingEffects(dimColor, normalGlow * 0.5, normalIntensity * 0.6, 1);
    
    // Update description
    updateCandelabraDisplay();
}

// Function to extinguish the candelabra
extinguishCandles() {
    // Check current state
    if (currentState == STATE_UNLIT) {
        return; // Already unlit
    }
    
    // Set to unlit state
    currentState = STATE_UNLIT;
    candlesLit = 0;
    
    // Remove lighting effects
    applyLightingEffects(ZERO_VECTOR, 0.0, 0.0, 0);
    
    // Trigger extinguishing sound
    llPlaySound("candle_extinguish", 0.3);
    
    // Update description
    updateCandelabraDisplay();
}

// Function to apply lighting effects
applyLightingEffects(vector flameColor, float glowAmount, float lightIntensity, integer particlesPerEmission) {
    // Set glow on main candelabra parts
    llSetLinkPrimitiveParamsFast(LINK_SET, [
        PRIM_GLOW, ALL_SIDES, glowAmount,
        PRIM_FULLBRIGHT, ALL_SIDES, (glowAmount > 0.0)
    ]);
    
    // Set specific flame colors on flame prims
    // This would require identifying the specific link numbers for flame prims
    // For this example, we'll assume links 2-6 are the flame prims
    integer i;
    for (i = 2; i <= 6 && i <= candlesLit + 1; i++) {
        llSetLinkPrimitiveParamsFast(i, [
            PRIM_COLOR, ALL_SIDES, flameColor, 1.0,
            PRIM_GLOW, ALL_SIDES, glowAmount * 1.5, // Flames glow more
            PRIM_FULLBRIGHT, ALL_SIDES, TRUE
        ]);
    }
    
    // Extinguish any candles that should be out
    for (; i <= 6; i++) {
        llSetLinkPrimitiveParamsFast(i, [
            PRIM_COLOR, ALL_SIDES, <0.5, 0.5, 0.5>, 1.0,  // Gray for unlit wicks
            PRIM_GLOW, ALL_SIDES, 0.0,
            PRIM_FULLBRIGHT, ALL_SIDES, FALSE
        ]);
    }
    
    // Set point light
    llSetLinkPrimitiveParamsFast(LINK_ROOT, [
        PRIM_POINT_LIGHT, (lightIntensity > 0.0), flameColor, lightIntensity, 10.0, 0.75
    ]);
    
    // Set particle system for flame effects if lit
    if (particlesPerEmission > 0) {
        // Create flame and smoke particles
        llLinkParticleSystem(LINK_SET, [
            PSYS_PART_FLAGS, 
                PSYS_PART_INTERP_COLOR_MASK | 
                PSYS_PART_INTERP_SCALE_MASK | 
                PSYS_PART_EMISSIVE_MASK |
                PSYS_PART_FOLLOW_VELOCITY_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR, flameColor,
            PSYS_PART_END_COLOR, <0.5, 0.3, 0.1>,
            PSYS_PART_START_ALPHA, 0.8,
            PSYS_PART_END_ALPHA, 0.1,
            PSYS_PART_START_SCALE, <0.04, 0.04, 0.0>,
            PSYS_PART_END_SCALE, <0.02, 0.02, 0.0>,
            PSYS_PART_MAX_AGE, 1.0,
            PSYS_SRC_BURST_RATE, 0.02,
            PSYS_SRC_BURST_PART_COUNT, particlesPerEmission,
            PSYS_SRC_ACCEL, <0.0, 0.0, 0.05>,
            PSYS_SRC_BURST_RADIUS, 0.05,
            PSYS_SRC_BURST_SPEED_MIN, 0.01,
            PSYS_SRC_BURST_SPEED_MAX, 0.05,
            PSYS_SRC_MAX_AGE, 0.0
        ]);
    }
    else {
        // Turn off particles if not lit
        llLinkParticleSystem(LINK_SET, []);
    }
}

// Function to detect imperial family presence
detectRoyalPresence(key avatarKey, string avatarName) {
    if (isImperialFamily(avatarKey)) {
        // Only proceed if this is a change in status
        if (!royalPresenceDetected) {
            royalPresenceDetected = TRUE;
            
            // If candles are already lit, enhance them
            if (currentState == STATE_LIT || currentState == STATE_DIMMED) {
                enhanceLighting();
                
                // Subtly announce the enhanced lighting
                string royalTitle = "";
                if (isTsar(avatarKey)) {
                    royalTitle = "His Imperial Majesty";
                }
                else if (isTsarina(avatarKey)) {
                    royalTitle = "Her Imperial Majesty";
                }
                else if (isZarevich(avatarKey)) {
                    royalTitle = "His Imperial Highness";
                }
                else {
                    royalTitle = "a member of the Imperial family";
                }
                
                llSay(0, "The candles in the " + locationName + " seem to burn more brightly as " + royalTitle + " approaches.");
            }
            // If candles are unlit, light them
            else if (currentState == STATE_UNLIT) {
                lightCandles();
                enhanceLighting();
                
                llSay(0, "The candelabra in the " + locationName + " ignites spontaneously as " + avatarName + " enters.");
            }
        }
    }
}

// Function to handle royal departure
handleRoyalDeparture() {
    // Only proceed if royalty was previously detected
    if (royalPresenceDetected) {
        royalPresenceDetected = FALSE;
        
        // Return to normal lighting if currently enhanced
        if (currentState == STATE_ENHANCED) {
            currentState = STATE_LIT;
            applyLightingEffects(normalFlameColor, normalGlow, normalIntensity, particleCount);
            
            // Subtle message about the change
            llSay(0, "The candles in the " + locationName + " return to their normal brightness.");
            
            // Update description
            updateCandelabraDisplay();
        }
    }
}

// Function to handle time-based lighting changes
handleTimeChange(integer hour) {
    // Only apply automatic lighting changes if enabled
    if (!autoLightingEnabled) {
        return;
    }
    
    // Evening hours - light candles if unlit
    if (hour >= 17 || hour <= 5) { // 5pm to 5am
        if (currentState == STATE_UNLIT) {
            lightCandles();
            
            // Only announce if not late night
            if (hour >= 17 && hour <= 22) {
                llSay(0, "A servant lights the candelabra in the " + locationName + " as evening approaches.");
            }
        }
        
        // Very late - dim if not already dimmed or unlit
        if ((hour >= 23 || hour <= 5) && currentState != STATE_DIMMED && currentState != STATE_UNLIT) {
            // Skip dimming if royalty is present
            if (!royalPresenceDetected) {
                dimCandles();
                llSay(0, "The candelabra in the " + locationName + " burns lower as the hour grows late.");
            }
        }
    }
    // Morning hours - extinguish candles if lit
    else if (hour >= 7 && hour <= 16) { // 7am to 4pm
        if (currentState != STATE_UNLIT) {
            extinguishCandles();
            llSay(0, "A servant extinguishes the candelabra in the " + locationName + " for the day.");
        }
    }
}

// Function to update candelabra description and appearance
updateCandelabraDisplay() {
    string displayText = "Imperial Candelabra\n";
    displayText += locationName + "\n";
    
    // Show current state
    if (currentState == STATE_UNLIT) {
        displayText += "Status: Unlit";
    }
    else if (currentState == STATE_LIT) {
        displayText += "Status: Lit (" + (string)candlesLit + " of " + (string)candleCount + " candles)";
    }
    else if (currentState == STATE_ENHANCED) {
        displayText += "Status: Brilliantly Lit (Royal Presence)";
    }
    else if (currentState == STATE_DIMMED) {
        displayText += "Status: Dimmed (" + (string)candlesLit + " of " + (string)candleCount + " candles)";
    }
    
    // Set the text with appropriate color based on type
    vector textColor = <0.9, 0.9, 0.9>; // White for default
    
    if (currentType == TYPE_SILVER) {
        textColor = <0.8, 0.8, 0.8>; // Silver
    }
    else if (currentType == TYPE_GOLD) {
        textColor = <0.9, 0.8, 0.2>; // Gold
    }
    else if (currentType == TYPE_CRYSTAL) {
        textColor = <0.8, 0.9, 1.0>; // Crystal blue
    }
    else if (currentType == TYPE_IMPERIAL) {
        textColor = <1.0, 0.8, 0.3>; // Imperial gold
    }
    
    llSetText(displayText, textColor, 1.0);
}

// Function to configure the candelabra
configureCandelabra(integer type, string location, integer candles, integer autoLight) {
    currentType = type;
    locationName = location;
    candleCount = candles;
    autoLightingEnabled = autoLight;
    
    // Update appearance based on type
    if (currentType == TYPE_SILVER) {
        // Silver appearance
        llSetLinkColor(LINK_SET, <0.8, 0.8, 0.8>, ALL_SIDES);
    }
    else if (currentType == TYPE_GOLD) {
        // Gold appearance
        llSetLinkColor(LINK_SET, <0.9, 0.8, 0.2>, ALL_SIDES);
    }
    else if (currentType == TYPE_CRYSTAL) {
        // Crystal appearance
        llSetLinkColor(LINK_SET, <0.9, 0.95, 1.0>, ALL_SIDES);
        llSetLinkPrimitiveParamsFast(LINK_SET, [
            PRIM_ALPHA_MODE, ALL_SIDES, PRIM_ALPHA_MODE_BLEND, 0
        ]);
    }
    else if (currentType == TYPE_IMPERIAL) {
        // Imperial appearance
        llSetLinkColor(LINK_SET, <1.0, 0.8, 0.3>, ALL_SIDES);
    }
    
    // Update display
    updateCandelabraDisplay();
}

// Process commands from other system components
processCandelabraCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "LIGHT") {
        // Manual light command
        lightCandles();
        
        // If sender is royalty, enhance
        if (isImperialFamily(senderKey)) {
            enhanceLighting();
        }
        
        // Acknowledge
        llRegionSayTo(senderKey, 0, "The candelabra has been lit.");
    }
    else if (command == "EXTINGUISH") {
        // Manual extinguish command
        extinguishCandles();
        
        // Acknowledge
        llRegionSayTo(senderKey, 0, "The candelabra has been extinguished.");
    }
    else if (command == "DIM") {
        // Manual dim command
        dimCandles();
        
        // Acknowledge
        llRegionSayTo(senderKey, 0, "The candelabra has been dimmed.");
    }
    else if (command == "AUTO_LIGHTING" && isImperialFamily(senderKey)) {
        // Format: AUTO_LIGHTING|enabled
        if (llGetListLength(messageParts) >= 2) {
            integer enabled = (integer)llList2String(messageParts, 1);
            autoLightingEnabled = enabled;
            
            // Acknowledge
            llRegionSayTo(senderKey, 0, "Automatic lighting has been " + 
                         (autoLightingEnabled ? "enabled" : "disabled") + " for this candelabra.");
        }
    }
    else if (command == "CONFIGURE" && isTsar(senderKey)) {
        // Format: CONFIGURE|type|location|candles|autoLight
        if (llGetListLength(messageParts) >= 5) {
            integer type = (integer)llList2String(messageParts, 1);
            string location = llList2String(messageParts, 2);
            integer candles = (integer)llList2String(messageParts, 3);
            integer autoLight = (integer)llList2String(messageParts, 4);
            
            configureCandelabra(type, location, candles, autoLight);
            
            // Acknowledge
            llRegionSayTo(senderKey, 0, "Candelabra configuration updated, Your Imperial Majesty.");
        }
    }
}

default {
    state_entry() {
        // Configure default settings
        configureCandelabra(TYPE_SILVER, "Grand Corridor", 5, TRUE);
        
        // Start listening for system events
        llListen(CANDELABRA_CHANNEL, "", NULL_KEY, "");
        
        // Start scanning for avatars
        llSensorRepeat("", NULL_KEY, AGENT, scanRange, PI, scanTimer);
        
        // Check current time to set initial lighting state
        integer hour = (integer)llGetTimestamp() % 24;
        handleTimeChange(hour);
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Different options based on who is touching
        list options = [];
        
        if (isImperialFamily(toucherKey)) {
            // Royal interaction menu
            options = ["Light Candelabra", "Extinguish Candelabra", "Dim Candelabra"];
            
            // Add auto-lighting toggle
            options += ["Toggle Auto-Lighting"];
            
            // If Tsar, add configuration
            if (isTsar(toucherKey)) {
                options += ["Configure Candelabra"];
            }
        }
        else {
            // Servant or regular visitor
            options = ["Light Candelabra", "Extinguish Candelabra", "Dim Candelabra"];
        }
        
        // Show menu
        llDialog(toucherKey, "Select an action for the Imperial Candelabra:", options, CANDELABRA_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Process menu selections
        if (channel == CANDELABRA_CHANNEL) {
            if (message == "Light Candelabra") {
                processCandelabraCommand("LIGHT", id);
            }
            else if (message == "Extinguish Candelabra") {
                processCandelabraCommand("EXTINGUISH", id);
            }
            else if (message == "Dim Candelabra") {
                processCandelabraCommand("DIM", id);
            }
            else if (message == "Toggle Auto-Lighting" && isImperialFamily(id)) {
                processCandelabraCommand("AUTO_LIGHTING|" + (string)(!autoLightingEnabled), id);
            }
            else if (message == "Configure Candelabra" && isTsar(id)) {
                // Show type options
                list typeOptions = ["Silver Candelabra", "Gold Candelabra", "Crystal Candelabra", "Imperial Candelabra"];
                llDialog(id, "Select the candelabra type:", typeOptions, CANDELABRA_CHANNEL + 1);
            }
            else {
                processCandelabraCommand(message, id);
            }
        }
        else if (channel == CANDELABRA_CHANNEL + 1 && isTsar(id)) {
            // Process type selection
            integer type = TYPE_SILVER;
            
            if (message == "Gold Candelabra") {
                type = TYPE_GOLD;
            }
            else if (message == "Crystal Candelabra") {
                type = TYPE_CRYSTAL;
            }
            else if (message == "Imperial Candelabra") {
                type = TYPE_IMPERIAL;
            }
            
            // Show location options
            list locationOptions = ["Grand Corridor", "Imperial Throne Room", "Winter Palace Ballroom", "Tsar's Study"];
            llDialog(id, "Select the candelabra location:", locationOptions, CANDELABRA_CHANNEL + 2);
            
            // Store the selected type temporarily
            currentType = type;
        }
        else if (channel == CANDELABRA_CHANNEL + 2 && isTsar(id)) {
            // Process location selection and finish configuration
            string location = message;
            
            // Choose appropriate candle count based on type and location
            integer candles = 5; // Default
            
            if (currentType == TYPE_IMPERIAL) {
                candles = 7;
            }
            else if (currentType == TYPE_CRYSTAL && 
                    (location == "Imperial Throne Room" || location == "Winter Palace Ballroom")) {
                candles = 9;
            }
            else if (currentType == TYPE_GOLD) {
                candles = 7;
            }
            
            // Apply the full configuration
            configureCandelabra(currentType, location, candles, autoLightingEnabled);
            
            // Acknowledge
            llRegionSayTo(id, 0, "Candelabra configuration updated, Your Imperial Majesty.");
        }
    }
    
    sensor(integer num_detected) {
        // Reset royal presence flag before checking
        integer royaltyFound = FALSE;
        
        // Check for imperial family members
        integer i;
        for (i = 0; i < num_detected; i++) {
            key detectedKey = llDetectedKey(i);
            string detectedName = llDetectedName(i);
            
            if (isImperialFamily(detectedKey)) {
                detectRoyalPresence(detectedKey, detectedName);
                royaltyFound = TRUE;
                
                // Once we've detected one royal person, stop processing
                break;
            }
        }
        
        // If no royalty found but previously detected, handle departure
        if (!royaltyFound && royalPresenceDetected) {
            handleRoyalDeparture();
        }
    }
    
    timer() {
        // Check time every hour for automatic lighting changes
        integer hour = (integer)llGetGMTclock();
        handleTimeChange(hour);
        
        // Reset timer for next hour
        llSetTimerEvent(3600.0); // One hour
    }
}