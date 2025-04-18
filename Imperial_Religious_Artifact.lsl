// Imperial Russian Court RP - Religious Artifact
// This script creates an interactive Orthodox icon with resurrection mechanics
// For use with the Imperial Russian Court roleplay system

// Communication channels
integer ARTIFACT_CHANNEL = -9000001;
integer PRAYER_CHANNEL;
integer RESURRECTION_CHANNEL;
integer MENU_CHANNEL;
integer listenHandle;

// Artifact properties
string ARTIFACT_NAME = "Sacred Icon";
string SAINT_NAME = "St. Nicholas"; // The saint depicted
float PRAYER_POWER = 0.0; // Accumulated prayer power
float PRAYER_THRESHOLD = 100.0; // Power needed for resurrection
integer PRAYER_ACTIVE = FALSE; // Whether prayer is in progress
integer CAN_RESURRECT = TRUE; // Whether this artifact can resurrect

// Prayer settings
float PRAYER_TIME = 30.0; // How long a prayer session lasts
float PRAYER_VALUE = 5.0; // How much power gained per prayer
integer MAX_DAILY_PRAYERS = 5; // Max prayers per day per person
float POWER_DECAY_RATE = 1.0; // How much power decays per hour

// Particle settings for prayer effect
vector PRAYER_COLOR = <0.9, 0.8, 0.2>; // Gold color
float PARTICLE_DURATION = 1.5; // How long particles last

// Security and tracking
key ownerID;
key currentPrayerID = NULL_KEY;
string currentPrayerName = "";
list recentPrayers = []; // Format: [key ID, integer prayerCount, integer timestamp]
key lastResurrection = NULL_KEY;
integer lastResurrectionTime = 0;

// Timer control
integer timerRunning = FALSE;
integer nextTimerAction = 0; // 0=none, 1=end prayer, 2=power decay
integer DECAY_CHECK_INTERVAL = 3600; // Check power decay every hour

// Initialize the artifact
initialize() {
    // Set up random channels
    PRAYER_CHANNEL = ARTIFACT_CHANNEL - (integer)llFrand(10000);
    RESURRECTION_CHANNEL = ARTIFACT_CHANNEL - 10000 - (integer)llFrand(10000);
    MENU_CHANNEL = ARTIFACT_CHANNEL - 20000 - (integer)llFrand(10000);
    
    // Setup artifact appearance
    llSetText(ARTIFACT_NAME + "\n" + SAINT_NAME + "\nPrayer Power: " + 
             (string)((integer)PRAYER_POWER) + "%", PRAYER_COLOR, 1.0);

    // Listen for interaction
    llListen(PRAYER_CHANNEL, "", NULL_KEY, "");
    
    // Start decay timer
    startDecayTimer();
}

// Start a timer for checking power decay
startDecayTimer() {
    if (!timerRunning) {
        timerRunning = TRUE;
        nextTimerAction = 2; // decay
        llSetTimerEvent(DECAY_CHECK_INTERVAL);
    }
}

// Start a timer for ending prayer
startPrayerTimer() {
    timerRunning = TRUE;
    nextTimerAction = 1; // end prayer
    llSetTimerEvent(PRAYER_TIME);
}

// Update artifact display
updateDisplay() {
    // Update floating text
    llSetText(ARTIFACT_NAME + "\n" + SAINT_NAME + "\nPrayer Power: " + 
             (string)((integer)PRAYER_POWER) + "%", PRAYER_COLOR, 1.0);
    
    // Update glow based on power
    float glowAmount = PRAYER_POWER / PRAYER_THRESHOLD;
    if (glowAmount > 1.0) glowAmount = 1.0;
    if (glowAmount < 0.1) glowAmount = 0.1;
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, glowAmount]);
}

// Start prayer effect (particles)
startPrayerEffect(key prayerID) {
    vector particleStart = llGetPos() + <0.0, 0.0, 0.3>;
    
    // Get position of the praying avatar
    list avatarDetails = llGetObjectDetails(prayerID, [OBJECT_POS]);
    vector avatarPos = llList2Vector(avatarDetails, 0);
    
    // Create particles from icon to avatar
    llParticleSystem([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
        PSYS_SRC_ACCEL, <0.0, 0.0, -0.1>,
        PSYS_SRC_BURST_RATE, 0.1,
        PSYS_SRC_BURST_PART_COUNT, 5,
        PSYS_SRC_BURST_RADIUS, 0.1,
        PSYS_SRC_BURST_SPEED_MIN, 0.5,
        PSYS_SRC_BURST_SPEED_MAX, 1.0,
        PSYS_SRC_OUTER_ANGLE, 0.6,
        PSYS_SRC_MAX_AGE, PARTICLE_DURATION,
        PSYS_PART_MAX_AGE, 3.0,
        PSYS_SRC_TEXTURE, "5748decc-f629-461c-9a36-a35a221fe21f",
        PSYS_PART_START_COLOR, PRAYER_COLOR,
        PSYS_PART_END_COLOR, <1.0, 1.0, 1.0>,
        PSYS_PART_START_ALPHA, 0.8,
        PSYS_PART_END_ALPHA, 0.1,
        PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
        PSYS_PART_END_SCALE, <0.05, 0.05, 0.0>,
        PSYS_SRC_TARGET_KEY, prayerID,
        PSYS_SRC_OMEGA, <0, 0, 0>,
        PSYS_SRC_ANGLE_BEGIN, 0,
        PSYS_SRC_ANGLE_END, 0
    ]);
}

// Stop prayer effect
stopPrayerEffect() {
    llParticleSystem([]);
}

// Process prayer from avatar
processPrayer(key avatarID, string avatarName) {
    // Check if already praying
    if (PRAYER_ACTIVE) {
        llRegionSayTo(avatarID, 0, "Please wait until the current prayer session is complete.");
        return;
    }
    
    // Check if this person has prayed too many times today
    integer prayerCount = 0;
    integer avatarIndex = -1;
    integer i = 0;
    integer listLength = llGetListLength(recentPrayers);
    integer currentTime = llGetUnixTime();
    
    // Check for existing prayer counts
    while (i < listLength) {
        key storedID = llList2Key(recentPrayers, i);
        if (storedID == avatarID) {
            avatarIndex = i;
            prayerCount = llList2Integer(recentPrayers, i + 1);
            integer prayerTime = llList2Integer(recentPrayers, i + 2);
            
            // Reset count if from a different day
            if (!isSameDay(prayerTime, currentTime)) {
                prayerCount = 0;
            }
            
            i = listLength; // Exit loop
        }
        i += 3; // Move to next record
    }
    
    // Check if too many prayers today
    if (prayerCount >= MAX_DAILY_PRAYERS) {
        llRegionSayTo(avatarID, 0, "You have prayed to this icon too many times today. Please return tomorrow.");
        return;
    }
    
    // Start prayer session
    PRAYER_ACTIVE = TRUE;
    currentPrayerID = avatarID;
    currentPrayerName = avatarName;
    
    // Increment prayer count
    prayerCount++;
    
    // Update or add to recentPrayers list
    if (avatarIndex >= 0) {
        // Update existing record
        recentPrayers = llListReplaceList(recentPrayers, [avatarID, prayerCount, currentTime], 
                                         avatarIndex, avatarIndex + 2);
    }
    else {
        // Add new record
        recentPrayers += [avatarID, prayerCount, currentTime];
    }
    
    // Notify player
    llRegionSayTo(avatarID, 0, "You begin a prayer to " + SAINT_NAME + "...");
    
    // Public message
    llSay(0, avatarName + " begins to pray before the icon of " + SAINT_NAME + ".");
    
    // Start prayer visual effects
    startPrayerEffect(avatarID);
    
    // Start timer for prayer duration
    startPrayerTimer();
}

// Complete prayer session
completePrayer() {
    if (!PRAYER_ACTIVE) {
        return;
    }
    
    // Calculate prayer power
    float powerGained = PRAYER_POWER + PRAYER_VALUE;
    
    // Apply prayer power
    PRAYER_POWER = powerGained;
    if (PRAYER_POWER > PRAYER_THRESHOLD) PRAYER_POWER = PRAYER_THRESHOLD;
    
    // Stop prayer effects
    stopPrayerEffect();
    
    // Notify player
    if (currentPrayerID != NULL_KEY) {
        llRegionSayTo(currentPrayerID, 0, "Your prayer to " + SAINT_NAME + " is complete. The icon's power grows to " + 
                     (string)((integer)PRAYER_POWER) + "%.");
    }
    
    // Public message
    string possessive;
    if (llGetSubString(currentPrayerName, -1, -1) == "s") {
        possessive = "their";
    }
    else {
        possessive = "his/her";
    }
    llSay(0, currentPrayerName + " finishes " + possessive + " prayer to " + SAINT_NAME + ".");
    
    // Reset prayer status
    PRAYER_ACTIVE = FALSE;
    currentPrayerID = NULL_KEY;
    currentPrayerName = "";
    
    // Update display
    updateDisplay();
    
    // Switch to decay timer
    startDecayTimer();
}

// Check prayer power decay
checkPowerDecay() {
    integer currentTime = llGetUnixTime();
    
    // Decay prayer power over time
    if (PRAYER_POWER > 0.0) {
        PRAYER_POWER -= POWER_DECAY_RATE;
        if (PRAYER_POWER < 0.0) PRAYER_POWER = 0.0;
        
        // Update display
        updateDisplay();
    }
    
    // Clean up old prayer records (older than 1 day)
    integer i = 0;
    integer listLength = llGetListLength(recentPrayers);
    
    while (i < listLength) {
        integer prayerTime = llList2Integer(recentPrayers, i + 2);
        
        // Remove if from previous day
        if (!isSameDay(prayerTime, currentTime)) {
            recentPrayers = llDeleteSubList(recentPrayers, i, i + 2);
            listLength -= 3;
        }
        else {
            i += 3; // Move to next record
        }
    }
    
    // Continue decay timer
    startDecayTimer();
}

// Show artifact information
showArtifactInfo(key avatarID) {
    string infoText = "\n=== " + ARTIFACT_NAME + " ===\n\n";
    infoText += "This sacred icon depicts " + SAINT_NAME + ".\n\n";
    
    // Description based on saint
    if (SAINT_NAME == "St. Nicholas") {
        infoText += "St. Nicholas is known as the Wonder-Worker and protector of children, sailors, and the falsely accused. He is one of the most venerated saints in Orthodox Christianity.\n\n";
    }
    else if (SAINT_NAME == "St. George") {
        infoText += "St. George the Victory-Bearer is renowned for slaying a dragon to save a princess. He is the patron saint of soldiers and a symbol of courage.\n\n";
    }
    else if (SAINT_NAME == "St. Seraphim") {
        infoText += "St. Seraphim of Sarov was known for his ascetic life and spiritual wisdom. He is often depicted with a bear, as wild animals were said to obey him.\n\n";
    }
    else if (SAINT_NAME == "Theotokos") {
        infoText += "This icon depicts the Mother of God (Theotokos), the most venerated saint in Orthodox Christianity. She is considered the supreme intercessor before God.\n\n";
    }
    else {
        infoText += "This sacred icon is believed to perform miracles for the faithful who pray before it with sincere hearts.\n\n";
    }
    
    infoText += "Current Prayer Power: " + (string)((integer)PRAYER_POWER) + "%\n";
    infoText += "Prayer Threshold for Resurrection: " + (string)((integer)PRAYER_THRESHOLD) + "%\n\n";
    
    if (CAN_RESURRECT && PRAYER_POWER >= PRAYER_THRESHOLD) {
        infoText += "This icon is filled with divine energy and can perform the miracle of resurrection.";
    }
    else if (CAN_RESURRECT) {
        infoText += "This icon needs more prayers to accumulate sufficient power for resurrection.";
    }
    else {
        infoText += "This icon provides spiritual blessings but cannot perform resurrections.";
    }
    
    llDialog(avatarID, infoText, ["Pray", "Cancel"], PRAYER_CHANNEL);
}

// Process resurrection request
processResurrection(key requestorID, key targetID) {
    // Check if has enough power
    if (PRAYER_POWER < PRAYER_THRESHOLD) {
        llRegionSayTo(requestorID, 0, "The icon does not have sufficient prayer power for resurrection.");
        return;
    }
    
    // Check if can resurrect
    if (!CAN_RESURRECT) {
        llRegionSayTo(requestorID, 0, "This holy icon cannot perform resurrections.");
        return;
    }
    
    // Perform resurrection
    llRegionSayTo(requestorID, 0, "You invoke the divine power of the icon to resurrect " + 
                 llKey2Name(targetID) + ".");
    
    // Public message
    llSay(0, llKey2Name(requestorID) + " uses the sacred icon of " + SAINT_NAME + 
         " to perform a miracle of resurrection upon " + llKey2Name(targetID) + "!");
    
    // Spectacular visual and sound effects
    // Bright light emanating from icon
    llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_GLOW, ALL_SIDES, 1.0]);
    
    // Sound effect
    llPlaySound("d5154357-28d9-4f53-a513-70bf510b1fc8", 1.0); // Choir sound
    
    // Intensive particles
    llParticleSystem([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_SRC_BURST_RATE, 0.1,
        PSYS_SRC_BURST_PART_COUNT, 50,
        PSYS_SRC_BURST_RADIUS, 1.0,
        PSYS_SRC_BURST_SPEED_MIN, 0.5,
        PSYS_SRC_BURST_SPEED_MAX, 1.5,
        PSYS_SRC_MAX_AGE, 5.0,
        PSYS_PART_MAX_AGE, 5.0,
        PSYS_SRC_TEXTURE, "5748decc-f629-461c-9a36-a35a221fe21f",
        PSYS_PART_START_COLOR, <1.0, 1.0, 1.0>,
        PSYS_PART_END_COLOR, PRAYER_COLOR,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>,
        PSYS_PART_END_SCALE, <0.5, 0.5, 0.0>,
        PSYS_SRC_ANGLE_BEGIN, 0,
        PSYS_SRC_ANGLE_END, PI
    ]);
    
    // Send resurrection message to the target
    llRegionSayTo(targetID, 0, "The divine power of " + SAINT_NAME + " flows through you, restoring your life force!");
    
    // Send a message on the resurrection channel (HUDs will listen for this)
    string resurrectionMessage = "RESURRECT|" + (string)targetID + "|" + (string)PRAYER_POWER;
    llRegionSay(RESURRECTION_CHANNEL, resurrectionMessage);
    
    // Record the resurrection
    lastResurrection = targetID;
    lastResurrectionTime = llGetUnixTime();
    
    // Consume prayer power
    PRAYER_POWER = 0.0;
    
    // Update display after a delay
    llSleep(5.0);
    stopPrayerEffect();
    updateDisplay();
}

// Check if two timestamps are from the same day
integer isSameDay(integer time1, integer time2) {
    // Convert to days since epoch
    integer day1 = time1 / 86400;
    integer day2 = time2 / 86400;
    
    return (day1 == day2);
}

default {
    state_entry() {
        // Initialize the artifact
        ownerID = llGetOwner();
        initialize();
        
        // Welcome message
        llOwnerSay("Sacred Orthodox Icon initialized: " + ARTIFACT_NAME + " (" + SAINT_NAME + ")");
    }
    
    touch_start(integer total_number) {
        key toucherID = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Show information dialog
        showArtifactInfo(toucherID);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Prayer channel
        if (channel == PRAYER_CHANNEL) {
            if (message == "Pray") {
                processPrayer(id, name);
            }
            else if (message == "Info") {
                showArtifactInfo(id);
            }
            // Check for resurrection request
            else if (llSubStringIndex(message, "Resurrect:") == 0) {
                // Extract target ID
                string targetIDStr = llGetSubString(message, 11, -1);
                key targetID = (key)targetIDStr;
                
                // Process resurrection
                processResurrection(id, targetID);
            }
        }
        
        // Resurrection channel
        else if (channel == RESURRECTION_CHANNEL) {
            // This is for communication between artifacts and HUDs
        }
    }
    
    timer() {
        // Check which timer action to perform
        if (nextTimerAction == 1) {
            // End prayer
            completePrayer();
        }
        else if (nextTimerAction == 2) {
            // Check decay
            checkPowerDecay();
        }
        
        // Stop timer only if no action needed
        if (!PRAYER_ACTIVE && PRAYER_POWER <= 0.0) {
            llSetTimerEvent(0.0);
            timerRunning = FALSE;
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_OWNER) {
            llResetScript();
        }
    }
}