// Imperial Russian Court Roleplay System
// Script: Imperial Courtier NPC Tsar Recognition
// Version: 1.0
// Description: NPC courtier that recognizes imperial family and follows court protocols

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei
key TSARINA_UUID = NULL_KEY; // Placeholder for Tsarina Alexandra

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer COURTIER_CHANNEL = -8675328; // Specific channel for courtier interactions

// Courtier types
integer TYPE_DIPLOMAT = 0;      // Foreign diplomat
integer TYPE_NOBLE = 1;         // Russian noble
integer TYPE_MILITARY = 2;      // Military officer
integer TYPE_CLERGY = 3;        // Orthodox clergy
integer TYPE_SERVANT = 4;       // Palace servant

// Courtier rank levels
integer RANK_LOW = 0;           // Low-ranking
integer RANK_MEDIUM = 1;        // Mid-ranking
integer RANK_HIGH = 2;          // High-ranking

// Courtier states
integer STATE_IDLE = 0;         // Default idle state
integer STATE_GREETING = 1;     // Greeting someone
integer STATE_BOWING = 2;       // Bowing to royalty
integer STATE_CONVERSING = 3;   // In conversation
integer STATE_FOLLOWING = 4;    // Following someone

// Status variables
integer currentType = TYPE_NOBLE;
integer currentRank = RANK_MEDIUM;
string courtierName = "Count Orlov";
string courtierTitle = "Count";
string courtierRole = "Court Chamberlain";
integer currentState = STATE_IDLE;
key interactingWith = NULL_KEY;     // Who NPC is currently interacting with
integer listenHandle;               // Handle for the listen event
integer scanTimer = 5;              // Seconds between proximity scans

// Animation names
string ANIM_IDLE = "courtier_idle";
string ANIM_BOW = "courtier_bow";
string ANIM_CURTSY = "courtier_curtsy";
string ANIM_CONVERSE = "courtier_talk";
string ANIM_FOLLOW = "courtier_walk";

// Conversation variables
list greetings = [];                // Standard greetings
list royalGreetings = [];           // Greetings for royalty
list conversationTopics = [];       // Potential discussion topics
list gossip = [];                   // Court gossip

// Protocol variables
integer protocolLevel = 2;          // How strictly protocol is followed (1-3)
list royalTitles = [];              // Proper royal titles
list courtRules = [];               // Court etiquette rules
list recentVisitors = [];           // Recent visitors to the court

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

// Function to initialize courtier phrases
initializeCourtierPhrases() {
    // Initialize standard greetings
    greetings = [
        "Good day to you.",
        "I bid you welcome to the Imperial Court.",
        "How do you do?",
        "It is a pleasure to make your acquaintance.",
        "Welcome to the Winter Palace.",
        "I trust you are enjoying the court festivities?",
        "A fine day for court business, is it not?",
        "I don't believe we've been formally introduced."
    ];
    
    // Initialize royal greetings
    royalGreetings = [
        "Your Imperial Majesty, I am honored by your presence.",
        "Your Imperial Highness, how may I be of service?",
        "I am humbled to stand in your imperial presence.",
        "God save Your Majesty! How may I serve the crown today?",
        "Your Imperial Majesty, the court brightens at your arrival.",
        "I am but a loyal servant to Your Imperial Highness.",
        "May I have the honor of assisting Your Imperial Majesty today?",
        "Your Imperial Majesty's health is the concern of all loyal Russians."
    ];
    
    // Initialize conversation topics
    conversationTopics = [
        "The latest diplomatic dispatches from Paris are most intriguing.",
        "I attended the ballet at the Mariinsky last evening. Magnificent performance.",
        "The winter season promises to be exceptionally grand this year.",
        "Have you heard about the proposed expansion of the Trans-Siberian Railway?",
        "The new military reforms are the talk of certain circles.",
        "Court fashions this season show a distinct Parisian influence.",
        "The recent exhibition of French impressionists has caused quite a stir.",
        "I understand the Imperial yacht will be sailing to Crimea next month.",
        "The Grand Duchess's charity ball was a tremendous success.",
        "They say the German ambassador seeks a private audience with the Tsar."
    ];
    
    // Initialize court gossip
    gossip = [
        "They say Count Yusupov has been spending an unusual amount of time with the French ambassador's wife.",
        "I've heard the Minister of Finance has been purchasing large estates in Finland. Most curious.",
        "The Grand Duke Sergei was notably absent from the Empress's salon last week.",
        "Princess Dashkova's new jewels have raised more than a few eyebrows.",
        "The British military attaché was overheard making concerning remarks about the Baltic Fleet.",
        "General Kornilov's promotion has caused quite a stir among the staff officers.",
        "The Tsar's decision regarding the Japanese situation is awaited with great anxiety.",
        "The Metropolitan of St. Petersburg was in deep conversation with Rasputin after the service.",
        "Baron Fredericks seems to have fallen from favor - his invitations have become scarce.",
        "The American industrialist made a most improper suggestion during the diplomatic reception."
    ];
    
    // Initialize royal titles
    royalTitles = [
        "His Imperial Majesty, Tsar Nikolai II, Emperor and Autocrat of All the Russias",
        "Her Imperial Majesty, Tsarina Alexandra Feodorovna, Empress of All the Russias",
        "His Imperial Highness, Tsarevich Alexei Nikolaevich, Heir to the Russian Throne",
        "Her Imperial Highness, Grand Duchess Olga Nikolaevna",
        "Her Imperial Highness, Grand Duchess Tatiana Nikolaevna",
        "Her Imperial Highness, Grand Duchess Maria Nikolaevna",
        "Her Imperial Highness, Grand Duchess Anastasia Nikolaevna",
        "Her Imperial Majesty, Dowager Empress Maria Feodorovna"
    ];
    
    // Initialize court rules
    courtRules = [
        "One must never turn one's back to the Tsar or Tsarina.",
        "Ladies must curtsy and gentlemen must bow when the Imperial family enters.",
        "No one may sit in the presence of the Tsar unless invited to do so.",
        "One must address the Tsar as 'Your Imperial Majesty' upon first greeting.",
        "The Tsar must be served first at all ceremonial meals.",
        "No one may leave a room before the Imperial family has departed.",
        "Proper court dress is required for all formal functions.",
        "One must request permission before approaching the Imperial family directly.",
        "Court presentations must be arranged through the Master of Ceremonies.",
        "Conversations cease when the Tsar or Tsarina wishes to speak."
    ];
}

// Function to recognize a royal person and react appropriately
recognizeRoyalty(key avatarKey, string avatarName, float distance) {
    // Only react if NPC is in idle state
    if (currentState != STATE_IDLE) {
        return;
    }
    
    // Response depends on who it is and their proximity
    if (distance <= 10.0) { // Close proximity
        // Set interacting state
        currentState = STATE_BOWING;
        interactingWith = avatarKey;
        
        // Determine appropriate greeting
        string greeting = "";
        string title = "";
        
        if (isTsar(avatarKey)) {
            title = "His Imperial Majesty, Tsar";
            greeting = "Your Imperial Majesty, " + courtierTitle + " " + courtierName + " at your service. May God bless and keep the Tsar of All the Russias.";
            
            // Play bow animation
            // Would use llStartAnimation(ANIM_BOW) in a real implementation
            
            // Public announcement of Tsar's presence
            llSay(0, courtierTitle + " " + courtierName + " bows deeply as " + title + " " + avatarName + " approaches.");
        }
        else if (isTsarina(avatarKey)) {
            title = "Her Imperial Majesty, Tsarina";
            greeting = "Your Imperial Majesty, " + courtierTitle + " " + courtierName + " at your service. God save the Empress of All the Russias.";
            
            // Play bow/curtsy animation based on courtier gender
            
            // Public announcement of Tsarina's presence
            llSay(0, courtierTitle + " " + courtierName + " bows deeply as " + title + " " + avatarName + " approaches.");
        }
        else if (isZarevich(avatarKey)) {
            title = "His Imperial Highness, Tsarevich";
            greeting = "Your Imperial Highness, " + courtierTitle + " " + courtierName + " at your service. God bless the Heir to the Throne.";
            
            // Play bow animation
            
            // Public announcement of Zarevich's presence
            llSay(0, courtierTitle + " " + courtierName + " bows as " + title + " " + avatarName + " approaches.");
        }
        else if (isImperialFamily(avatarKey)) {
            title = "His/Her Imperial Highness";
            greeting = "Your Imperial Highness, " + courtierTitle + " " + courtierName + " at your service.";
            
            // Play bow/curtsy animation
            
            // Lower-key announcement for other family members
            llSay(0, courtierTitle + " " + courtierName + " bows respectfully to " + title + " " + avatarName + ".");
        }
        
        // Deliver personal greeting to royal
        llRegionSayTo(avatarKey, 0, greeting);
        
        // Stand ready for orders
        llSetTimerEvent(10.0); // Return to idle after a delay if no interaction
    }
    else { // Royalty is at a distance but visible
        // More subdued recognition
        string notification = "";
        
        if (isTsar(avatarKey)) {
            notification = "His Imperial Majesty the Tsar is present in the vicinity.";
        }
        else if (isTsarina(avatarKey)) {
            notification = "Her Imperial Majesty the Tsarina graces us with her presence today.";
        }
        else if (isZarevich(avatarKey)) {
            notification = "His Imperial Highness the Tsarevich is among us today.";
        }
        
        // Only announce if high enough rank and protocol
        if ((currentRank >= RANK_MEDIUM) && (protocolLevel >= 2) && (notification != "")) {
            llSay(0, courtierTitle + " " + courtierName + " discreetly notes, \"" + notification + "\"");
        }
    }
}

// Function to start a conversation
startConversation(key avatarKey, string avatarName) {
    // Set state
    currentState = STATE_CONVERSING;
    interactingWith = avatarKey;
    
    // Choose appropriate greeting based on who they are
    string greeting = "";
    
    if (isImperialFamily(avatarKey)) {
        // Use one of the royal greetings
        integer index = llFloor(llFrand(llGetListLength(royalGreetings)));
        greeting = llList2String(royalGreetings, index);
    }
    else {
        // Use one of the standard greetings
        integer index = llFloor(llFrand(llGetListLength(greetings)));
        greeting = llList2String(greetings, index);
        greeting += " I am " + courtierTitle + " " + courtierName + ", " + courtierRole + ".";
    }
    
    // Deliver greeting
    llRegionSayTo(avatarKey, 0, greeting);
    
    // Start NPC animation for talking
    // Would use llStartAnimation(ANIM_CONVERSE) in a real implementation
    
    // Set timer to end conversation if no response
    llSetTimerEvent(30.0);
}

// Function to share court gossip
shareGossip(key avatarKey) {
    // Only certain types of courtiers share gossip
    if (currentType == TYPE_SERVANT || currentType == TYPE_CLERGY) {
        llRegionSayTo(avatarKey, 0, "I'm afraid I don't engage in idle gossip. Court protocol forbids it.");
        return;
    }
    
    // Select a random piece of gossip
    integer index = llFloor(llFrand(llGetListLength(gossip)));
    string gossipItem = llList2String(gossip, index);
    
    // Deliver with appropriate preamble
    string preamble = "";
    
    if (currentRank == RANK_HIGH) {
        preamble = "I normally wouldn't share such things, but I trust your discretion. ";
    }
    else if (currentRank == RANK_MEDIUM) {
        preamble = "Between ourselves, of course... ";
    }
    else {
        preamble = "Have you heard? ";
    }
    
    llRegionSayTo(avatarKey, 0, preamble + gossipItem);
}

// Function to share court rules
shareCourtrules(key avatarKey) {
    // Select a random court rule
    integer index = llFloor(llFrand(llGetListLength(courtRules)));
    string rule = llList2String(courtRules, index);
    
    // Deliver with appropriate preamble
    string preamble = "";
    
    if (currentType == TYPE_DIPLOMAT) {
        preamble = "As a diplomatic advisor, I must inform you that at the Russian Imperial Court, ";
    }
    else if (currentType == TYPE_NOBLE) {
        preamble = "As someone well-versed in court protocol, I should mention that ";
    }
    else if (currentType == TYPE_MILITARY) {
        preamble = "Court protocol dictates that ";
    }
    else if (currentType == TYPE_CLERGY) {
        preamble = "Both tradition and protocol require that ";
    }
    else {
        preamble = "It is important to remember that ";
    }
    
    llRegionSayTo(avatarKey, 0, preamble + rule);
}

// Function to discuss a random topic
discussTopic(key avatarKey) {
    // Select a random conversation topic
    integer index = llFloor(llFrand(llGetListLength(conversationTopics)));
    string topic = llList2String(conversationTopics, index);
    
    // Deliver topic
    llRegionSayTo(avatarKey, 0, topic);
}

// Function to follow a royal person
followRoyalty(key avatarKey, string avatarName) {
    // Only follow if ordered to or if high-ranking royal
    if (!isTsar(avatarKey) && !isTsarina(avatarKey)) {
        return;
    }
    
    // Set state
    currentState = STATE_FOLLOWING;
    interactingWith = avatarKey;
    
    // Announce following
    string title = isTsar(avatarKey) ? "His Imperial Majesty" : "Her Imperial Majesty";
    llSay(0, courtierTitle + " " + courtierName + " proceeds to accompany " + title + ".");
    
    // Start following animation/behavior
    // In a real implementation, would use pathfinding to follow
    
    // In this simulation, we'll just set a timer to "follow" for a period
    llSetTimerEvent(60.0);
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
}

// Function to update the courtier's display
updateCourtierDisplay() {
    string displayText = courtierTitle + " " + courtierName + "\n";
    displayText += courtierRole + "\n";
    
    // Show current state
    if (currentState == STATE_IDLE) {
        displayText += "Status: At leisure";
    }
    else if (currentState == STATE_GREETING) {
        displayText += "Status: Greeting visitors";
    }
    else if (currentState == STATE_BOWING) {
        if (isTsar(interactingWith)) {
            displayText += "Status: Attending to His Imperial Majesty";
        }
        else if (isTsarina(interactingWith)) {
            displayText += "Status: Attending to Her Imperial Majesty";
        }
        else if (isZarevich(interactingWith)) {
            displayText += "Status: Attending to His Imperial Highness";
        }
        else {
            displayText += "Status: Observing protocol";
        }
    }
    else if (currentState == STATE_CONVERSING) {
        displayText += "Status: In conversation";
    }
    else if (currentState == STATE_FOLLOWING) {
        if (isTsar(interactingWith)) {
            displayText += "Status: Escorting His Imperial Majesty";
        }
        else if (isTsarina(interactingWith)) {
            displayText += "Status: Escorting Her Imperial Majesty";
        }
        else {
            displayText += "Status: On imperial business";
        }
    }
    
    // Set the text with appropriate color based on rank
    vector textColor = <0.9, 0.9, 0.9>; // White for common
    
    if (currentRank == RANK_HIGH) {
        textColor = <0.9, 0.8, 0.3>; // Gold for high rank
    }
    else if (currentRank == RANK_MEDIUM) {
        textColor = <0.9, 0.7, 0.4>; // Light gold for medium rank
    }
    
    llSetText(displayText, textColor, 1.0);
}

// Function to configure the courtier
configureCourtier(integer type, integer rank, string name, string title, string role) {
    currentType = type;
    currentRank = rank;
    courtierName = name;
    courtierTitle = title;
    courtierRole = role;
    
    // Update display
    updateCourtierDisplay();
}

// Process commands from other system components
processCourtierCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "FOLLOW" && isImperialFamily(senderKey)) {
        // Format: FOLLOW
        followRoyalty(senderKey, llKey2Name(senderKey));
    }
    else if (command == "DISMISS" && isImperialFamily(senderKey)) {
        // Format: DISMISS
        returnToIdle();
        
        // Acknowledge dismissal
        if (isTsar(senderKey)) {
            llSay(0, courtierTitle + " " + courtierName + " bows deeply. \"As Your Imperial Majesty commands.\"");
        }
        else if (isTsarina(senderKey)) {
            llSay(0, courtierTitle + " " + courtierName + " bows deeply. \"As Your Imperial Majesty wishes.\"");
        }
        else {
            llSay(0, courtierTitle + " " + courtierName + " bows respectfully. \"At your service, Your Imperial Highness.\"");
        }
    }
    else if (command == "CONFIGURE" && isTsar(senderKey)) {
        // Format: CONFIGURE|type|rank|name|title|role
        if (llGetListLength(messageParts) >= 6) {
            integer type = (integer)llList2String(messageParts, 1);
            integer rank = (integer)llList2String(messageParts, 2);
            string name = llList2String(messageParts, 3);
            string title = llList2String(messageParts, 4);
            string role = llList2String(messageParts, 5);
            
            configureCourtier(type, rank, name, title, role);
            llRegionSayTo(senderKey, 0, "Courtier configuration updated.");
        }
    }
}

// Process chat messages from nearby avatars
processChatMessage(key avatarKey, string avatarName, string message) {
    // Ignore messages if not in conversation state
    if (currentState != STATE_CONVERSING && currentState != STATE_GREETING) {
        // Make an exception for the Imperial family
        if (!isImperialFamily(avatarKey)) {
            return;
        }
    }
    
    // Convert to lowercase for easier matching
    string lowerMessage = llToLower(message);
    
    // Check for requests for gossip
    if (llSubStringIndex(lowerMessage, "gossip") >= 0 || 
        llSubStringIndex(lowerMessage, "rumors") >= 0 || 
        llSubStringIndex(lowerMessage, "heard anything") >= 0) {
        
        shareGossip(avatarKey);
        return;
    }
    
    // Check for requests about court rules
    if (llSubStringIndex(lowerMessage, "protocol") >= 0 || 
        llSubStringIndex(lowerMessage, "etiquette") >= 0 || 
        llSubStringIndex(lowerMessage, "rules") >= 0 ||
        llSubStringIndex(lowerMessage, "court custom") >= 0) {
        
        shareCourtrules(avatarKey);
        return;
    }
    
    // Check for general conversation
    if (llSubStringIndex(lowerMessage, "how are you") >= 0 || 
        llSubStringIndex(lowerMessage, "what do you think") >= 0 || 
        llSubStringIndex(lowerMessage, "your opinion") >= 0 ||
        llSubStringIndex(lowerMessage, "tell me about") >= 0) {
        
        discussTopic(avatarKey);
        return;
    }
    
    // Check for farewell
    if (llSubStringIndex(lowerMessage, "goodbye") >= 0 || 
        llSubStringIndex(lowerMessage, "farewell") >= 0 || 
        llSubStringIndex(lowerMessage, "good day") >= 0 ||
        llSubStringIndex(lowerMessage, "until later") >= 0) {
        
        // Different response based on who is leaving
        string farewell = "";
        
        if (isImperialFamily(avatarKey)) {
            farewell = "I remain your humble servant, Your Imperial ";
            farewell += isTsar(avatarKey) || isTsarina(avatarKey) ? "Majesty." : "Highness.";
        }
        else {
            farewell = "Good day to you. It was a pleasure conversing with you.";
        }
        
        llRegionSayTo(avatarKey, 0, farewell);
        
        // Return to idle state
        returnToIdle();
        
        return;
    }
    
    // Default response for other queries
    string response = "";
    
    // Special responses for imperial family
    if (isTsar(avatarKey)) {
        response = "As Your Imperial Majesty wishes. I am at your service.";
    }
    else if (isTsarina(avatarKey)) {
        response = "Your Imperial Majesty honors me with your attention. How may I be of assistance?";
    }
    else if (isZarevich(avatarKey)) {
        response = "Your Imperial Highness, it is my privilege to serve the Heir to the Throne.";
    }
    else if (isImperialFamily(avatarKey)) {
        response = "Your Imperial Highness, I am at your disposal.";
    }
    else {
        // Generic acknowledgment for others
        response = "Indeed. The court has been most lively of late.";
    }
    
    llRegionSayTo(avatarKey, 0, response);
}

default {
    state_entry() {
        // Initialize courtier phrases
        initializeCourtierPhrases();
        
        // Configure courtier defaults
        configureCourtier(TYPE_NOBLE, RANK_MEDIUM, "Count Orlov", "Count", "Court Chamberlain");
        
        // Start listening for system events
        listenHandle = llListen(COURTIER_CHANNEL, "", NULL_KEY, "");
        
        // Also listen for chat from all sources
        listenHandle = llListen(0, "", NULL_KEY, "");
        
        // Start scanning for royalty
        llSensorRepeat("", NULL_KEY, AGENT, 20.0, PI, scanTimer);
        
        // Set initial state
        returnToIdle();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Different response based on who is touching
        if (isImperialFamily(toucherKey)) {
            // Royal interaction menu
            list options = ["Speak with Courtier", "Request Information", "Follow Me", "Dismiss"];
            llDialog(toucherKey, "How may " + courtierTitle + " " + courtierName + " serve Your Imperial " + 
                     (isTsar(toucherKey) || isTsarina(toucherKey) ? "Majesty" : "Highness") + "?", 
                     options, COURTIER_CHANNEL);
        }
        else {
            // Regular interaction menu
            list options = ["Speak with Courtier", "Ask about Court Protocol", "Request Gossip"];
            llDialog(toucherKey, "How may " + courtierTitle + " " + courtierName + " assist you?", 
                     options, COURTIER_CHANNEL);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Check if this is on the courtier special channel
        if (channel == COURTIER_CHANNEL) {
            // Process menu selections
            if (message == "Speak with Courtier") {
                startConversation(id, name);
            }
            else if (message == "Ask about Court Protocol" || message == "Request Information") {
                shareCourtrules(id);
            }
            else if (message == "Request Gossip") {
                shareGossip(id);
            }
            else if (message == "Follow Me" && isImperialFamily(id)) {
                followRoyalty(id, name);
            }
            else if (message == "Dismiss" && isImperialFamily(id)) {
                returnToIdle();
                
                // Acknowledge dismissal
                if (isTsar(id)) {
                    llSay(0, courtierTitle + " " + courtierName + " bows deeply. \"As Your Imperial Majesty commands.\"");
                }
                else if (isTsarina(id)) {
                    llSay(0, courtierTitle + " " + courtierName + " bows deeply. \"As Your Imperial Majesty wishes.\"");
                }
                else {
                    llSay(0, courtierTitle + " " + courtierName + " bows respectfully. \"At your service, Your Imperial Highness.\"");
                }
            }
            else {
                // Check if it's a system command
                processCourtierCommand(message, id);
            }
        }
        // Process chat on public channel
        else if (channel == 0) {
            processChatMessage(id, name, message);
        }
    }
    
    sensor(integer num_detected) {
        // Scan for royal family members
        integer i;
        for (i = 0; i < num_detected; i++) {
            key detectedKey = llDetectedKey(i);
            string detectedName = llDetectedName(i);
            float detectedDist = llDetectedDist(i);
            
            if (isImperialFamily(detectedKey)) {
                recognizeRoyalty(detectedKey, detectedName, detectedDist);
                
                // Once we've recognized one royal person, stop processing
                // This prevents multiple recognitions in the same sensor sweep
                return;
            }
        }
    }
    
    timer() {
        // Return to idle state after timer expires
        returnToIdle();
        
        // Stop timer
        llSetTimerEvent(0.0);
        
        // Update display
        updateCourtierDisplay();
    }
}