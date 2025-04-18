// Imperial Arts and Culture Module
// Implements the arts and cultural scene of 1905 Imperial Russia
// Features Silver Age artists, patrons, poetry salons,
// museum exhibitions, and cultural reputation tracking

// Constants
integer HUD_LINK_MESSAGE_CHANNEL = 42;
integer TOUCH_CHANNEL = -42;
integer ARTS_CHANNEL = -48;

// Module identification
string MODULE_NAME = "ARTS";

// Art Movements
string MOVEMENT_SYMBOLISM = "Symbolism";
string MOVEMENT_REALISM = "Realism";
string MOVEMENT_MODERNISM = "Modernism";
string MOVEMENT_TRADITIONALISM = "Traditionalism";
string MOVEMENT_MIR_ISKUSSTVA = "Mir Iskusstva (World of Art)";

// Art Forms
list artForms = [
    "Literature", "Poetry", "Painting", 
    "Sculpture", "Ballet", "Opera",
    "Theater", "Music", "Architecture"
];

// Cultural institutions
list culturalInstitutions = [
    "Mariinsky Theater", "Saint Petersburg",
    "Bolshoi Theater", "Moscow",
    "Imperial Academy of Arts", "Saint Petersburg",
    "Tretyakov Gallery", "Moscow",
    "Moscow Art Theater", "Moscow",
    "Hermitage Museum", "Saint Petersburg",
    "Russian Museum", "Saint Petersburg",
    "Moscow Conservatory", "Moscow"
];

// Notable artistic figures of 1905 Russia
list notableArtists = [
    "Anton Chekhov", "Literature", "Playwright", "1904",
    "Maxim Gorky", "Literature", "Writer", "Active",
    "Leo Tolstoy", "Literature", "Writer", "Active",
    "Alexander Blok", "Poetry", "Symbolist", "Active",
    "Valery Bryusov", "Poetry", "Symbolist", "Active",
    "Mikhail Vrubel", "Painting", "Symbolist", "Active",
    "Ilya Repin", "Painting", "Realist", "Active",
    "Viktor Vasnetsov", "Painting", "Traditionalist", "Active",
    "Sergei Diaghilev", "Ballet", "Mir Iskusstva", "Active",
    "Anna Pavlova", "Ballet", "Dancer", "Active",
    "Fyodor Chaliapin", "Opera", "Bass Singer", "Active",
    "Konstantin Stanislavski", "Theater", "Director", "Active",
    "Sergei Rachmaninoff", "Music", "Composer", "Active",
    "Alexander Scriabin", "Music", "Composer", "Active"
];

// Personal artistic skills and involvement
list artisticSkills = []; // Format: [art form, skill level, last practice time]
string preferredMovement = MOVEMENT_TRADITIONALISM;
list ownedArtworks = []; // Format: [title, artist, value]
list patronageRelationships = []; // Format: [artist name, art form, support level]
list culturalEvents = []; // Format: [event type, date, location]
list literarySalon = []; // Format: [name, position, influence]
string culturalReputation = "Unknown";
list culturalPublications = []; // Format: [title, type, date]

// Skill levels
integer SKILL_NOVICE = 0;
integer SKILL_AMATEUR = 1;
integer SKILL_ACCOMPLISHED = 2;
integer SKILL_MASTER = 3;
integer SKILL_VIRTUOSO = 4;

// Practice cooldown (in seconds)
integer PRACTICE_COOLDOWN = 3600; // 1 hour
integer lastPracticeTime = 0;

// Cache player data
string playerName = "";
key playerKey = NULL_KEY;
string playerGender = "Unknown";
string playerRank = "";
integer playerRubles = 0;
integer isNoble = FALSE;

// Function to get a skill level name
string getSkillLevelName(integer level) {
    if(level == SKILL_NOVICE) return "Novice";
    else if(level == SKILL_AMATEUR) return "Amateur";
    else if(level == SKILL_ACCOMPLISHED) return "Accomplished";
    else if(level == SKILL_MASTER) return "Master";
    else if(level == SKILL_VIRTUOSO) return "Virtuoso";
    return "Unknown";
}

// Initialize artistic skills list
initializeSkills() {
    artisticSkills = [];
    integer i;
    integer count = llGetListLength(artForms);
    
    for(i = 0; i < count; i++) {
        string artForm = llList2String(artForms, i);
        artisticSkills += [artForm, SKILL_NOVICE, 0]; // Art form, skill level, last practice time
    }
    
    // Set defaults based on noble status
    if(isNoble) {
        setSkillLevel("Music", SKILL_AMATEUR);
        setSkillLevel("Literature", SKILL_AMATEUR);
        
        // Add initial art ownership for nobles
        ownedArtworks = [
            "Landscape of Russia", "Unknown Artist", "1000",
            "Family Portrait", "Court Painter", "2000"
        ];
        
        // Add default salon members for nobles
        literarySalon = [
            "Court Poet", "Resident Artist", "Medium",
            "Local Musician", "Performer", "Low"
        ];
    }
}

// Update skill level for a specific art form
setSkillLevel(string artForm, integer level) {
    integer index = llListFindList(artisticSkills, [artForm]);
    
    if(index != -1) {
        artisticSkills = llListReplaceList(artisticSkills, [level], index + 1, index + 1);
    }
}

// Get current skill level for an art form
integer getSkillLevel(string artForm) {
    integer index = llListFindList(artisticSkills, [artForm]);
    
    if(index != -1) {
        return llList2Integer(artisticSkills, index + 1);
    }
    
    return SKILL_NOVICE;
}

// Update last practice time for an art form
updatePracticeTime(string artForm) {
    integer index = llListFindList(artisticSkills, [artForm]);
    integer currentTime = llGetUnixTime();
    
    if(index != -1) {
        artisticSkills = llListReplaceList(artisticSkills, [currentTime], index + 2, index + 2);
        lastPracticeTime = currentTime;
    }
}

// Check if player can practice an art form (cooldown passed)
integer canPracticeArt(string artForm) {
    integer index = llListFindList(artisticSkills, [artForm]);
    integer currentTime = llGetUnixTime();
    
    if(index != -1) {
        integer lastTime = llList2Integer(artisticSkills, index + 2);
        
        // Can practice if cooldown has passed
        return (currentTime - lastTime) >= PRACTICE_COOLDOWN;
    }
    
    return TRUE;
}

// Practice an art form to increase skill
practiceArt(string artForm) {
    integer level = getSkillLevel(artForm);
    
    // Can only advance if not already virtuoso
    if(level < SKILL_VIRTUOSO) {
        // Update skill level
        setSkillLevel(artForm, level + 1);
        updatePracticeTime(artForm);
        
        // Update cultural reputation based on skill levels
        calculateCulturalReputation();
        
        llOwnerSay("🎭 You have practiced " + artForm + " and advanced to " + 
                  getSkillLevelName(level + 1) + " level!");
                  
        // Announce significant achievements
        if(level + 1 == SKILL_MASTER) {
            llSay(0, playerName + " has become a master of " + artForm + "!");
        }
        else if(level + 1 == SKILL_VIRTUOSO) {
            llSay(0, playerName + " has achieved virtuoso status in " + artForm + " and is now recognized in cultural circles!");
            
            // Add a cultural publication when reaching virtuoso
            addCulturalPublication(artForm);
        }
    }
    else {
        llOwnerSay("You have already achieved virtuoso status in " + artForm + ".");
    }
}

// Calculate cultural reputation based on skills
calculateCulturalReputation() {
    integer totalLevels = 0;
    integer artFormCount = llGetListLength(artForms);
    integer masterCount = 0;
    integer virtuosoCount = 0;
    
    integer i;
    for(i = 0; i < artFormCount; i++) {
        string artForm = llList2String(artForms, i);
        integer level = getSkillLevel(artForm);
        
        totalLevels += level;
        
        if(level == SKILL_VIRTUOSO) virtuosoCount++;
        if(level == SKILL_MASTER) masterCount++;
    }
    
    // Reputation also considers patronage and salon size
    integer patronageCount = llGetListLength(patronageRelationships) / 3;
    integer salonCount = llGetListLength(literarySalon) / 3;
    
    // Determine reputation based on artistic achievements
    if(virtuosoCount >= 1 || (masterCount >= 2 && patronageCount >= 3)) {
        culturalReputation = "Cultural Icon";
    }
    else if(masterCount >= 1 || (patronageCount >= 2 && salonCount >= 3)) {
        culturalReputation = "Cultural Leader";
    }
    else if(totalLevels >= artFormCount * SKILL_ACCOMPLISHED || patronageCount >= 1) {
        culturalReputation = "Patron of the Arts";
    }
    else if(totalLevels >= artFormCount * SKILL_AMATEUR) {
        culturalReputation = "Arts Enthusiast";
    }
    else {
        culturalReputation = "Cultural Novice";
    }
    
    // Update HUD with new reputation
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "CULTURAL_REPUTATION=" + culturalReputation, "");
}

// Add a cultural publication or performance
addCulturalPublication(string artForm) {
    string publicationType = "";
    string title = "";
    
    if(artForm == "Literature") {
        publicationType = "Novel";
        title = "Tales of Imperial Society";
    }
    else if(artForm == "Poetry") {
        publicationType = "Poetry Collection";
        title = "Verses from the Court";
    }
    else if(artForm == "Painting") {
        publicationType = "Exhibition";
        title = "Visions of Russia";
    }
    else if(artForm == "Sculpture") {
        publicationType = "Sculpture Commission";
        title = "Imperial Bronze";
    }
    else if(artForm == "Ballet") {
        publicationType = "Ballet Performance";
        title = "Imperial Seasons";
    }
    else if(artForm == "Opera") {
        publicationType = "Opera Performance";
        title = "Songs of the Empire";
    }
    else if(artForm == "Theater") {
        publicationType = "Theater Production";
        title = "Drama of the Century";
    }
    else if(artForm == "Music") {
        publicationType = "Musical Composition";
        title = "Imperial Melodies";
    }
    else if(artForm == "Architecture") {
        publicationType = "Architectural Design";
        title = "Modern Palace";
    }
    
    string dateString = (string)llGetUnixTime();
    culturalPublications += [title, publicationType, dateString];
    
    llOwnerSay("🎭 Your " + publicationType + " \"" + title + "\" has been well-received in cultural circles.");
    llSay(0, playerName + " has published/presented \"" + title + "\", a " + publicationType + "!");
}

// Add a patronage relationship with an artist
addPatronageRelationship(string artist, string artForm) {
    // Check if already patronizing this artist
    integer index = llListFindList(patronageRelationships, [artist]);
    
    if(index == -1) {
        // New patronage relationship
        patronageRelationships += [artist, artForm, "Low"];
        llOwnerSay("You have begun patronizing " + artist + " (" + artForm + ").");
        
        // Announce significant patronage
        if(llGetListLength(patronageRelationships) % 3 == 0) {
            // Every third artist patronized gets announced
            llSay(0, playerName + " has become a patron to " + artist + ", supporting the arts of Imperial Russia.");
        }
    }
    else {
        // Increase existing patronage level
        string currentLevel = llList2String(patronageRelationships, index + 2);
        string newLevel = currentLevel;
        
        if(currentLevel == "Low") newLevel = "Medium";
        else if(currentLevel == "Medium") newLevel = "High";
        
        if(currentLevel != newLevel) {
            patronageRelationships = llListReplaceList(patronageRelationships, [newLevel], index + 2, index + 2);
            llOwnerSay("You have increased your patronage of " + artist + " to " + newLevel + " level.");
            
            if(newLevel == "High") {
                llSay(0, playerName + " has become a major patron of " + artist + ", significantly supporting their artistic endeavors.");
            }
        }
        else {
            llOwnerSay("You are already a high-level patron of " + artist + ".");
        }
    }
    
    // Update cultural reputation to reflect patronage
    calculateCulturalReputation();
}

// Purchase an artwork
purchaseArtwork(string title, string artist, integer value) {
    if(playerRubles >= value) {
        playerRubles -= value;
        
        // Add to owned collection
        ownedArtworks += [title, artist, (string)value];
        
        llOwnerSay("You have purchased \"" + title + "\" by " + artist + " for " + (string)value + " rubles.");
        llSay(0, playerName + " has acquired \"" + title + "\" by " + artist + " for their collection.");
        
        // Update HUD with new rubles value
        llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "RUBLES=" + (string)playerRubles, "");
        
        // Also add patronage relationship with the artist
        string artForm = "Unknown";
        
        // Try to determine art form from notableArtists list
        integer index = llListFindList(notableArtists, [artist]);
        if(index != -1) {
            artForm = llList2String(notableArtists, index + 1);
        }
        
        addPatronageRelationship(artist, artForm);
    }
    else {
        llOwnerSay("You do not have enough rubles to purchase this artwork.");
    }
}

// Add a member to your literary salon
addSalonMember(string name, string position) {
    // Check salon size limit (max 12 for dialog menu purposes)
    if(llGetListLength(literarySalon) >= 36) { // 36 = 12 members * 3 fields
        llOwnerSay("Your salon cannot accommodate any more members. Consider removing some members first.");
        return;
    }
    
    // Check if already a member
    integer index = llListFindList(literarySalon, [name]);
    
    if(index == -1) {
        // New member
        literarySalon += [name, position, "Low"];
        
        llOwnerSay("You have invited " + name + " to join your salon as " + position + ".");
        
        // Announce salon growth at significant points
        integer memberCount = llGetListLength(literarySalon) / 3;
        if(memberCount == 5) {
            llSay(0, playerName + "'s literary salon is growing in reputation, with five distinguished members now attending.");
        }
        else if(memberCount == 10) {
            llSay(0, playerName + "'s literary salon has become one of the most prestigious cultural gatherings in the city.");
        }
    }
    else {
        // Increase existing member's influence
        string currentInfluence = llList2String(literarySalon, index + 2);
        string newInfluence = currentInfluence;
        
        if(currentInfluence == "Low") newInfluence = "Medium";
        else if(currentInfluence == "Medium") newInfluence = "High";
        
        if(currentInfluence != newInfluence) {
            literarySalon = llListReplaceList(literarySalon, [newInfluence], index + 2, index + 2);
            llOwnerSay(name + "'s influence in your salon has increased to " + newInfluence + ".");
        }
        else {
            llOwnerSay(name + " is already a highly influential member of your salon.");
        }
    }
    
    // Update cultural reputation
    calculateCulturalReputation();
}

// Host a cultural event
hostCulturalEvent(string eventType) {
    // Add to events list
    string currentDate = (string)llGetUnixTime();
    string location = playerRank + " Residence";
    
    culturalEvents += [eventType, currentDate, location];
    
    // Different announcements based on event type
    if(eventType == "Poetry Reading") {
        llSay(0, playerName + " hosts an elegant poetry reading, featuring works from the Silver Age of Russian poetry.");
    }
    else if(eventType == "Musical Soiree") {
        llSay(0, playerName + " presents a musical soiree with performances of Rachmaninoff and Tchaikovsky.");
    }
    else if(eventType == "Art Exhibition") {
        llSay(0, playerName + " opens their home for an exhibition of modern Russian art, including works from the Mir Iskusstva movement.");
    }
    else if(eventType == "Literary Discussion") {
        llSay(0, playerName + " leads a stimulating discussion on the latest works of Russian literature and their significance.");
    }
    else if(eventType == "Ballet Performance") {
        llSay(0, playerName + " arranges a private ballet performance showcasing the talents of Imperial Ballet dancers.");
    }
    
    // Cost for hosting
    integer eventCost = 1000; // Basic cost
    playerRubles -= eventCost;
    
    // Update HUD with new rubles value
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "RUBLES=" + (string)playerRubles, "");
    
    // Improve cultural reputation
    calculateCulturalReputation();
}

// Choose artistic movement affiliation
chooseArtisticMovement(string movement) {
    preferredMovement = movement;
    
    if(movement == MOVEMENT_SYMBOLISM) {
        llOwnerSay("You have aligned yourself with the Symbolist movement, focusing on mysticism, dreams, and the spiritual in art.");
    }
    else if(movement == MOVEMENT_REALISM) {
        llOwnerSay("You have aligned yourself with the Realist movement, emphasizing accurate depiction of everyday life and social issues.");
    }
    else if(movement == MOVEMENT_MODERNISM) {
        llOwnerSay("You have aligned yourself with the Modernist movement, embracing innovation and experimentation in artistic expression.");
    }
    else if(movement == MOVEMENT_TRADITIONALISM) {
        llOwnerSay("You have aligned yourself with the Traditionalist movement, preserving classical Russian artistic heritage and forms.");
    }
    else if(movement == MOVEMENT_MIR_ISKUSSTVA) {
        llOwnerSay("You have aligned yourself with the Mir Iskusstva (World of Art) movement, blending Russian themes with European aesthetics.");
    }
    
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "ARTISTIC_MOVEMENT=" + preferredMovement, "");
}

// Generate artistic skills report
string generateSkillsReport() {
    string report = "Your Artistic Abilities:\n\n";
    report += "Cultural Reputation: " + culturalReputation + "\n";
    report += "Preferred Movement: " + preferredMovement + "\n\n";
    report += "Skills:\n";
    
    integer i;
    integer count = llGetListLength(artisticSkills);
    
    for(i = 0; i < count; i += 3) {
        string artForm = llList2String(artisticSkills, i);
        integer level = llList2Integer(artisticSkills, i + 1);
        
        report += artForm + ": " + getSkillLevelName(level) + "\n";
    }
    
    return report;
}

// Generate collection report
string generateCollectionReport() {
    string report = "Your Art Collection:\n\n";
    
    integer count = llGetListLength(ownedArtworks);
    
    if(count == 0) {
        report += "You have not acquired any artworks yet.";
    }
    else {
        integer totalValue = 0;
        integer i;
        
        for(i = 0; i < count; i += 3) {
            string title = llList2String(ownedArtworks, i);
            string artist = llList2String(ownedArtworks, i + 1);
            integer value = (integer)llList2String(ownedArtworks, i + 2);
            
            report += "\"" + title + "\" by " + artist + "\n";
            report += "   Value: " + (string)value + " rubles\n\n";
            
            totalValue += value;
        }
        
        report += "Total Collection Value: " + (string)totalValue + " rubles";
    }
    
    return report;
}

// Generate patronage report
string generatePatronageReport() {
    string report = "Your Artistic Patronage:\n\n";
    
    integer count = llGetListLength(patronageRelationships);
    
    if(count == 0) {
        report += "You are not currently patronizing any artists.";
    }
    else {
        integer i;
        for(i = 0; i < count; i += 3) {
            string artist = llList2String(patronageRelationships, i);
            string artForm = llList2String(patronageRelationships, i + 1);
            string level = llList2String(patronageRelationships, i + 2);
            
            report += artist + " (" + artForm + ")\n";
            report += "   Support Level: " + level + "\n\n";
        }
    }
    
    return report;
}

// Generate salon report
string generateSalonReport() {
    string report = "Your Literary Salon:\n\n";
    
    integer count = llGetListLength(literarySalon);
    
    if(count == 0) {
        report += "You have not established a literary salon yet.";
    }
    else {
        integer i;
        for(i = 0; i < count; i += 3) {
            string name = llList2String(literarySalon, i);
            string position = llList2String(literarySalon, i + 1);
            string influence = llList2String(literarySalon, i + 2);
            
            report += name + " (" + position + ")\n";
            report += "   Influence: " + influence + "\n\n";
        }
    }
    
    return report;
}

// Generate cultural events report
string generateEventsReport() {
    string report = "Your Cultural Events:\n\n";
    
    integer count = llGetListLength(culturalEvents);
    
    if(count == 0) {
        report += "You have not hosted any cultural events yet.";
    }
    else {
        integer i;
        for(i = 0; i < count; i += 3) {
            string eventType = llList2String(culturalEvents, i);
            string date = llList2String(culturalEvents, i + 1);
            string location = llList2String(culturalEvents, i + 2);
            
            report += eventType + "\n";
            report += "   Date: " + date + "\n";
            report += "   Location: " + location + "\n\n";
        }
    }
    
    return report;
}

// Generate publications report
string generatePublicationsReport() {
    string report = "Your Cultural Publications and Performances:\n\n";
    
    integer count = llGetListLength(culturalPublications);
    
    if(count == 0) {
        report += "You have not published or performed any notable works yet.";
    }
    else {
        integer i;
        for(i = 0; i < count; i += 3) {
            string title = llList2String(culturalPublications, i);
            string type = llList2String(culturalPublications, i + 1);
            string date = llList2String(culturalPublications, i + 2);
            
            report += "\"" + title + "\" (" + type + ")\n";
            report += "   Date: " + date + "\n\n";
        }
    }
    
    return report;
}

// Display arts menu
displayArtsMenu(key id) {
    llDialog(id, "Imperial Arts & Culture Module\n\nCultural Reputation: " + culturalReputation + "\nMovement: " + preferredMovement + "\n\nWhat would you like to do?",
        ["Practice Art", "Art Collection", "Patronage", "Host Event", "Salon", "Movement", "Publications"], ARTS_CHANNEL);
}

// Display practice menu
displayPracticeMenu(key id) {
    // Only show art forms that are not at virtuoso and off cooldown
    list availableForms = [];
    
    integer i;
    integer count = llGetListLength(artForms);
    
    for(i = 0; i < count; i++) {
        string artForm = llList2String(artForms, i);
        if(getSkillLevel(artForm) < SKILL_VIRTUOSO && canPracticeArt(artForm)) {
            availableForms += [artForm];
        }
    }
    
    if(llGetListLength(availableForms) > 0) {
        llDialog(id, "Select an art form to practice:", availableForms + ["Back"], ARTS_CHANNEL);
    }
    else {
        llOwnerSay("All art forms are currently on cooldown or already mastered. Please try again later.");
        displayArtsMenu(id);
    }
}

// Display collection menu
displayCollectionMenu(key id) {
    string report = generateCollectionReport();
    
    llDialog(id, report, ["Purchase Art", "View Collection", "Back"], ARTS_CHANNEL);
}

// Display patronage menu
displayPatronageMenu(key id) {
    string report = generatePatronageReport();
    
    llDialog(id, report, ["Patronize Artist", "View Patronage", "Back"], ARTS_CHANNEL);
}

// Display artist selection menu for patronage
displayArtistSelectionMenu(key id) {
    // Create a list of notable artists
    list artistNames = [];
    
    integer i;
    integer count = llGetListLength(notableArtists);
    integer maxReached = FALSE;
    
    for(i = 0; i < count && !maxReached; i += 4) {
        string artist = llList2String(notableArtists, i);
        string status = llList2String(notableArtists, i + 3);
        
        // Only show active artists
        if(status == "Active") {
            artistNames += [artist];
        }
        
        // Only show 9 artists max due to dialog button limits
        if(llGetListLength(artistNames) >= 9) maxReached = TRUE;
    }
    
    llDialog(id, "Select an artist to patronize:", artistNames + ["Back"], ARTS_CHANNEL);
}

// Display salon menu
displaySalonMenu(key id) {
    string report = generateSalonReport();
    
    llDialog(id, report, ["Add Member", "Host Salon", "View Salon", "Back"], ARTS_CHANNEL);
}

// Display event hosting menu
displayEventMenu(key id) {
    llDialog(id, "Select the type of cultural event to host:",
        ["Poetry Reading", "Musical Soiree", "Art Exhibition", "Literary Discussion", "Ballet Performance", "Back"], ARTS_CHANNEL);
}

// Display art movement selection menu
displayMovementMenu(key id) {
    string description = "Current movement: " + preferredMovement + "\n\n";
    
    description += "Symbolism: Mysticism, dreams, and the spiritual.\n";
    description += "Realism: Accurate depiction of everyday life and social issues.\n";
    description += "Modernism: Innovation and experimentation in artistic expression.\n";
    description += "Traditionalism: Preserving classical Russian artistic heritage.\n";
    description += "Mir Iskusstva: Blending Russian themes with European aesthetics.";
    
    llDialog(id, description,
        [MOVEMENT_SYMBOLISM, MOVEMENT_REALISM, MOVEMENT_MODERNISM, MOVEMENT_TRADITIONALISM, MOVEMENT_MIR_ISKUSSTVA, "Back"], ARTS_CHANNEL);
}

// Display publications menu
displayPublicationsMenu(key id) {
    string report = generatePublicationsReport();
    
    llDialog(id, report, ["Back"], ARTS_CHANNEL);
}

// Update cached player data
updatePlayerData(string field, string value) {
    if(field == "PLAYERNAME") {
        playerName = value;
    }
    else if(field == "PLAYERKEY") {
        playerKey = (key)value;
    }
    else if(field == "GENDER") {
        playerGender = value;
    }
    else if(field == "RANK") {
        playerRank = value;
        
        // Check if player is noble
        if(llSubStringIndex(playerRank, "Imperial") != -1 || 
           llSubStringIndex(playerRank, "Prince") != -1 ||
           llSubStringIndex(playerRank, "Duke") != -1 ||
           llSubStringIndex(playerRank, "Count") != -1 ||
           llSubStringIndex(playerRank, "Baron") != -1 ||
           llSubStringIndex(playerRank, "Knight") != -1) {
            isNoble = TRUE;
        }
        else {
            isNoble = FALSE;
        }
    }
    else if(field == "RUBLES") {
        playerRubles = (integer)value;
    }
}

default {
    state_entry() {
        llListen(ARTS_CHANNEL, "", NULL_KEY, "");
        
        // Initialize default values
        initializeSkills();
        
        // Calculate initial cultural reputation
        calculateCulturalReputation();
        
        llOwnerSay("Imperial Arts & Culture Module initialized. Touch to access cultural options.");
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        displayArtsMenu(toucherId);
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == ARTS_CHANNEL) {
            // Main menu options
            if(message == "Practice Art") {
                displayPracticeMenu(id);
            }
            else if(message == "Art Collection") {
                displayCollectionMenu(id);
            }
            else if(message == "Patronage") {
                displayPatronageMenu(id);
            }
            else if(message == "Host Event") {
                displayEventMenu(id);
            }
            else if(message == "Salon") {
                displaySalonMenu(id);
            }
            else if(message == "Movement") {
                displayMovementMenu(id);
            }
            else if(message == "Publications") {
                displayPublicationsMenu(id);
            }
            else if(message == "Back") {
                displayArtsMenu(id);
            }
            // Art practice options
            else if(llListFindList(artForms, [message]) != -1) {
                practiceArt(message);
                displayArtsMenu(id);
            }
            // Collection management
            else if(message == "Purchase Art") {
                // Simple art purchase mechanic
                if(playerRubles >= 5000) {
                    llDialog(id, "Select an artwork to purchase:",
                        ["Landscape (5,000)", "Portrait (10,000)", "Abstract (15,000)", "Back"], ARTS_CHANNEL);
                }
                else {
                    llOwnerSay("You need at least 5,000 rubles to purchase artwork.");
                    displayArtsMenu(id);
                }
            }
            else if(message == "Landscape (5,000)") {
                purchaseArtwork("Russian Landscape", "Ilya Repin", 5000);
                displayArtsMenu(id);
            }
            else if(message == "Portrait (10,000)") {
                purchaseArtwork("Aristocratic Portrait", "Valentin Serov", 10000);
                displayArtsMenu(id);
            }
            else if(message == "Abstract (15,000)") {
                purchaseArtwork("Avant-garde Composition", "Wassily Kandinsky", 15000);
                displayArtsMenu(id);
            }
            else if(message == "View Collection") {
                string report = generateCollectionReport();
                llDialog(id, report, ["Back"], ARTS_CHANNEL);
            }
            // Patronage management
            else if(message == "Patronize Artist") {
                displayArtistSelectionMenu(id);
            }
            else if(message == "View Patronage") {
                string report = generatePatronageReport();
                llDialog(id, report, ["Back"], ARTS_CHANNEL);
            }
            // Salon management
            else if(message == "Add Member") {
                llDialog(id, "Select a category of salon member to add:",
                    ["Poet", "Writer", "Musician", "Painter", "Critic", "Back"], ARTS_CHANNEL);
            }
            else if(message == "Host Salon") {
                if(llGetListLength(literarySalon) >= 6) { // Need at least 2 members
                    llSay(0, playerName + " hosts an elegant literary salon, where the cultural elite discuss art, literature, and philosophy.");
                    
                    // Improve cultural reputation
                    calculateCulturalReputation();
                    
                    llDialog(id, "Your salon gathering is a success. The cultural elite of the city are impressed with your patronage of the arts.", ["Back"], ARTS_CHANNEL);
                }
                else {
                    llOwnerSay("You need more salon members before hosting a gathering. Add at least 2 members first.");
                    displaySalonMenu(id);
                }
            }
            else if(message == "View Salon") {
                string report = generateSalonReport();
                llDialog(id, report, ["Back"], ARTS_CHANNEL);
            }
            // Add salon members by category
            else if(message == "Poet") {
                addSalonMember("Alexander Blok", "Symbolist Poet");
                displaySalonMenu(id);
            }
            else if(message == "Writer") {
                addSalonMember("Maxim Gorky", "Realist Writer");
                displaySalonMenu(id);
            }
            else if(message == "Musician") {
                addSalonMember("Sergei Rachmaninoff", "Composer and Pianist");
                displaySalonMenu(id);
            }
            else if(message == "Painter") {
                addSalonMember("Mikhail Vrubel", "Symbolist Painter");
                displaySalonMenu(id);
            }
            else if(message == "Critic") {
                addSalonMember("Sergei Diaghilev", "Artistic Director and Critic");
                displaySalonMenu(id);
            }
            // Handle artist selection for patronage
            else if(llListFindList(notableArtists, [message]) != -1) {
                // Find artist's art form
                integer index = llListFindList(notableArtists, [message]);
                string artForm = llList2String(notableArtists, index + 1);
                
                addPatronageRelationship(message, artForm);
                displayPatronageMenu(id);
            }
            // Event hosting
            else if(message == "Poetry Reading" || message == "Musical Soiree" || 
                    message == "Art Exhibition" || message == "Literary Discussion" || 
                    message == "Ballet Performance") {
                
                if(playerRubles >= 1000) {
                    hostCulturalEvent(message);
                    llDialog(id, "Your cultural event was a success and has enhanced your reputation in society.", ["Back"], ARTS_CHANNEL);
                }
                else {
                    llOwnerSay("You need at least 1,000 rubles to host a cultural event.");
                    displayArtsMenu(id);
                }
            }
            // Art movement selection
            else if(message == MOVEMENT_SYMBOLISM || message == MOVEMENT_REALISM || 
                    message == MOVEMENT_MODERNISM || message == MOVEMENT_TRADITIONALISM || 
                    message == MOVEMENT_MIR_ISKUSSTVA) {
                
                chooseArtisticMovement(message);
                displayArtsMenu(id);
            }
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == HUD_LINK_MESSAGE_CHANNEL) {
            list params = llParseString2List(str, ["="], []);
            if(llGetListLength(params) == 2) {
                string cmd = llList2String(params, 0);
                string value = llList2String(params, 1);
                
                updatePlayerData(cmd, value);
            }
            // Handle explicit command to show arts menu
            else if(str == "SHOW_ARTS_MENU") {
                displayArtsMenu(id);
            }
        }
    }
}