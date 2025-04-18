// Imperial Ekaterina the Great Phantom NPC
// Special ghost-like NPC that appears and disappears
// Interacts exclusively with the Tsar and shares historical knowledge

// The Tsar's UUID - unique identifier for Tsar Nikolai II
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02";

// Phantom state tracking
integer isVisible = FALSE;
integer isTalking = FALSE;
integer currentHistoryIndex = 0;
integer lastMessageIndex = -1;

// Detection range for Tsar
float DETECTION_RANGE = 20.0;

// Alpha values
float INVISIBLE_ALPHA = 0.0;
float VISIBLE_ALPHA = 0.6;

// Glow parameters
vector GLOW_COLOR = <0.5, 1.0, 0.5>; // Soft green
float GLOW_ALPHA = 0.3;

// Movement parameters
float HOVER_HEIGHT = 0.5;
float MOVEMENT_RADIUS = 3.0;
float MOVEMENT_SPEED = 0.05;
vector startPosition;

// No animations needed for physical object

// Ekaterina's wisdom and stories
list historicalWisdom = [
    "The ruler who does not learn from history is destined to fail, my dear great-grandson.",
    "Art is not merely decoration, Nikolai. It is the soul of civilization, a reflection of our deepest truths.",
    "I expanded Russia by understanding our neighbors. Diplomacy first, force only when necessary.",
    "The Romanov legacy is built on both strength and enlightenment. Remember both aspects of your inheritance.",
    "Your wife's devotion to your son is admirable, but beware allowing mysticism to influence matters of state.",
    "When I invited the great philosophers of Europe to my court, it was not vanity but strategy. Knowledge is power.",
    "I see Russia's future reflected in its past. The people have always been our greatest strength and greatest challenge.",
    "Your grandfather Alexander II understood the need for reform. Sometimes change preserves more than it risks.",
    "I commissioned the Hermitage not for my pleasure alone, but to show the world Russia's cultural greatness.",
    "Listen to your ministers, but trust your own judgment. A sovereign must be decisive even when uncertain."
];

// Family histories to share
list familyHistories = [
    "Did you know your ancestor Peter transformed Russia through sheer force of will? He built this very city from swampland.",
    "Your grandmother, Maria Alexandrovna, possessed remarkable patience. You inherited her gentle temperament.",
    "Your great-uncle Constantine would have been Tsar if not for his morganatic marriage. Love and duty often conflict in our family.",
    "When I first came to Russia as Princess Sophie of Anhalt-Zerbst, I was merely fifteen. I reinvented myself entirely to become Russian.",
    "Your father Alexander III strengthened autocracy after his father's assassination. Fear guided him, but you need not follow the same path.",
    "The Romanov family has survived for three centuries through adaptation. Remember this when facing modern challenges.",
    "Your ancestor Nicholas I was called the Iron Tsar. His inflexibility became Russia's weakness in the Crimean War.",
    "I maintained correspondence with Voltaire and Diderot while expanding the empire. Military might and intellectual pursuit are not exclusive.",
    "Your cousin Wilhelm of Germany combines ambition with insecurity - a dangerous mixture in a ruler. Watch him carefully.",
    "The Romanov women have always been the quiet strength behind the throne. Treasure your daughters; they continue this legacy."
];

// Art knowledge to share
list artKnowledge = [
    "The Amber Room I commissioned was called the Eighth Wonder of the World. Protect such treasures; they embody Russia's soul.",
    "I acquired over 4,000 paintings during my reign. Art elevates the spirit of both ruler and nation.",
    "Russian iconography reflects our spiritual heritage. Modern art has its place, but never forget these sacred roots.",
    "The Winter Palace should not merely impress visitors but inspire Russians with a sense of their own greatness.",
    "I sponsored the Imperial Academy of Arts to nurture native talent. Russian artists need not imitate Europe but can lead it.",
    "The ballet you and Alexandra enjoy continues a tradition I established. Russian culture must be both preserved and advanced.",
    "Architecture reveals a nation's aspirations. St. Petersburg's grandeur speaks of Russia's European ambitions.",
    "The portraits of royalty serve not vanity but history. How we present ourselves becomes how history remembers us.",
    "I collected Rembrandt when few appreciated his genius. A ruler must recognize greatness before others do.",
    "The Imperial Fabergé eggs Alexandra treasures continue the tradition of royal patronage I established."
];

// Special appearance effects
applyPhantomEffects(integer visible)
{
    if(visible)
    {
        // Become visible with ethereal green glow
        // Use standard LSL functions with literal values
        llSetAlpha(VISIBLE_ALPHA, -1); // -1 for ALL_SIDES
        
        // Add glow effect using primitive parameters
        list params = [];
        params += [PRIM_GLOW, -1, GLOW_ALPHA]; // -1 for ALL_SIDES, PRIM_GLOW is a built-in constant
        llSetPrimitiveParams(params);
        
        // Apply ethereal texture effect using primitive parameters
        list animParams = [];
        animParams += [PRIM_COLOR, -1, GLOW_COLOR, VISIBLE_ALPHA]; // Set color with transparency
        llSetPrimitiveParams(animParams);
        
        // Set floating name text
        llSetText("Empress Ekaterina the Great", GLOW_COLOR, 1.0);
        
        // Add ghostly particle effect for appearance
        llParticleSystem([
            PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_PART_START_COLOR, GLOW_COLOR,
            PSYS_PART_END_COLOR, <0.5, 1.0, 0.5>,
            PSYS_PART_START_ALPHA, 0.8,
            PSYS_PART_END_ALPHA, 0.0,
            PSYS_PART_START_SCALE, <0.2, 0.2, 0>,
            PSYS_PART_END_SCALE, <1.0, 1.0, 0>,
            PSYS_PART_MAX_AGE, 5.0,
            PSYS_SRC_ACCEL, <0,0,0.1>,
            PSYS_SRC_BURST_RATE, 0.1,
            PSYS_SRC_BURST_PART_COUNT, 15,
            PSYS_SRC_MAX_AGE, 1.0,
            PSYS_SRC_BURST_RADIUS, 1.0,
            PSYS_SRC_BURST_SPEED_MIN, 0.1,
            PSYS_SRC_BURST_SPEED_MAX, 0.5,
            PSYS_SRC_ANGLE_BEGIN, 0.0,
            PSYS_SRC_ANGLE_END, PI
        ]);
    }
    else
    {
        // Become invisible
        llSetAlpha(INVISIBLE_ALPHA, -1); // -1 for ALL_SIDES
        
        // Remove glow
        list params = [];
        params += [PRIM_GLOW, -1, 0.0]; // -1 for ALL_SIDES
        llSetPrimitiveParams(params);
        
        // Reset color instead of using texture animation
        list colorParams = [];
        colorParams += [PRIM_COLOR, -1, <1.0, 1.0, 1.0>, 0.0]; // Reset to white but invisible
        llSetPrimitiveParams(colorParams);
        
        // Remove floating text
        llSetText("", <0,0,0>, 0.0);
        
        // Turn off particle system
        llParticleSystem([]);
    }
}

// Ethereal movement pattern
doPhantomMovement()
{
    if(!isVisible) return;
    
    // Create floating, swaying movement around the original position
    float time = llGetTime() * MOVEMENT_SPEED;
    
    vector newPos = startPosition;
    newPos.x += MOVEMENT_RADIUS * llSin(time);
    newPos.y += MOVEMENT_RADIUS * llCos(time * 0.7);
    newPos.z += startPosition.z + HOVER_HEIGHT + (0.3 * llSin(time * 0.5));
    
    llSetPos(newPos);
    
    // Subtle rotation
    llRotLookAt(
        llEuler2Rot(<0, 0, 15.0 * DEG_TO_RAD * llSin(time * 0.2)>), 
        0.2, 
        0.5
    );
}

// Select a random message that hasn't been used recently
string getRandomMessage(list messageList)
{
    integer listLength = llGetListLength(messageList);
    integer randomIndex;
    
    // Make sure we don't repeat the last message
    do {
        randomIndex = (integer)llFrand(listLength);
    } while(randomIndex == lastMessageIndex && listLength > 1);
    
    lastMessageIndex = randomIndex;
    return llList2String(messageList, randomIndex);
}

// Share wisdom or stories based on current context
shareWisdom(integer wisdomType)
{
    if(!isVisible) return;
    
    string message;
    
    // Select type of wisdom to share
    if(wisdomType == 0)
    {
        message = getRandomMessage(historicalWisdom);
    }
    else if(wisdomType == 1)
    {
        message = getRandomMessage(familyHistories);
    }
    else
    {
        message = getRandomMessage(artKnowledge);
    }
    
    // Add a special particle effect instead of animation
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_PART_START_COLOR, GLOW_COLOR,
        PSYS_PART_END_COLOR, <0.5, 1.0, 0.5>,
        PSYS_PART_START_ALPHA, 0.5,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.1, 0.1, 0>,
        PSYS_PART_END_SCALE, <0.3, 0.3, 0>,
        PSYS_PART_MAX_AGE, 3.0,
        PSYS_SRC_ACCEL, <0,0,0.3>,
        PSYS_SRC_BURST_RATE, 0.02,
        PSYS_SRC_BURST_PART_COUNT, 2,
        PSYS_SRC_MAX_AGE, 0.0,
        PSYS_SRC_BURST_RADIUS, 0.0,
        PSYS_SRC_BURST_SPEED_MIN, 0.05,
        PSYS_SRC_BURST_SPEED_MAX, 0.1,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI_BY_TWO
    ]);
    llSay(PUBLIC_CHANNEL, "*Ekaterina's spectral voice resonates* " + message);
    llSetTimerEvent(10.0); // Resume movement after speaking
}

default
{
    state_entry()
    {
        // Initialize phantom in invisible state
        isVisible = FALSE;
        applyPhantomEffects(isVisible);
        
        // Store initial position
        startPosition = llGetPos();
        
        // Set up listener for Tsar commands
        llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
        
        // Start sensor to detect Tsar proximity - 1 is AGENT flag
        llSensorRepeat("", NULL_KEY, 1, DETECTION_RANGE, PI, 5.0);
        
        // Set phantom physics status (allows avatars to walk through)
        llSetStatus(STATUS_PHANTOM, TRUE);
        
        // Start timer for movement when visible
        llSetTimerEvent(0.1);
    }
    
    // Listen for specific commands to appear/disappear
    listen(integer channel, string name, key id, string message)
    {
        if(channel == PUBLIC_CHANNEL)
        {
            // Listen for the Tsar's command to appear
            if(llSubStringIndex(llToLower(message), "romanova") != -1)
            {
                if(!isVisible)
                {
                    isVisible = TRUE;
                    applyPhantomEffects(isVisible);
                    llSay(PUBLIC_CHANNEL, "*A shimmer of green light appears as Empress Ekaterina's ghostly form materializes*");
                    llSay(PUBLIC_CHANNEL, "*Empress Ekaterina bows gracefully* I have returned to court, as you summoned me, my dear descendant.");
                }
            }
            // Listen for command to disappear
            else if(id == TSAR_UUID && llSubStringIndex(llToLower(message), "disappear ekaterina") != -1)
            {
                if(isVisible)
                {
                    llSay(PUBLIC_CHANNEL, "*Empress Ekaterina nods solemnly* As you wish, Your Imperial Majesty. Until you need my counsel again...");
                    llSleep(2.0);
                    // Special fade-out effect before disappearing
                    llParticleSystem([
                        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
                        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
                        PSYS_PART_START_COLOR, GLOW_COLOR,
                        PSYS_PART_END_COLOR, <0.1, 0.3, 0.1>,
                        PSYS_PART_START_ALPHA, 0.7,
                        PSYS_PART_END_ALPHA, 0.0,
                        PSYS_PART_START_SCALE, <0.5, 0.5, 0>,
                        PSYS_PART_END_SCALE, <0.1, 0.1, 0>,
                        PSYS_PART_MAX_AGE, 3.0,
                        PSYS_SRC_ACCEL, <0,0,-0.1>,
                        PSYS_SRC_BURST_RATE, 0.1,
                        PSYS_SRC_BURST_PART_COUNT, 30,
                        PSYS_SRC_MAX_AGE, 0.5,
                        PSYS_SRC_BURST_RADIUS, 0.7,
                        PSYS_SRC_BURST_SPEED_MIN, 0.05,
                        PSYS_SRC_BURST_SPEED_MAX, 0.2,
                        PSYS_SRC_ANGLE_BEGIN, 0.0,
                        PSYS_SRC_ANGLE_END, PI
                    ]);
                    llSleep(1.5); // Allow fade-out effect to be visible
                    
                    isVisible = FALSE;
                    applyPhantomEffects(isVisible);
                }
            }
            // Detect conversation about art
            else if(isVisible && llSubStringIndex(llToLower(message), "art") != -1)
            {
                shareWisdom(2); // Share art knowledge
            }
            // Detect conversation about family or history
            else if(isVisible && (llSubStringIndex(llToLower(message), "family") != -1 || 
                   llSubStringIndex(llToLower(message), "history") != -1 ||
                   llSubStringIndex(llToLower(message), "romanov") != -1))
            {
                shareWisdom(1); // Share family history
            }
        }
    }
    
    // Timer for ethereal movement and occasional wisdom
    timer()
    {
        if(isVisible)
        {
            // Create ethereal floating movement
            doPhantomMovement();
            
            // Occasionally share wisdom when not actively talking
            if(!isTalking && llFrand(1.0) < 0.01) // 1% chance per timer cycle
            {
                isTalking = TRUE;
                shareWisdom(0); // Share general historical wisdom
                llSetTimerEvent(10.0); // Pause between sharings
            }
            else
            {
                isTalking = FALSE;
            }
        }
    }
    
    // Detect when Tsar approaches
    sensor(integer num_detected)
    {
        if(!isVisible) return;
        
        integer i;
        for(i = 0; i < num_detected; i++)
        {
            key id = llDetectedKey(i);
            
            // If Tsar is detected and close
            if(id == TSAR_UUID)
            {
                // Calculate distance
                vector tsarPos = llDetectedPos(i);
                float distance = llVecDist(llGetPos(), tsarPos);
                
                // If Tsar is very close and we're not already talking
                if(distance < 5.0 && !isTalking && llFrand(1.0) < 0.3) // 30% chance when Tsar is close
                {
                    isTalking = TRUE;
                    
                    // Rotate to face the Tsar
                    llLookAt(tsarPos, 1.0, 1.0);
                    
                    // Share wisdom with the Tsar
                    integer wisdomType = (integer)llFrand(3.0); // Random wisdom type
                    shareWisdom(wisdomType);
                }
            }
        }
    }
    
    // Reset when touched
    touch_start(integer total_number)
    {
        key toucher = llDetectedKey(0);
        
        // Only the Tsar can interact directly with the phantom
        if(toucher == TSAR_UUID)
        {
            if(isVisible)
            {
                // Offer the Tsar options for interaction
                list options = ["Ask About Art", "Ask About History", "Ask About Family", "Disappear"];
                llDialog(TSAR_UUID, "What counsel do you seek from Empress Ekaterina?", options, PUBLIC_CHANNEL);
            }
            else
            {
                // If touched while invisible, briefly manifest to the Tsar only
                llSetAlpha(0.3, -1); // -1 for ALL_SIDES
                
                // Add temporary glow
                list params = [];
                params += [PRIM_GLOW, -1, 0.2]; // -1 for ALL_SIDES
                llSetPrimitiveParams(params);
                
                llSetText("Only you can see me, Your Majesty. Speak 'Romanova' to summon me fully.", GLOW_COLOR, 1.0);
                llSleep(5.0);
                
                // Return to invisible
                llSetAlpha(INVISIBLE_ALPHA, -1); // -1 for ALL_SIDES
                
                // Remove glow
                params = [];
                params += [PRIM_GLOW, -1, 0.0]; // -1 for ALL_SIDES
                llSetPrimitiveParams(params);
                
                llSetText("", <0,0,0>, 0.0);
            }
        }
    }
    
    // No animation permissions needed for physical object
    
    // Reset when ownership changes
    changed(integer change)
    {
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}