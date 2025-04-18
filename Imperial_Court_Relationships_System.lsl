// Imperial Court Relationships System
// Advanced Interaction Tracking System with Dynamic Social Influence Reputation Mechanism
// Tracks relationships, influence, and reputation between members of the Russian Imperial Court

// Constants
integer COURT_RELATIONSHIPS_CHANNEL = -100;
integer COURT_INFLUENCE_CHANNEL = -101;
integer RELATIONSHIP_UPDATE_CHANNEL = -102;
integer REPUTATION_UPDATE_CHANNEL = -103;
integer HUD_LINK_MESSAGE_CHANNEL = 42;

// Shared key for authenticating messages between HUDs
string AUTHENTICATION_KEY = "ImperialCourtAuth1905";

// Key for authorizing admin-level operations
string ADMIN_KEY = "ImperialCourtAdmin1905";

// Maximum number of relationship entries per avatar
integer MAX_RELATIONSHIPS = 25;

// Maximum number of tracked interactions per relationship
integer MAX_INTERACTION_HISTORY = 10;

// Maximum number of reputation factors per avatar
integer MAX_REPUTATION_FACTORS = 10;

// Relationship tracking
// Format for relationships: [UUID, relationship level (-100 to 100), relationship type, last interaction time]
list trackedRelationships = [];

// Interaction history
// Format: [UUID1 + UUID2, timestamp, interaction type, influence change, description]
list interactionHistory = [];

// Reputation system
// Format: [UUID, total reputation, highest faction, recent change, faction influences, faction descriptions]
list reputationSystem = [];

// Court factions for influence tracking
list courtFactions = [
    "Imperial Family", "Direct members of the Romanov dynasty",
    "Military Leadership", "Army and Navy high command",
    "Aristocratic Elite", "Old noble families and the highest aristocracy",
    "Church Hierarchy", "Orthodox Church leadership",
    "Government Officials", "Ministers and bureaucrats",
    "Foreign Diplomats", "Ambassadors and diplomatic corps",
    "Cultural Figures", "Artists, writers, and intellectuals",
    "Conservative Faction", "Traditionalists supporting autocracy",
    "Progressive Faction", "Moderates supporting careful reforms",
    "Financial Interests", "Banking, industry, and commerce"
];

// Court prestige tiers
list prestigeTiers = [
    "Imperial Majesty", 90, "The Tsar and immediate Imperial family",
    "Imperial Highness", 80, "Grand Dukes and Grand Duchesses",
    "Serene Highness", 70, "Junior Romanov princes and princesses",
    "Distinguished Nobility", 60, "Highest aristocracy and court officials",
    "High Nobility", 50, "Counts and important nobles",
    "Court Nobility", 40, "Barons and regular court attendees",
    "Lesser Nobility", 30, "Minor nobles and gentry",
    "Court Official", 20, "Non-noble government functionaries",
    "Court Attendee", 10, "Regular visitors without titles",
    "General Public", 0, "Ordinary citizens without court standing"
];

// Owner information
key ownerKey;
string ownerName;
string ownerTitle = "Member of the Imperial Court";
integer ownerPrestige = 10; // Default starting value
list ownerFactionInfluence = []; // Will be initialized with all factions at 0

// Initialize owner faction influence
initializeOwnerInfluence() {
    ownerFactionInfluence = [];
    integer i;
    integer count = llGetListLength(courtFactions) / 2;
    
    for(i = 0; i < count; i++) {
        ownerFactionInfluence += 0; // Start with neutral influence in all factions
    }
}

// Clean and validate state on initialization
validateState() {
    // Check if lists are properly initialized
    if(llGetListLength(ownerFactionInfluence) == 0) {
        initializeOwnerInfluence();
    }
    
    // Trim lists if they exceed maximum size
    while(llGetListLength(trackedRelationships) > MAX_RELATIONSHIPS * 4) {
        trackedRelationships = llDeleteSubList(trackedRelationships, 0, 3);
    }
    
    while(llGetListLength(interactionHistory) > MAX_INTERACTION_HISTORY * 5) {
        interactionHistory = llDeleteSubList(interactionHistory, 0, 4);
    }
    
    while(llGetListLength(reputationSystem) > MAX_REPUTATION_FACTORS * 6) {
        reputationSystem = llDeleteSubList(reputationSystem, 0, 5);
    }
}

// Calculate combined relationship key for two avatars
string getRelationshipKey(key avatar1, key avatar2) {
    // Simply use UUID strings directly
    string str1 = (string)avatar1;
    string str2 = (string)avatar2;
    
    // Use a very basic deterministic approach that doesn't need any comparison
    // Just make the deterministic decision based on string length
    if(llStringLength(str1) != llStringLength(str2)) {
        if(llStringLength(str1) < llStringLength(str2)) {
            return str1 + "|" + str2;
        } else {
            return str2 + "|" + str1;
        }
    }
    
    // If length is the same, we'll just use a fixed ordering
    // This is still deterministic, just not lexicographically sorted
    return str1 + "|" + str2;
}

// Find relationship between two avatars
integer findRelationship(key avatar1, key avatar2) {
    integer i;
    integer count = llGetListLength(trackedRelationships) / 4;
    
    for(i = 0; i < count; i++) {
        integer index = i * 4;
        key storedAvatar = (key)llList2String(trackedRelationships, index);
        
        if(storedAvatar == avatar1) {
            return index;
        }
    }
    
    return -1; // Relationship not found
}

// Get relationship level between two avatars
integer getRelationshipLevel(key avatar1, key avatar2) {
    integer index = findRelationship(avatar1, avatar2);
    
    if(index != -1) {
        return llList2Integer(trackedRelationships, index + 1);
    }
    
    return 0; // Neutral relationship by default
}

// Get relationship type between two avatars
string getRelationshipType(key avatar1, key avatar2) {
    integer index = findRelationship(avatar1, avatar2);
    
    if(index != -1) {
        return llList2String(trackedRelationships, index + 2);
    }
    
    return "Acquaintance"; // Default relationship type
}

// Update or create relationship between two avatars
// Return type omitted as LSL doesn't have void
updateRelationship(key avatar1, key avatar2, integer level, string type) {
    integer index = findRelationship(avatar1, avatar2);
    
    if(index != -1) {
        // Update existing relationship
        trackedRelationships = llListReplaceList(trackedRelationships, 
            [avatar1, level, type, llGetUnixTime()], index, index + 3);
    } else {
        // Create new relationship if space available
        if(llGetListLength(trackedRelationships) / 4 < MAX_RELATIONSHIPS) {
            trackedRelationships += [avatar1, level, type, llGetUnixTime()];
        } else {
            // Replace oldest relationship
            integer oldestTime = llGetUnixTime();
            integer oldestIndex = 0;
            integer i;
            integer count = llGetListLength(trackedRelationships) / 4;
            
            for(i = 0; i < count; i++) {
                integer timeIndex = i * 4 + 3;
                integer entryTime = llList2Integer(trackedRelationships, timeIndex);
                
                if(entryTime < oldestTime) {
                    oldestTime = entryTime;
                    oldestIndex = i * 4;
                }
            }
            
            trackedRelationships = llListReplaceList(trackedRelationships,
                [avatar1, level, type, llGetUnixTime()], oldestIndex, oldestIndex + 3);
        }
    }
}

// Record an interaction between two avatars
// No return type as function doesn't return anything
recordInteraction(key avatar1, key avatar2, string interactionType, integer influenceChange, string description) {
    string relationshipKey = getRelationshipKey(avatar1, avatar2);
    integer currentTime = llGetUnixTime();
    
    // Add new interaction to history
    if(llGetListLength(interactionHistory) / 5 >= MAX_INTERACTION_HISTORY) {
        // Remove oldest interaction if at capacity
        interactionHistory = llDeleteSubList(interactionHistory, 0, 4);
    }
    
    interactionHistory += [relationshipKey, currentTime, interactionType, influenceChange, description];
    
    // Update relationship based on interaction
    integer currentLevel = getRelationshipLevel(avatar1, avatar2);
    string currentType = getRelationshipType(avatar1, avatar2);
    
    // Adjust relationship level based on interaction
    currentLevel += influenceChange;
    
    // Keep relationship level within bounds
    if(currentLevel > 100) currentLevel = 100;
    if(currentLevel < -100) currentLevel = -100;
    
    // Update relationship type based on new level
    if(currentLevel >= 90) currentType = "Intimate Ally";
    else if(currentLevel >= 70) currentType = "Close Friend";
    else if(currentLevel >= 50) currentType = "Friend";
    else if(currentLevel >= 20) currentType = "Friendly Acquaintance";
    else if(currentLevel >= -20) currentType = "Acquaintance";
    else if(currentLevel >= -50) currentType = "Unfriendly";
    else if(currentLevel >= -70) currentType = "Adversary";
    else if(currentLevel >= -90) currentType = "Enemy";
    else currentType = "Sworn Enemy";
    
    // Update the relationship
    updateRelationship(avatar1, avatar2, currentLevel, currentType);
    
    // Broadcast relationship update to both parties
    string updateMessage = llList2CSV([AUTHENTICATION_KEY, "RELATIONSHIP_UPDATE", (string)avatar1, (string)avatar2, (string)currentLevel, currentType, description]);
    llRegionSay(RELATIONSHIP_UPDATE_CHANNEL, updateMessage);
}

// Find reputation entry for an avatar
integer findReputation(key avatar) {
    integer i;
    integer count = llGetListLength(reputationSystem) / 6;
    
    for(i = 0; i < count; i++) {
        integer index = i * 6;
        key storedAvatar = (key)llList2String(reputationSystem, index);
        
        if(storedAvatar == avatar) {
            return index;
        }
    }
    
    return -1; // Reputation not found
}

// Get total reputation score for an avatar
integer getReputationScore(key avatar) {
    integer index = findReputation(avatar);
    
    if(index != -1) {
        return llList2Integer(reputationSystem, index + 1);
    }
    
    return 0; // Neutral reputation by default
}

// Get highest faction influence for an avatar
string getHighestFaction(key avatar) {
    integer index = findReputation(avatar);
    
    if(index != -1) {
        return llList2String(reputationSystem, index + 2);
    }
    
    return "None"; // No significant faction by default
}

// Update or create reputation for an avatar
// No return type as function doesn't return anything
updateReputation(key avatar, integer totalScore, string highestFaction, integer recentChange, list factionScores, string factionDetails) {
    integer index = findReputation(avatar);
    
    if(index != -1) {
        // Update existing reputation
        reputationSystem = llListReplaceList(reputationSystem, 
            [avatar, totalScore, highestFaction, recentChange, factionScores, factionDetails], index, index + 5);
    } else {
        // Create new reputation if space available
        if(llGetListLength(reputationSystem) / 6 < MAX_REPUTATION_FACTORS) {
            reputationSystem += [avatar, totalScore, highestFaction, recentChange, factionScores, factionDetails];
        } else {
            // Simple replacement of first entry if at capacity
            reputationSystem = llListReplaceList(reputationSystem,
                [avatar, totalScore, highestFaction, recentChange, factionScores, factionDetails], 0, 5);
        }
    }
    
    // Broadcast reputation update
    string updateMessage = llList2CSV([AUTHENTICATION_KEY, "REPUTATION_UPDATE", (string)avatar, (string)totalScore, highestFaction, (string)recentChange]);
    llRegionSay(REPUTATION_UPDATE_CHANNEL, updateMessage);
}

// Calculate prestige tier based on reputation score
string calculatePrestigeTier(integer score) {
    integer i;
    integer count = llGetListLength(prestigeTiers) / 3;
    
    for(i = 0; i < count; i++) {
        integer index = i * 3;
        integer tierThreshold = llList2Integer(prestigeTiers, index + 1);
        
        if(score >= tierThreshold) {
            return llList2String(prestigeTiers, index);
        }
    }
    
    return "General Public"; // Default lowest tier
}

// Process interaction between two avatars and update reputation
// No return type as function doesn't return anything
processInteraction(key initiator, key target, string interactionType, string details) {
    // Default influence values
    integer relationshipChange = 0;
    string highestFaction = "None";
    integer reputationChange = 0;
    list factionChanges = [];
    
    // Initialize faction changes list if needed
    integer factionCount = llGetListLength(courtFactions) / 2;
    integer i;
    for(i = 0; i < factionCount; i++) {
        factionChanges += 0;
    }
    
    // Process different interaction types
    if(interactionType == "Greeting") {
        relationshipChange = 1;
        reputationChange = 0;
    }
    else if(interactionType == "Formal Introduction") {
        relationshipChange = 2;
        reputationChange = 1;
        // Affect aristocratic elite faction
        factionChanges = llListReplaceList(factionChanges, [1], 2, 2);
    }
    else if(interactionType == "Private Conversation") {
        relationshipChange = 3;
        reputationChange = 1;
    }
    else if(interactionType == "Social Invitation") {
        relationshipChange = 4;
        reputationChange = 2;
        // Affect aristocratic elite faction
        factionChanges = llListReplaceList(factionChanges, [2], 2, 2);
    }
    else if(interactionType == "Gift Giving") {
        relationshipChange = 5;
        reputationChange = 2;
    }
    else if(interactionType == "Public Praise") {
        relationshipChange = 6;
        reputationChange = 3;
        // Affect multiple factions
        factionChanges = llListReplaceList(factionChanges, [3], 2, 2); // Aristocratic Elite
        factionChanges = llListReplaceList(factionChanges, [1], 6, 6); // Cultural Figures
    }
    else if(interactionType == "Alliance Offer") {
        relationshipChange = 8;
        reputationChange = 4;
        // Affect political factions
        factionChanges = llListReplaceList(factionChanges, [3], 7, 7); // Conservative Faction
    }
    else if(interactionType == "Slight Insult") {
        relationshipChange = -3;
        reputationChange = -1;
    }
    else if(interactionType == "Public Criticism") {
        relationshipChange = -5;
        reputationChange = -2;
        // Affect multiple factions
        factionChanges = llListReplaceList(factionChanges, [-2], 2, 2); // Aristocratic Elite
        factionChanges = llListReplaceList(factionChanges, [-1], 6, 6); // Cultural Figures
    }
    else if(interactionType == "Formal Challenge") {
        relationshipChange = -8;
        reputationChange = -3;
        // Affect military faction
        factionChanges = llListReplaceList(factionChanges, [2], 1, 1); // Military Leadership
    }
    else if(interactionType == "Religious Debate") {
        relationshipChange = 0; // Could go either way
        reputationChange = 1;
        // Affect church faction
        factionChanges = llListReplaceList(factionChanges, [3], 3, 3); // Church Hierarchy
    }
    else if(interactionType == "Military Discussion") {
        relationshipChange = 2;
        reputationChange = 1;
        // Affect military faction
        factionChanges = llListReplaceList(factionChanges, [3], 1, 1); // Military Leadership
    }
    else if(interactionType == "Court Gossip") {
        relationshipChange = -1; // Slightly negative
        reputationChange = 0; // Neutral effect on reputation
    }
    else if(interactionType == "Charitable Support") {
        relationshipChange = 3;
        reputationChange = 4;
        // Affect church and conservative factions
        factionChanges = llListReplaceList(factionChanges, [2], 3, 3); // Church Hierarchy
        factionChanges = llListReplaceList(factionChanges, [1], 7, 7); // Conservative Faction
    }
    else if(interactionType == "Cultural Patronage") {
        relationshipChange = 4;
        reputationChange = 3;
        // Affect cultural faction
        factionChanges = llListReplaceList(factionChanges, [4], 6, 6); // Cultural Figures
    }
    else if(interactionType == "Political Support") {
        relationshipChange = 5;
        reputationChange = 5;
        // Affect government and political faction groups
        factionChanges = llListReplaceList(factionChanges, [3], 4, 4); // Government Officials
        factionChanges = llListReplaceList(factionChanges, [3], 7, 7); // Conservative Faction
    }
    else if(interactionType == "Diplomatic Exchange") {
        relationshipChange = 3;
        reputationChange = 2;
        // Affect foreign diplomats faction
        factionChanges = llListReplaceList(factionChanges, [4], 5, 5); // Foreign Diplomats
    }
    else if(interactionType == "Business Transaction") {
        relationshipChange = 2;
        reputationChange = 1;
        // Affect financial interests faction
        factionChanges = llListReplaceList(factionChanges, [3], 9, 9); // Financial Interests
    }
    
    // Record the interaction
    recordInteraction(initiator, target, interactionType, relationshipChange, details);
    
    // Update initiator's reputation if it's the owner
    if(initiator == ownerKey) {
        // Calculate new faction influences
        list newFactionInfluence = [];
        for(i = 0; i < factionCount; i++) {
            integer oldValue = llList2Integer(ownerFactionInfluence, i);
            integer change = llList2Integer(factionChanges, i);
            newFactionInfluence += oldValue + change;
        }
        ownerFactionInfluence = newFactionInfluence;
        
        // Find highest faction influence
        integer highestValue = -999;
        integer highestIndex = 0;
        for(i = 0; i < factionCount; i++) {
            integer value = llList2Integer(ownerFactionInfluence, i);
            if(value > highestValue) {
                highestValue = value;
                highestIndex = i;
            }
        }
        highestFaction = llList2String(courtFactions, highestIndex * 2);
        
        // Update owner's reputation
        ownerPrestige += reputationChange;
        if(ownerPrestige > 100) ownerPrestige = 100;
        if(ownerPrestige < 0) ownerPrestige = 0;
        
        // Get faction details as string
        string factionDetails = "";
        for(i = 0; i < factionCount; i++) {
            if(i > 0) factionDetails += ", ";
            factionDetails += llList2String(courtFactions, i * 2) + ": " + (string)llList2Integer(ownerFactionInfluence, i);
        }
        
        // Update internal reputation tracking
        updateReputation(ownerKey, ownerPrestige, highestFaction, reputationChange, ownerFactionInfluence, factionDetails);
        
        // Update owner title based on prestige
        ownerTitle = calculatePrestigeTier(ownerPrestige);
    }
}

// Generate a formatted reputation report for the HUD owner
string generateReputationReport() {
    string report = "Imperial Court Standing:\n\n";
    
    report += "Title: " + ownerTitle + "\n";
    report += "Prestige: " + (string)ownerPrestige + "/100\n";
    
    // Get highest faction influence
    integer highestValue = -999;
    integer highestIndex = 0;
    integer i;
    integer factionCount = llGetListLength(courtFactions) / 2;
    
    for(i = 0; i < factionCount; i++) {
        integer value = llList2Integer(ownerFactionInfluence, i);
        if(value > highestValue) {
            highestValue = value;
            highestIndex = i;
        }
    }
    string highestFaction = llList2String(courtFactions, highestIndex * 2);
    
    report += "Primary Influence: " + highestFaction + "\n\n";
    report += "Faction Standing:\n";
    
    // List faction standings
    for(i = 0; i < factionCount; i++) {
        string faction = llList2String(courtFactions, i * 2);
        integer value = llList2Integer(ownerFactionInfluence, i);
        report += faction + ": " + (string)value + "\n";
    }
    
    return report;
}

// Generate a formatted relationship report
string generateRelationshipReport() {
    string report = "Court Relationships:\n\n";
    
    integer count = llGetListLength(trackedRelationships) / 4;
    integer i;
    
    // Sort relationships by level (highest first)
    list sortedIndices = [];
    list relationshipLevels = [];
    
    for(i = 0; i < count; i++) {
        integer level = llList2Integer(trackedRelationships, i * 4 + 1);
        relationshipLevels += (string)level; // Cast to string to avoid type mismatch
        sortedIndices += (string)i; // Cast to string to avoid type mismatch
    }
    
    // Simple bubble sort for this small list
    integer j;
    for(i = 0; i < count - 1; i++) {
        for(j = 0; j < count - i - 1; j++) {
            integer level1 = (integer)llList2String(relationshipLevels, j);
            integer level2 = (integer)llList2String(relationshipLevels, j + 1);
            if(level1 < level2) {
                // Swap levels
                relationshipLevels = llListReplaceList(relationshipLevels, [(string)level2, (string)level1], j, j + 1);
                // Swap indices
                integer index1 = (integer)llList2String(sortedIndices, j);
                integer index2 = (integer)llList2String(sortedIndices, j + 1);
                sortedIndices = llListReplaceList(sortedIndices, [(string)index2, (string)index1], j, j + 1);
            }
        }
    }
    
    // List relationships in order of closeness
    for(i = 0; i < count; i++) {
        integer index = (integer)llList2String(sortedIndices, i);
        key avatar = (key)llList2String(trackedRelationships, index * 4);
        integer level = llList2Integer(trackedRelationships, index * 4 + 1);
        string type = llList2String(trackedRelationships, index * 4 + 2);
        
        string avatarName = llKey2Name(avatar);
        if(avatarName == "") {
            avatarName = "Unknown Person";
        }
        
        report += avatarName + "\n";
        report += "   Relationship: " + type + " (" + (string)level + ")\n";
    }
    
    return report;
}

// Generate a formatted interaction history report
string generateInteractionHistory() {
    string report = "Recent Interactions:\n\n";
    
    integer count = llGetListLength(interactionHistory) / 5;
    integer i;
    
    // Sort interactions by time (newest first)
    list sortedIndices = [];
    list interactionTimes = [];
    
    for(i = 0; i < count; i++) {
        integer time = llList2Integer(interactionHistory, i * 5 + 1);
        interactionTimes += (string)time; // Cast to string to avoid type mismatch
        sortedIndices += (string)i; // Cast to string to avoid type mismatch
    }
    
    // Simple bubble sort
    integer j;
    for(i = 0; i < count - 1; i++) {
        for(j = 0; j < count - i - 1; j++) {
            integer time1 = (integer)llList2String(interactionTimes, j);
            integer time2 = (integer)llList2String(interactionTimes, j + 1);
            if(time1 < time2) {
                // Swap times
                interactionTimes = llListReplaceList(interactionTimes, [(string)time2, (string)time1], j, j + 1);
                // Swap indices
                integer index1 = (integer)llList2String(sortedIndices, j);
                integer index2 = (integer)llList2String(sortedIndices, j + 1);
                sortedIndices = llListReplaceList(sortedIndices, [(string)index2, (string)index1], j, j + 1);
            }
        }
    }
    
    // List interactions in reverse chronological order
    for(i = 0; i < count; i++) {
        integer index = (integer)llList2String(sortedIndices, i);
        string relationshipKey = llList2String(interactionHistory, index * 5);
        integer timestamp = llList2Integer(interactionHistory, index * 5 + 1);
        string type = llList2String(interactionHistory, index * 5 + 2);
        integer influence = llList2Integer(interactionHistory, index * 5 + 3);
        string description = llList2String(interactionHistory, index * 5 + 4);
        
        // Parse the relationship key to get the UUIDs
        list keyParts = llParseString2List(relationshipKey, ["|"], []);
        key avatar1 = (key)llList2String(keyParts, 0);
        key avatar2 = (key)llList2String(keyParts, 1);
        
        // Get avatar names
        string name1 = llKey2Name(avatar1);
        string name2 = llKey2Name(avatar2);
        
        if(name1 == "") name1 = "Unknown Person";
        if(name2 == "") name2 = "Unknown Person";
        
        // Format time difference
        integer timeDiff = llGetUnixTime() - timestamp;
        string timeStr;
        
        if(timeDiff < 60) {
            timeStr = (string)timeDiff + " seconds ago";
        } else if(timeDiff < 3600) {
            timeStr = (string)(timeDiff / 60) + " minutes ago";
        } else if(timeDiff < 86400) {
            timeStr = (string)(timeDiff / 3600) + " hours ago";
        } else {
            timeStr = (string)(timeDiff / 86400) + " days ago";
        }
        
        report += timeStr + "\n";
        report += name1 + " and " + name2 + "\n";
        report += "   Interaction: " + type + " (" + (string)influence + ")\n";
        report += "   Details: " + description + "\n\n";
    }
    
    return report;
}

// Process commands from menu selections
// No return type as function doesn't return anything
processMenuCommand(key id, string command) {
    list cmd = llParseStringKeepNulls(command, ["|"], []);
    string action = llList2String(cmd, 0);
    
    if(action == "VIEW_REPUTATION") {
        string report = generateReputationReport();
        llDialog(id, report, ["Relationships", "Interactions", "Main Menu"], COURT_RELATIONSHIPS_CHANNEL);
    }
    else if(action == "VIEW_RELATIONSHIPS") {
        string report = generateRelationshipReport();
        llDialog(id, report, ["Reputation", "Interactions", "Main Menu"], COURT_RELATIONSHIPS_CHANNEL);
    }
    else if(action == "VIEW_INTERACTIONS") {
        string report = generateInteractionHistory();
        llDialog(id, report, ["Reputation", "Relationships", "Main Menu"], COURT_RELATIONSHIPS_CHANNEL);
    }
    else if(action == "RECORD_INTERACTION") {
        // Show list of possible interaction types
        list interactionTypes = [
            "Greeting", "Formal Introduction", "Private Conversation", 
            "Social Invitation", "Gift Giving", "Public Praise",
            "Alliance Offer", "Slight Insult", "Public Criticism",
            "More Options"
        ];
        llDialog(id, "Select interaction type:", interactionTypes, COURT_RELATIONSHIPS_CHANNEL);
    }
    else if(action == "MORE_INTERACTIONS") {
        // Show second page of interaction types
        list interactionTypes = [
            "Formal Challenge", "Religious Debate", "Military Discussion",
            "Court Gossip", "Charitable Support", "Cultural Patronage",
            "Political Support", "Diplomatic Exchange", "Business Transaction",
            "Back"
        ];
        llDialog(id, "Select interaction type:", interactionTypes, COURT_RELATIONSHIPS_CHANNEL);
    }
    else if(action == "INTERACTION_TARGET") {
        string interactionType = llList2String(cmd, 1);
        // Request touch target for the interaction
        llOwnerSay("Please touch the person you want to interact with for: " + interactionType);
        llSetTimerEvent(30.0); // Set timeout for touch detection
    }
    else if(action == "MAIN_MENU") {
        showMainMenu(id);
    }
    else if(llListFindList(["Greeting", "Formal Introduction", "Private Conversation", 
        "Social Invitation", "Gift Giving", "Public Praise", "Alliance Offer",
        "Slight Insult", "Public Criticism", "Formal Challenge", "Religious Debate",
        "Military Discussion", "Court Gossip", "Charitable Support", "Cultural Patronage",
        "Political Support", "Diplomatic Exchange", "Business Transaction"], [action]) != -1) {
        
        // This is an interaction type selection
        // Store it and prompt for target
        llOwnerSay("Please touch the person you want to interact with for: " + action);
        
        // Store selected interaction type for when touch happens
        llSetTimerEvent(30.0); // Set timeout for touch detection
    }
}

// Show main menu dialog
// No return type as function doesn't return anything
showMainMenu(key id) {
    list buttons = [
        "View Reputation", 
        "View Relationships", 
        "View Interactions", 
        "Record Interaction"
    ];
    
    llDialog(id, "Imperial Court Relationships System\n\nSelect an option:", buttons, COURT_RELATIONSHIPS_CHANNEL);
}

// Handle dialog input
// No return type as function doesn't return anything
handleDialogResponse(key id, string message) {
    if(message == "View Reputation") {
        processMenuCommand(id, "VIEW_REPUTATION");
    }
    else if(message == "View Relationships") {
        processMenuCommand(id, "VIEW_RELATIONSHIPS");
    }
    else if(message == "View Interactions") {
        processMenuCommand(id, "VIEW_INTERACTIONS");
    }
    else if(message == "Record Interaction") {
        processMenuCommand(id, "RECORD_INTERACTION");
    }
    else if(message == "More Options") {
        processMenuCommand(id, "MORE_INTERACTIONS");
    }
    else if(message == "Back") {
        processMenuCommand(id, "RECORD_INTERACTION");
    }
    else if(message == "Main Menu") {
        processMenuCommand(id, "MAIN_MENU");
    }
    else if(message == "Reputation") {
        processMenuCommand(id, "VIEW_REPUTATION");
    }
    else if(message == "Relationships") {
        processMenuCommand(id, "VIEW_RELATIONSHIPS");
    }
    else if(message == "Interactions") {
        processMenuCommand(id, "VIEW_INTERACTIONS");
    }
    else if(llListFindList(["Greeting", "Formal Introduction", "Private Conversation", 
        "Social Invitation", "Gift Giving", "Public Praise", "Alliance Offer",
        "Slight Insult", "Public Criticism", "Formal Challenge", "Religious Debate",
        "Military Discussion", "Court Gossip", "Charitable Support", "Cultural Patronage",
        "Political Support", "Diplomatic Exchange", "Business Transaction"], [message]) != -1) {
        
        // Store selected interaction type and prompt for details
        llSetTimerEvent(0.0); // Cancel any pending timeout
        string interactionType = message;
        
        // Ask for details about the interaction
        llTextBox(id, "Enter details about this " + interactionType + " interaction:", COURT_INFLUENCE_CHANNEL);
        
        // Store information for when the text response comes back
    }
}

// Default state
default {
    state_entry() {
        ownerKey = llGetOwner();
        ownerName = llKey2Name(ownerKey);
        
        // Initialize lists if needed
        validateState();
        
        // Listen for dialog responses
        llListen(COURT_RELATIONSHIPS_CHANNEL, "", NULL_KEY, "");
        llListen(COURT_INFLUENCE_CHANNEL, "", NULL_KEY, "");
        llListen(RELATIONSHIP_UPDATE_CHANNEL, "", NULL_KEY, "");
        llListen(REPUTATION_UPDATE_CHANNEL, "", NULL_KEY, "");
        
        llOwnerSay("Imperial Court Relationships System initialized.");
        llOwnerSay("Touch the HUD to access the relationship and reputation tracking system.");
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        
        // Only respond to owner's touch
        if(toucherId == llGetOwner()) {
            showMainMenu(toucherId);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Only respond to owner's input for dialogs
        if(id == llGetOwner()) {
            if(channel == COURT_RELATIONSHIPS_CHANNEL) {
                handleDialogResponse(id, message);
            }
            else if(channel == COURT_INFLUENCE_CHANNEL) {
                // Process text box input for interaction details
                string interactionType = "Greeting"; // Default
                string interactionDetails = message;
                
                // Record the interaction with the target avatar
                key targetAvatar = llDetectedKey(0); // This assumes we're in touch detection mode
                
                if(targetAvatar) {
                    processInteraction(ownerKey, targetAvatar, interactionType, interactionDetails);
                    llOwnerSay("Recorded " + interactionType + " interaction with " + llKey2Name(targetAvatar));
                } else {
                    llOwnerSay("Error: No interaction target detected. Please try again.");
                }
                
                // Return to main menu
                showMainMenu(id);
            }
        }
        
        // Listen for secure broadcast messages about relationships and reputation
        if(channel == RELATIONSHIP_UPDATE_CHANNEL || channel == REPUTATION_UPDATE_CHANNEL) {
            list params = llCSV2List(message);
            
            // Verify authentication key to prevent spoofing
            if(llList2String(params, 0) == AUTHENTICATION_KEY) {
                string messageType = llList2String(params, 1);
                
                // Process relationship updates from other HUDs
                if(messageType == "RELATIONSHIP_UPDATE") {
                    key avatar1 = (key)llList2String(params, 2);
                    key avatar2 = (key)llList2String(params, 3);
                    integer level = (integer)llList2String(params, 4);
                    string type = llList2String(params, 5);
                    string description = llList2String(params, 6);
                    
                    // Only update if one of the avatars is the owner
                    if(avatar1 == ownerKey || avatar2 == ownerKey) {
                        // Update the relationship without broadcasting again
                        integer index = findRelationship(avatar1, avatar2);
                        
                        if(index != -1) {
                            trackedRelationships = llListReplaceList(trackedRelationships, 
                                [avatar1, level, type, llGetUnixTime()], index, index + 3);
                        } else {
                            if(llGetListLength(trackedRelationships) / 4 < MAX_RELATIONSHIPS) {
                                trackedRelationships += [avatar1, level, type, llGetUnixTime()];
                            }
                        }
                        
                        // Notify owner of relationship change
                        string otherAvatar;
                        if(avatar1 == ownerKey) {
                            otherAvatar = llKey2Name(avatar2);
                        } else {
                            otherAvatar = llKey2Name(avatar1);
                        }
                        llOwnerSay("Your relationship with " + otherAvatar + " is now " + type + " (" + (string)level + ")");
                    }
                }
                // Process reputation updates from other HUDs
                else if(messageType == "REPUTATION_UPDATE") {
                    key avatar = (key)llList2String(params, 2);
                    integer score = (integer)llList2String(params, 3);
                    string faction = llList2String(params, 4);
                    integer change = (integer)llList2String(params, 5);
                    
                    // Only update if the avatar is the owner
                    if(avatar == ownerKey) {
                        ownerPrestige = score;
                        
                        // Update owner title based on prestige
                        ownerTitle = calculatePrestigeTier(ownerPrestige);
                        
                        // Notify owner of reputation change
                        string changeText;
                        if(change > 0) {
                            changeText = "increased by " + (string)change;
                        } else {
                            changeText = "decreased by " + (string)(-change);
                        }
                        llOwnerSay("Your court reputation has " + changeText + ". New prestige: " + (string)score);
                        llOwnerSay("Your strongest influence is with the " + faction + " faction.");
                        llOwnerSay("Your court title is now: " + ownerTitle);
                    }
                }
            }
        }
    }
    
    touch(integer total_number) {
        // Process touch on another avatar for interaction
        key touched = llDetectedKey(0);
        
        // Exclude touches on self or non-avatar objects
        if(touched != NULL_KEY && touched != ownerKey && llGetAgentSize(touched) != ZERO_VECTOR) {
            string interactionType = "Greeting"; // Default or stored from dialog
            
            // Ask for interaction details
            llTextBox(ownerKey, "Enter details about this " + interactionType + 
                " interaction with " + llDetectedName(0) + ":", COURT_INFLUENCE_CHANNEL);
            
            // Store touched avatar for when the text response comes back
        }
    }
    
    timer() {
        // Timeout for touch detection
        llSetTimerEvent(0.0);
        llOwnerSay("Interaction target selection timed out. Please try again.");
        showMainMenu(ownerKey);
    }
    
    changed(integer change) {
        if(change & CHANGED_OWNER) {
            // Reset state for new owner
            ownerKey = llGetOwner();
            ownerName = llKey2Name(ownerKey);
            initializeOwnerInfluence();
            ownerPrestige = 10; // Default starting value
            
            // Clear tracked relationships
            trackedRelationships = [];
            interactionHistory = [];
            reputationSystem = [];
            
            llOwnerSay("Imperial Court Relationships System reset for new owner.");
        }
    }
}