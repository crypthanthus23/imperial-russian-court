// Imperial Baba Yaga Mystic NPC
// A mystical woman who predicts the future, tells folk tales, and interacts with players
// Special behaviors: 
// - Recognizes Tsar Nikolai II and shows special deference
// - Blesses players who donate coins
// - Tells Russian folk tales and mystical prophecies
// - Has an aversion to Rasputin and warns against him
// - Interacts with nearby avatars through both detection and touch

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II's UUID
integer CHAT_CHANNEL = 0; // Public chat channel
integer COIN_CHANNEL = 734921; // Private channel for coin donations
float PI_BY_TWO = 1.57079633; // PI/2 value
float DEG_TO_RAD = 0.01745329; // Conversion from degrees to radians
// Using built-in TRUE and FALSE constants
// Using built-in STATUS_PHANTOM constant
// Using built-in LINK_THIS constant
// Using built-in CHANGED_OWNER constant

// Using built-in particle system constants

// Appearance parameters
vector MYSTIC_COLOR = <0.7, 0.0, 0.9>; // Deep purple for mystic aura
float GLOW_INTENSITY = 0.3; // Subtle mystical glow
float VISIBLE_ALPHA = 1.0; // Fully visible
float SMOKE_ALPHA = 0.7; // Alpha for smoke effects
float DETECTION_RANGE = 10.0; // Range to detect avatars

// Movement parameters
float HOVER_HEIGHT = 0.1; // Slight hovering
float MOVEMENT_RADIUS = 0.2; // Small radius of movement
float MOVEMENT_SPEED = 0.1; // Slow, deliberate movement

// Tracking variables
vector startPosition; // Original position
integer isSpeaking = FALSE; // Currently speaking to someone
integer lastTaleIndex = -1; // Track last tale to avoid repetition
integer lastProphecyIndex = -1; // Track last prophecy
integer lastGreetingIndex = -1; // Track last greeting
integer coinOffered = FALSE; // Whether a coin has been offered
key currentVisitor = NULL_KEY; // Avatar currently interacting with
integer dialogChannel; // Random channel for dialog menus
integer dialogHandle; // Handle for dialog listener

// Player interaction tracking
list recentVisitors = []; // List of recent visitors (to avoid repetitive greetings)
list blessedAvatars = []; // List of avatars who have received blessings
list coinDonors = []; // List of avatars who have donated coins

// Russian folk tales
list folkTales = [
    "Long ago, in a frozen forest, there lived a firebird whose feathers glowed like the embers of a dying sun. A single feather could light an entire palace for a year.",
    "The great hero Ilya Muromets sat paralyzed for thirty-three years before receiving the strength to defend Holy Russia from its enemies.",
    "Koschei the Deathless hid his soul inside a needle, inside an egg, inside a duck, inside a hare, inside an iron chest, buried under an oak tree on the island of Buyan.",
    "The Firebird was a magical glowing bird from a faraway land, whose feathers shined like gold and eyes sparkled like jewels. To catch it meant both fortune and peril.",
    "Vasilisa the Beautiful was given a magical doll by her dying mother. The doll helped her complete impossible tasks given by myself, Baba Yaga!",
    "The fool Ivan captured the Firebird by using golden apples as bait, despite being warned of the danger. Sometimes, the simple-minded achieve what the clever cannot.",
    "A soldier shared his last bread with a beggar, not knowing it was a saint in disguise. For his kindness, he was granted a magical bag that could trap anything inside.",
    "The Grey Wolf served Prince Ivan after he spared its life, teaching that mercy creates unexpected allies. Remember this in the court's deadly games.",
    "Sadko played his gusli so beautifully that the Sea King himself rose from the depths to listen, showing that art can move even the most powerful forces.",
    "The Frog Princess was actually an enchanted maiden of incredible beauty and wisdom, proving that appearances can be the most deceiving magic of all."
];

// Prophecies about Russia's future
list prophecies = [
    "I see the eagle's feathers burning... the Romanov nest shall face a great fire. Protect your children, for they are Russia's future.",
    "Beware the holy man who is not holy. His whispers are poison to the tsarina's ear, and his presence casts a shadow over the succession.",
    "A great war approaches from the West. Blood will flow like rivers, and crowns will fall like autumn leaves. Hold tight to what you love.",
    "The people's hunger grows with each winter. When bread becomes more precious than gold, the walls of the palace will no longer protect.",
    "I see a time of red banners and angry voices. The old ways will be swept away like snow before a spring wind. Change is coming, whether welcomed or not.",
    "Trust not the German whispers, nor the English promises. Russia must find its own path between East and West, or be torn apart.",
    "Three hundred years of Romanov rule hangs by a silken thread. Only humility before the people's needs may yet preserve it.",
    "Five lives tied together, like fingers on a hand. Their fate is the fate of Russia itself. Guard them well.",
    "The heir's health conceals a deeper ill affecting all of Russia. What weakens the son weakens the empire.",
    "A revolution comes not from the peasants' hands but from within the educated classes who have lost faith. Rebuild this faith, or all is lost."
];

// Blessings to give when coins are offered
list blessings = [
    "May your children grow strong and your fields stay fertile. The spirits smile upon your generosity!",
    "I bless your household with protection from evil eyes and jealous hearts. No curse shall cross your threshold!",
    "May your enemies' words turn to dust before they reach your ears, and your friends' loyalty remain firm as the ancient oaks!",
    "The water spirits shall guard you when you cross rivers, and the forest guardians shall guide you when you travel through the woods!",
    "I bestow upon you the favor of your ancestors. They will watch over you in times of darkness!",
    "May your dreams be prophetic and your intuition sharp. The veil between worlds thins for those who show kindness to old Baba Yaga!",
    "Your generosity brings fortune! May your pockets never empty and your table never lack for bread!",
    "I bless you with the cunning of the fox and the courage of the bear. Both wisdom and strength shall be yours when needed!",
    "The stars themselves shall rearrange to favor your endeavors. Fortune smiles upon the generous heart!",
    "By the power of ancient Russia, I bind good fortune to you for a full turning of the seasons! Return when the year is complete for another blessing!"
];

// Greetings for regular visitors
list greetings = [
    "Ah, a visitor to Baba Yaga's domain! Come closer, child, let me see your future...",
    "The bones have been speaking of your arrival. What brings you to this old woman's hut?",
    "I smell the scent of Russian blood! But fear not, I mean no harm to those who show respect.",
    "The forest whispered you would come today. Fate has brought you to my door for a reason.",
    "Another soul seeking wisdom from old Baba Yaga? Or perhaps you're lost in the forest of life?",
    "Step carefully around my hut, dear one. It doesn't take kindly to disrespectful guests!",
    "Has the wind blown you to my door, or have you come seeking Baba Yaga's wisdom?",
    "Few find my dwelling by accident. The spirits must have guided you here for a purpose.",
    "Ahh, I've been waiting for you, though you didn't know you were coming! Such is the way of fate.",
    "Welcome, seeker. Have you brought an offering for old Baba Yaga, or merely your curiosity?"
];

// Special greetings for the Tsar
list tsarGreetings = [
    "Your Imperial Majesty! Baba Yaga is honored by your royal presence. The ancient spirits of Russia bow before you!",
    "The Tsar himself visits humble Baba Yaga! The forests and rivers of Holy Russia rejoice at your approach, Gosudar!",
    "Ah, the Little Father of all Russians comes to consult with old Baba Yaga! Your ancestors smile from beyond the veil!",
    "Your Majesty! The crown of Monomakh sits heavy, does it not? Baba Yaga sees the burden you carry for Holy Russia.",
    "The descendent of Peter and Catherine! Your Imperial blood shines like a beacon through the mists of time!"
];

// Warnings about Rasputin
list rasputinWarnings = [
    "Beware the dark monk who calls himself holy! His eyes hold not God's light but the endless hunger of wolves!",
    "The tsarina's ear is poisoned by the Siberian devil. His prayers bring not healing but greater ill to Russia!",
    "That so-called holy man twists faith to serve his base desires. The stench of his corruption reaches even my forest!",
    "Rasputin's influence grows like a cancer at court. Cut it out before it reaches Russia's heart!",
    "The 'healer' is the greatest disease! His miracles are mere tricks that any village witch could perform!"
];

// Initialize the dialog listener
setupDialog()
{
    // Close any existing listeners
    llListenRemove(dialogHandle);
    
    // Create a random channel for dialog
    dialogChannel = -1 - (integer)llFrand(1000000.0);
    
    // Set up the listener
    dialogHandle = llListen(dialogChannel, "", NULL_KEY, "");
}

// Add mystical smoke and aura effects around Baba Yaga
applyMysticEffects()
{
    // Set a subtle glow
    list params = [];
    params += [PRIM_GLOW, -1, GLOW_INTENSITY]; // Apply to all sides
    llSetPrimitiveParams(params);
    
    // Add mystic color overlay
    list colorParams = [];
    colorParams += [PRIM_COLOR, -1, MYSTIC_COLOR, VISIBLE_ALPHA]; // Visible with mystic hue
    llSetPrimitiveParams(colorParams);
    
    // Set floating text
    llSetText("Baba Yaga", MYSTIC_COLOR, 1.0);
    
    // Add mystical particle effects (smoke and aura)
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE,
        PSYS_PART_START_COLOR, MYSTIC_COLOR,
        PSYS_PART_END_COLOR, <0.3, 0.0, 0.5>,
        PSYS_PART_START_ALPHA, SMOKE_ALPHA,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>,
        PSYS_PART_END_SCALE, <0.5, 0.5, 0.0>,
        PSYS_PART_MAX_AGE, 5.0,
        PSYS_SRC_ACCEL, <0.0, 0.0, 0.02>,
        PSYS_SRC_BURST_RATE, 0.05,
        PSYS_SRC_BURST_PART_COUNT, 1,
        PSYS_SRC_MAX_AGE, 0.0,
        PSYS_SRC_BURST_RADIUS, 0.2,
        PSYS_SRC_BURST_SPEED_MIN, 0.01,
        PSYS_SRC_BURST_SPEED_MAX, 0.05,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI
    ]);
}

// Create subtle swaying movement for Baba Yaga
doMysticMovement()
{
    // Only move if speaking to someone
    if(!isSpeaking) return;
    
    // Create slow, deliberate movement around original position
    float time = llGetTime() * MOVEMENT_SPEED;
    
    vector newPos = startPosition;
    newPos.x += MOVEMENT_RADIUS * llSin(time * 0.5);
    newPos.y += MOVEMENT_RADIUS * llCos(time * 0.3);
    newPos.z += startPosition.z + HOVER_HEIGHT + (0.05 * llSin(time * 0.8));
    
    llSetPos(newPos);
    
    // Create subtle, mystical rotation
    llRotLookAt(
        llEuler2Rot(<0, 0, 10.0 * DEG_TO_RAD * llSin(time * 0.1)>), 
        0.3, 
        0.7
    );
}

// Select a random message from a list, avoiding recent repeats
string getRandomMessage(list messageList, integer &lastIndex)
{
    integer listLength = llGetListLength(messageList);
    integer randomIndex;
    
    // Make sure we don't repeat the last message
    do {
        randomIndex = (integer)llFrand(listLength);
    } while(randomIndex == lastIndex && listLength > 1);
    
    lastIndex = randomIndex;
    return llList2String(messageList, randomIndex);
}

// Tell a folk tale
tellFolkTale()
{
    // Add a storytelling particle effect
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_PART_START_COLOR, <0.8, 0.6, 1.0>,
        PSYS_PART_END_COLOR, <0.4, 0.0, 0.8>,
        PSYS_PART_START_ALPHA, 0.5,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
        PSYS_PART_END_SCALE, <0.2, 0.2, 0.0>,
        PSYS_PART_MAX_AGE, 4.0,
        PSYS_SRC_ACCEL, <0.0, 0.0, 0.1>,
        PSYS_SRC_BURST_RATE, 0.02,
        PSYS_SRC_BURST_PART_COUNT, 1,
        PSYS_SRC_MAX_AGE, 0.0,
        PSYS_SRC_BURST_RADIUS, 0.1,
        PSYS_SRC_BURST_SPEED_MIN, 0.05,
        PSYS_SRC_BURST_SPEED_MAX, 0.1,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI_BY_TWO
    ]);
    
    string tale = getRandomMessage(folkTales, lastTaleIndex);
    llSay(CHAT_CHANNEL, "*Baba Yaga's eyes take on a distant look as she begins her tale* " + tale);
}

// Make a prophecy about the future
tellProphecy()
{
    // Add an ominous prophetic particle effect
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR, <1.0, 0.3, 1.0>,
        PSYS_PART_END_COLOR, <0.2, 0.0, 0.5>,
        PSYS_PART_START_ALPHA, 0.8,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.3, 0.3, 0.0>,
        PSYS_PART_END_SCALE, <0.1, 0.1, 0.0>,
        PSYS_PART_MAX_AGE, 5.0,
        PSYS_SRC_ACCEL, <0.0, 0.0, -0.05>,
        PSYS_SRC_BURST_RATE, 0.1,
        PSYS_SRC_BURST_PART_COUNT, 10,
        PSYS_SRC_MAX_AGE, 0.5,
        PSYS_SRC_BURST_RADIUS, 0.5,
        PSYS_SRC_BURST_SPEED_MIN, 0.05,
        PSYS_SRC_BURST_SPEED_MAX, 0.2,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI
    ]);
    
    string prophecy = getRandomMessage(prophecies, lastProphecyIndex);
    llSay(CHAT_CHANNEL, "*Baba Yaga's voice deepens, her eyes roll back showing only whites* " + prophecy);
}

// Give a mystical blessing after receiving a coin
giveBlessingForCoin(key avatarKey)
{
    // Add a blessing particle effect
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK | PSYS_PART_FOLLOW_SRC_MASK | PSYS_PART_TARGET_POS_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_PART_START_COLOR, <1.0, 0.8, 1.0>,
        PSYS_PART_END_COLOR, <0.7, 0.4, 1.0>,
        PSYS_PART_START_ALPHA, 0.6,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>,
        PSYS_PART_END_SCALE, <0.5, 0.5, 0.0>,
        PSYS_PART_MAX_AGE, 5.0,
        PSYS_SRC_ACCEL, <0.0, 0.0, 0.1>,
        PSYS_SRC_BURST_RATE, 0.02,
        PSYS_SRC_BURST_PART_COUNT, 3,
        PSYS_SRC_MAX_AGE, 3.0,
        PSYS_SRC_BURST_RADIUS, 0.0,
        PSYS_SRC_BURST_SPEED_MIN, 0.1,
        PSYS_SRC_BURST_SPEED_MAX, 0.3,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI_BY_TWO,
        PSYS_SRC_TARGET_KEY, avatarKey
    ]);
    
    string blessing = getRandomMessage(blessings, lastGreetingIndex);
    llSay(CHAT_CHANNEL, "*Baba Yaga's gnarled hands move in intricate patterns over your head* " + blessing);
    
    // Add the avatar to the blessed list if not already there
    if(llListFindList(blessedAvatars, [avatarKey]) == -1)
    {
        blessedAvatars += avatarKey;
        // Keep list from growing too large
        if(llGetListLength(blessedAvatars) > 20)
        {
            blessedAvatars = llDeleteSubList(blessedAvatars, 0, 0);
        }
    }
    
    // Add to coin donors list
    if(llListFindList(coinDonors, [avatarKey]) == -1)
    {
        coinDonors += avatarKey;
        // Keep list from growing too large
        if(llGetListLength(coinDonors) > 20)
        {
            coinDonors = llDeleteSubList(coinDonors, 0, 0);
        }
    }
}

// Warn about Rasputin
warnAboutRasputin()
{
    // Add an angry red warning particle effect
    llParticleSystem([
        PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR, <1.0, 0.0, 0.0>,
        PSYS_PART_END_COLOR, <0.5, 0.0, 0.0>,
        PSYS_PART_START_ALPHA, 0.7,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>,
        PSYS_PART_END_SCALE, <0.4, 0.4, 0.0>,
        PSYS_PART_MAX_AGE, 3.0,
        PSYS_SRC_ACCEL, <0.0, 0.0, 0.0>,
        PSYS_SRC_BURST_RATE, 0.1,
        PSYS_SRC_BURST_PART_COUNT, 5,
        PSYS_SRC_MAX_AGE, 0.5,
        PSYS_SRC_BURST_RADIUS, 0.4,
        PSYS_SRC_BURST_SPEED_MIN, 0.1,
        PSYS_SRC_BURST_SPEED_MAX, 0.3,
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, PI
    ]);
    
    integer index = (integer)llFrand(llGetListLength(rasputinWarnings));
    string warning = llList2String(rasputinWarnings, index);
    llSay(CHAT_CHANNEL, "*Baba Yaga spits on the ground, her face contorting in disgust* " + warning);
}

// Greet a visitor appropriately
greetVisitor(key avatarKey)
{
    string avatarName = llKey2Name(avatarKey);
    
    // Check if this is the Tsar
    if(avatarKey == TSAR_UUID)
    {
        string tsarGreeting = getRandomMessage(tsarGreetings, lastGreetingIndex);
        llSay(CHAT_CHANNEL, "*Baba Yaga bows deeply* " + tsarGreeting);
        return;
    }
    
    // Check if this avatar has visited recently
    if(llListFindList(recentVisitors, [avatarKey]) == -1)
    {
        // New visitor, add to list and greet
        recentVisitors += avatarKey;
        // Keep list from growing too large
        if(llGetListLength(recentVisitors) > 10)
        {
            recentVisitors = llDeleteSubList(recentVisitors, 0, 0);
        }
        
        string greeting = getRandomMessage(greetings, lastGreetingIndex);
        llSay(CHAT_CHANNEL, "*Baba Yaga peers at you with ancient eyes* " + greeting);
    }
}

// Present interaction options to the visitor
offerInteractionOptions(key avatarKey)
{
    // Set the current visitor
    currentVisitor = avatarKey;
    
    // Prepare the dialog options based on who's visiting
    list options = ["Hear a Folk Tale", "Request Prophecy", "Ask About Rasputin"];
    
    // Add option to donate a coin
    options += ["Offer Coin for Blessing"];
    
    // Special options for the Tsar
    if(avatarKey == TSAR_UUID)
    {
        options += ["Royal Counsel"];
    }
    
    // Always add a goodbye option
    options += ["Goodbye"];
    
    // Present the dialog menu
    llDialog(avatarKey, "What would you ask of Baba Yaga, the ancient mystic of Russia?", options, dialogChannel);
}

default
{
    state_entry()
    {
        // Initialize
        startPosition = llGetPos();
        
        // Apply mystic appearance effects
        applyMysticEffects();
        
        // Set phantom physics (can be walked through)
        llSetStatus(STATUS_PHANTOM, TRUE);
        
        // Set up dialog listener
        setupDialog();
        
        // Set up listeners for coin donations
        llListen(COIN_CHANNEL, "", NULL_KEY, "COIN_DONATED");
        llListen(CHAT_CHANNEL, "", NULL_KEY, "");
        
        // Detect avatars nearby
        llSensorRepeat("", NULL_KEY, AGENT_BY_LEGACY_NAME, DETECTION_RANGE, PI, 10.0);
        
        // Start movement timer
        llSetTimerEvent(0.1);
    }
    
    // Handle avatar detection
    sensor(integer num_detected)
    {
        // Only initiate interaction if not already speaking
        if(isSpeaking) return;
        
        // Look for nearby avatars
        integer i;
        for(i = 0; i < num_detected; i++)
        {
            key id = llDetectedKey(i);
            
            // Special priority for the Tsar
            if(id == TSAR_UUID)
            {
                // Calculate distance
                vector tsarPos = llDetectedPos(i);
                float distance = llVecDist(llGetPos(), tsarPos);
                
                // If Tsar is very close, greet immediately
                if(distance < 5.0 && !isSpeaking)
                {
                    // Face the Tsar
                    llLookAt(tsarPos, 1.0, 1.0);
                    
                    // Start interaction
                    isSpeaking = TRUE;
                    greetVisitor(TSAR_UUID);
                    llSleep(2.0);
                    offerInteractionOptions(TSAR_UUID);
                    return; // Exit after acknowledging Tsar
                }
            }
            else
            {
                // For regular avatars, only react occasionally when they are very close
                vector avatarPos = llDetectedPos(i);
                float distance = llVecDist(llGetPos(), avatarPos);
                
                if(distance < 3.0 && llFrand(1.0) < 0.3) // 30% chance when close
                {
                    // Face the visitor
                    llLookAt(avatarPos, 1.0, 1.0);
                    
                    // Only initiate if they're not on the recent visitor list
                    if(llListFindList(recentVisitors, [id]) == -1)
                    {
                        isSpeaking = TRUE;
                        greetVisitor(id);
                        // Don't immediately offer options, wait for them to touch/interact
                        return;
                    }
                }
            }
        }
    }
    
    // Handle touch events
    touch_start(integer total_number)
    {
        key toucher = llDetectedKey(0);
        
        // Set as speaking to avoid multiple simultaneous interactions
        isSpeaking = TRUE;
        
        // Greet the toucher appropriately if not already interacting
        if(currentVisitor == NULL_KEY)
        {
            greetVisitor(toucher);
            llSleep(1.0);
        }
        
        // Offer interaction options
        offerInteractionOptions(toucher);
    }
    
    // Handle dialog selections and chat
    listen(integer channel, string name, key id, string message)
    {
        // Handle dialog menu selections
        if(channel == dialogChannel && id == currentVisitor)
        {
            // Process option selected
            if(message == "Hear a Folk Tale")
            {
                tellFolkTale();
                llSleep(3.0);
                
                // Offer more options after a delay
                llSetTimerEvent(10.0); // Resume normal movement after delay
            }
            else if(message == "Request Prophecy")
            {
                tellProphecy();
                llSleep(3.0);
                
                // Offer more options after a delay
                llSetTimerEvent(10.0); // Resume normal movement after delay
            }
            else if(message == "Ask About Rasputin")
            {
                warnAboutRasputin();
                llSleep(3.0);
                
                // Offer more options after a delay
                llSetTimerEvent(10.0); // Resume normal movement after delay
            }
            else if(message == "Offer Coin for Blessing")
            {
                // Tell them how to donate a coin
                llSay(CHAT_CHANNEL, "*Baba Yaga's eyes glint with interest* Yes, yes! Place a coin in my bowl, and I shall bestow a powerful blessing upon you. The ancient spirits favor those who show generosity to old Baba Yaga!");
                
                // Set the coin offered flag (this would connect to coin payment script)
                coinOffered = TRUE;
                
                // Simulate coin donation for testing (in real use, this would come from a separate payment script)
                // For testing, we'll use a timer to simulate the coin being donated
                llSetTimerEvent(5.0);
            }
            else if(message == "Royal Counsel" && id == TSAR_UUID)
            {
                // Special advice for the Tsar
                llSay(CHAT_CHANNEL, "*Baba Yaga lowers her voice to a whisper, meant only for royal ears* Your Imperial Majesty, the ancient spirits of Russia have protected the Romanov line for centuries. Keep the tsarevich close, trust your own heart above foreign advisers, and remember that Russia's soul lives not in palaces but in the soil and the people who work it. The coming years will test your resolve like iron in fire.");
                
                // Special particle effect for royal counsel
                llParticleSystem([
                    PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK,
                    PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE,
                    PSYS_PART_START_COLOR, <1.0, 0.8, 0.0>, // Golden for royalty
                    PSYS_PART_END_COLOR, <0.5, 0.3, 0.0>,
                    PSYS_PART_START_ALPHA, 0.6,
                    PSYS_PART_END_ALPHA, 0.0,
                    PSYS_PART_START_SCALE, <0.2, 0.2, 0.0>,
                    PSYS_PART_END_SCALE, <0.4, 0.4, 0.0>,
                    PSYS_PART_MAX_AGE, 4.0,
                    PSYS_SRC_ACCEL, <0.0, 0.0, 0.05>,
                    PSYS_SRC_BURST_RATE, 0.05,
                    PSYS_SRC_BURST_PART_COUNT, 2,
                    PSYS_SRC_MAX_AGE, 2.0,
                    PSYS_SRC_BURST_RADIUS, 0.3,
                    PSYS_SRC_BURST_SPEED_MIN, 0.05,
                    PSYS_SRC_BURST_SPEED_MAX, 0.1,
                    PSYS_SRC_ANGLE_BEGIN, 0.0,
                    PSYS_SRC_ANGLE_END, PI_BY_TWO
                ]);
                
                llSleep(5.0);
                
                // Offer more options after a delay
                llSetTimerEvent(10.0); // Resume normal movement after delay
            }
            else if(message == "Goodbye")
            {
                // Say farewell
                llSay(CHAT_CHANNEL, "*Baba Yaga nods slowly* Go with the protection of the old ways, until our paths cross again. Remember what Baba Yaga has told you...");
                
                // End the interaction
                isSpeaking = FALSE;
                currentVisitor = NULL_KEY;
                coinOffered = FALSE;
                
                // Turn off particles
                llParticleSystem([]);
                // Reapply standard mystic effects
                applyMysticEffects();
            }
            
            // If the option wasn't "Goodbye", we're still in conversation
            if(message != "Goodbye")
            {
                llSleep(8.0); // Give time to read the response
                offerInteractionOptions(currentVisitor); // Offer options again
            }
        }
        // Handle coin donations (in a real implementation, this would come from a payment script)
        else if(channel == COIN_CHANNEL && message == "COIN_DONATED")
        {
            if(coinOffered && currentVisitor != NULL_KEY)
            {
                giveBlessingForCoin(currentVisitor);
                coinOffered = FALSE;
                llSleep(3.0);
                
                // Offer more options after the blessing
                offerInteractionOptions(currentVisitor);
            }
        }
        // Listen for mentions of Rasputin or the Tsar in public chat
        else if(channel == CHAT_CHANNEL)
        {
            // Respond to mentions of Rasputin
            if(llSubStringIndex(llToLower(message), "rasputin") != -1 && !isSpeaking)
            {
                // Random chance to react to Rasputin mentions
                if(llFrand(1.0) < 0.7) // 70% chance to respond
                {
                    isSpeaking = TRUE;
                    warnAboutRasputin();
                    llSleep(3.0);
                    isSpeaking = FALSE;
                }
            }
            
            // Respond to mentions of the Tsar
            if((llSubStringIndex(llToLower(message), "tsar") != -1 || 
                llSubStringIndex(llToLower(message), "nicholas") != -1 ||
                llSubStringIndex(llToLower(message), "nikolai") != -1) && 
               !isSpeaking)
            {
                // Random chance to react to Tsar mentions
                if(llFrand(1.0) < 0.5) // 50% chance to respond
                {
                    isSpeaking = TRUE;
                    llSay(CHAT_CHANNEL, "*Baba Yaga bows her head respectfully* The Tsar is guided by the ancient spirits of Russia. His bloodline carries the destiny of our great motherland.");
                    llSleep(2.0);
                    isSpeaking = FALSE;
                }
            }
        }
    }
    
    // Timer for movement and simulated coin donation
    timer()
    {
        // Handle ethereal movement if speaking
        if(isSpeaking)
        {
            doMysticMovement();
        }
        
        // For testing, simulate a coin donation if one has been offered
        if(coinOffered && currentVisitor != NULL_KEY)
        {
            // Simulate the coin being donated
            llMessageLinked(LINK_THIS, COIN_CHANNEL, "COIN_DONATED", NULL_KEY);
            llSleep(0.5);
            giveBlessingForCoin(currentVisitor);
            coinOffered = FALSE;
            
            // Resume interaction
            llSleep(3.0);
            offerInteractionOptions(currentVisitor);
        }
        
        // If no longer in conversation, reset speaking state
        if(!isSpeaking && currentVisitor != NULL_KEY)
        {
            currentVisitor = NULL_KEY;
            llParticleSystem([]); // Turn off special particles
            applyMysticEffects(); // Return to default mystic effects
        }
    }
    
    // Handle ownership changes
    changed(integer change)
    {
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}