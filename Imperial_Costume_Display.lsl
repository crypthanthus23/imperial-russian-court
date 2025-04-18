// Imperial Russian Court Roleplay System
// Script: Imperial Costume Display
// Version: 1.0
// Description: Interactive costume display with historical information and recommendations

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer COSTUME_CHANNEL = -8675320; // Specific channel for costume information

// Costume gender types
integer GENDER_MALE = 0;
integer GENDER_FEMALE = 1;
integer GENDER_NEUTRAL = 2;

// Costume rank categories
integer RANK_COMMON = 0;      // Common citizens, merchants, etc.
integer RANK_NOBILITY = 1;    // Lesser nobility
integer RANK_HIGH_NOBLE = 2;  // Counts, barons, etc.
integer RANK_COURT = 3;       // Court positions
integer RANK_ROYAL = 4;       // Royal family
integer RANK_IMPERIAL = 5;    // Tsar, Tsarina, Tsarevich

// Costume occasion types
integer OCCASION_DAILY = 0;      // Everyday wear
integer OCCASION_FORMAL = 1;     // Formal events
integer OCCASION_CEREMONY = 2;   // Ceremonial occasions
integer OCCASION_MILITARY = 3;   // Military uniforms
integer OCCASION_BALL = 4;       // Ball gowns and formal evening wear

// Status variables
integer currentDisplayMode = 0;  // 0=Cycle all, 1=Filter by gender, 2=Filter by rank
integer currentGenderFilter = GENDER_NEUTRAL;
integer currentRankFilter = RANK_NOBILITY;
integer currentOccasionFilter = OCCASION_FORMAL;
integer displayIndex = 0;        // Current costume being displayed
integer cyclePaused = FALSE;     // Is the automatic cycling paused
integer cycleTime = 60;          // Seconds between costume changes
integer listenHandle;            // Handle for the listen event

// Costume details
list costumeNames = [];          // Names of costumes
list costumeDescriptions = [];   // Detailed descriptions
list costumeHistories = [];      // Historical context
list costumeGenders = [];        // Target gender
list costumeRanks = [];          // Minimum rank
list costumeOccasions = [];      // Intended occasion
list costumeImages = [];         // Texture UUIDs for display

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to determine avatar's rank (would connect to HUD system)
// For demonstration, simplified to recognize Tsar and Zarevich
integer getAvatarRank(key avatarKey) {
    // Special case for the Tsar
    if (isTsar(avatarKey)) {
        return RANK_IMPERIAL;
    }
    
    // Special case for the Zarevich
    if (isZarevich(avatarKey)) {
        return RANK_IMPERIAL;
    }
    
    // In a real implementation, would query the Core HUD
    // For demonstration, assume nobility rank
    return RANK_NOBILITY;
}

// Function to determine avatar's gender (would connect to HUD system)
// For demonstration, return neutral to show all costumes
integer getAvatarGender(key avatarKey) {
    // In a real implementation, would query the Core HUD
    return GENDER_NEUTRAL;
}

// Function to initialize costume database
initializeCostumes() {
    // Clear existing lists
    costumeNames = [];
    costumeDescriptions = [];
    costumeHistories = [];
    costumeGenders = [];
    costumeRanks = [];
    costumeOccasions = [];
    costumeImages = [];
    
    // Male Court Uniforms
    costumeNames += ["Imperial Court Uniform - Male"];
    costumeDescriptions += ["Formal green and gold court uniform with decorative embroidery, worn with white breeches and formal shoes. Includes appropriate medals and orders."];
    costumeHistories += ["The male court uniform was standardized under Tsar Nicholas I in 1831 and remained largely unchanged through Nicholas II's reign. The dark green color was traditional for Russian civil servants and courtiers."];
    costumeGenders += [GENDER_MALE];
    costumeRanks += [RANK_COURT];
    costumeOccasions += [OCCASION_FORMAL];
    costumeImages += ["00000000-0000-0000-0000-000000000001"]; // Placeholder UUID, replace with actual texture
    
    // Cavalry Officer Uniform
    costumeNames += ["Imperial Cavalry Officer Uniform"];
    costumeDescriptions += ["Formal cavalry uniform with distinctive blue tunic, red piping, gold epaulettes, and white breeches. Includes saber and appropriate ceremonial accessories."];
    costumeHistories += ["Cavalry regiments held a prestigious position in the Imperial Russian military. Officers were often drawn from nobility, and their uniforms were designed to impress at both military and court functions."];
    costumeGenders += [GENDER_MALE];
    costumeRanks += [RANK_NOBILITY];
    costumeOccasions += [OCCASION_MILITARY];
    costumeImages += ["00000000-0000-0000-0000-000000000002"]; // Placeholder UUID
    
    // Imperial Guard Uniform
    costumeNames += ["Preobrazhensky Guards Parade Uniform"];
    costumeDescriptions += ["Elite guard regiment uniform featuring distinctive dark green tunic with red facings, ceremonial brass helmet with Russian eagle, and white parade breeches. Complete with full ceremonial equipment."];
    costumeHistories += ["The Preobrazhensky Regiment was the most senior guard regiment, founded by Peter the Great. These elite soldiers served as the Tsar's personal guards and wore some of the most splendid uniforms in formal parades and ceremonies."];
    costumeGenders += [GENDER_MALE];
    costumeRanks += [RANK_HIGH_NOBLE];
    costumeOccasions += [OCCASION_CEREMONY];
    costumeImages += ["00000000-0000-0000-0000-000000000003"]; // Placeholder UUID
    
    // Formal Ball Gown
    costumeNames += ["Imperial Court Ball Gown - 1905 Fashion"];
    costumeDescriptions += ["Exquisite evening gown with low décolletage, narrow waist, and long train. Made of finest silk, satin or velvet with extensive beadwork, lace, and embroidery in pastel colors or rich jewel tones."];
    costumeHistories += ["Court ball gowns in the early 1900s followed the fashionable S-shaped silhouette with a defined bust and hips. Noble ladies often ordered their gowns from Paris, though Russian designers were also becoming prominent."];
    costumeGenders += [GENDER_FEMALE];
    costumeRanks += [RANK_NOBILITY];
    costumeOccasions += [OCCASION_BALL];
    costumeImages += ["00000000-0000-0000-0000-000000000004"]; // Placeholder UUID
    
    // Female Court Dress
    costumeNames += ["Ladies' Court Dress (Придворное платье)"];
    costumeDescriptions += ["Formal Russian court dress featuring a fitted velvet bodice, voluminous skirt with long train, and distinctive kokoshnik headdress. Design includes traditional Russian elements with gold embroidery and fur trimming."];
    costumeHistories += ["The Russian court dress was codified under Catherine the Great but updated during the reign of Nicholas II. It remained distinctly Russian while incorporating elements of contemporary fashion. The kokoshnik headdress was mandatory for court presentations."];
    costumeGenders += [GENDER_FEMALE];
    costumeRanks += [RANK_COURT];
    costumeOccasions += [OCCASION_CEREMONY];
    costumeImages += ["00000000-0000-0000-0000-000000000005"]; // Placeholder UUID
    
    // Tsarina's Formal Gown
    costumeNames += ["Tsarina's State Gown"];
    costumeDescriptions += ["Magnificent imperial gown in cream satin with Russian-style overlay in deep blue velvet. Extensively decorated with gold embroidery featuring imperial eagles. Complete with diamond and pearl parure, imperial orders, and full regalia."];
    costumeHistories += ["The Tsarina's formal attire for state occasions balanced Russian tradition with contemporary European fashion. Alexandra Feodorovna's gowns were often created by the finest court dressmakers and featured extensive symbolism in their designs."];
    costumeGenders += [GENDER_FEMALE];
    costumeRanks += [RANK_IMPERIAL];
    costumeOccasions += [OCCASION_CEREMONY];
    costumeImages += ["00000000-0000-0000-0000-000000000006"]; // Placeholder UUID
    
    // Tsar's Military Uniform
    costumeNames += ["Tsar's Colonel-in-Chief Uniform"];
    costumeDescriptions += ["Immaculate military uniform of the regiment for which the Tsar serves as Colonel-in-Chief. Features highest quality fabric with gold embroidery, full decorations, and all imperial orders and medals."];
    costumeHistories += ["Tsar Nicholas II frequently wore military uniforms, reflecting his deep connection to the armed forces. As supreme commander and honorary colonel of multiple regiments, his uniforms were of exquisite quality while maintaining proper military standards."];
    costumeGenders += [GENDER_MALE];
    costumeRanks += [RANK_IMPERIAL];
    costumeOccasions += [OCCASION_MILITARY];
    costumeImages += ["00000000-0000-0000-0000-000000000007"]; // Placeholder UUID
    
    // Merchant Attire
    costumeNames += ["Merchant Class Traditional Attire"];
    costumeDescriptions += ["Prosperous merchant outfit featuring traditional Russian elements: colorful kaftan or long coat, decorative belt, and traditional boots. Indicates wealth while maintaining Russian cultural identity."];
    costumeHistories += ["Wealthy merchants in Imperial Russia maintained traditional Russian dress longer than the nobility, who adopted European styles. Their clothing served as both a status symbol and connection to Russian heritage."];
    costumeGenders += [GENDER_MALE];
    costumeRanks += [RANK_COMMON];
    costumeOccasions += [OCCASION_DAILY];
    costumeImages += ["00000000-0000-0000-0000-000000000008"]; // Placeholder UUID
    
    // Noblewoman's Day Dress
    costumeNames += ["Noblewoman's Day Dress - Belle Époque"];
    costumeDescriptions += ["Elegant day dress in the latest Paris fashion, featuring high neckline, fitted waist, and long skirt. Made of fine fabrics with delicate detailing suitable for morning calls and afternoon social events."];
    costumeHistories += ["Russian noblewomen followed Parisian fashion closely, with dresses arriving from France or being made by French seamstresses working in St. Petersburg. The Belle Époque style emphasized femininity and sophistication."];
    costumeGenders += [GENDER_FEMALE];
    costumeRanks += [RANK_NOBILITY];
    costumeOccasions += [OCCASION_DAILY];
    costumeImages += ["00000000-0000-0000-0000-000000000009"]; // Placeholder UUID
    
    // Grand Duchess Evening Attire
    costumeNames += ["Grand Duchess Evening Ensemble"];
    costumeDescriptions += ["Luxurious evening gown suitable for a Grand Duchess, featuring the finest silks, intricate beadwork, and appropriate jewelry. Design balances modernity with the dignity required of an imperial family member."];
    costumeHistories += ["The Grand Duchesses' evening attire needed to reflect their imperial status while still being fashionable. Their gowns were typically more restrained than those of other court ladies, particularly for the unmarried daughters of the Tsar."];
    costumeGenders += [GENDER_FEMALE];
    costumeRanks += [RANK_ROYAL];
    costumeOccasions += [OCCASION_BALL];
    costumeImages += ["00000000-0000-0000-0000-000000000010"]; // Placeholder UUID
}

// Function to find costumes matching current filters
list getFilteredCostumes() {
    list matches = [];
    integer i;
    integer count = llGetListLength(costumeNames);
    
    for (i = 0; i < count; i++) {
        integer matches_filter = TRUE;
        
        // Apply gender filter if not in "all" mode
        if (currentDisplayMode >= 1 && currentGenderFilter != GENDER_NEUTRAL) {
            integer gender = llList2Integer(costumeGenders, i);
            if (gender != currentGenderFilter && gender != GENDER_NEUTRAL) {
                matches_filter = FALSE;
            }
        }
        
        // Apply rank filter if in rank filter mode
        if (currentDisplayMode >= 2) {
            integer rank = llList2Integer(costumeRanks, i);
            if (rank != currentRankFilter) {
                matches_filter = FALSE;
            }
        }
        
        // Apply occasion filter if in occasion filter mode
        if (currentDisplayMode >= 3) {
            integer occasion = llList2Integer(costumeOccasions, i);
            if (occasion != currentOccasionFilter) {
                matches_filter = FALSE;
            }
        }
        
        if (matches_filter) {
            matches += [i]; // Store the index
        }
    }
    
    return matches;
}

// Function to get costume recommendations for an avatar
list getRecommendations(key avatarKey) {
    list recommendations = [];
    
    // Get avatar attributes
    integer avatarRank = getAvatarRank(avatarKey);
    integer avatarGender = getAvatarGender(avatarKey);
    
    // Find suitable costumes
    integer i;
    integer count = llGetListLength(costumeNames);
    
    for (i = 0; i < count; i++) {
        integer gender = llList2Integer(costumeGenders, i);
        integer rank = llList2Integer(costumeRanks, i);
        
        // Match gender and rank requirements
        if ((gender == avatarGender || gender == GENDER_NEUTRAL) && 
            rank <= avatarRank) {
            recommendations += [i]; // Store the index
        }
    }
    
    return recommendations;
}

// Function to display a costume
displayCostume(integer index) {
    // Validate index
    integer count = llGetListLength(costumeNames);
    if (index < 0 || index >= count) return;
    
    // Get costume details
    string name = llList2String(costumeNames, index);
    string description = llList2String(costumeDescriptions, index);
    string history = llList2String(costumeHistories, index);
    string imageID = llList2String(costumeImages, index);
    
    // Set costume texture on prim face 1 (assumes face 1 is the display panel)
    llSetTexture(imageID, 1);
    
    // Get gender text
    string genderText = "Suitable for all";
    integer gender = llList2Integer(costumeGenders, index);
    if (gender == GENDER_MALE) {
        genderText = "Male attire";
    }
    else if (gender == GENDER_FEMALE) {
        genderText = "Female attire";
    }
    
    // Get rank text
    string rankText = "Commoner suitable";
    integer rank = llList2Integer(costumeRanks, index);
    if (rank == RANK_NOBILITY) {
        rankText = "Nobility rank required";
    }
    else if (rank == RANK_HIGH_NOBLE) {
        rankText = "High nobility rank required";
    }
    else if (rank == RANK_COURT) {
        rankText = "Court position required";
    }
    else if (rank == RANK_ROYAL) {
        rankText = "Royal family only";
    }
    else if (rank == RANK_IMPERIAL) {
        rankText = "Imperial family only";
    }
    
    // Get occasion text
    string occasionText = "Everyday wear";
    integer occasion = llList2Integer(costumeOccasions, index);
    if (occasion == OCCASION_FORMAL) {
        occasionText = "Formal occasions";
    }
    else if (occasion == OCCASION_CEREMONY) {
        occasionText = "Ceremonial events";
    }
    else if (occasion == OCCASION_MILITARY) {
        occasionText = "Military functions";
    }
    else if (occasion == OCCASION_BALL) {
        occasionText = "Balls and evening events";
    }
    
    // Construct and set the display text
    string displayText = name + "\n\n";
    displayText += genderText + " • " + rankText + " • " + occasionText + "\n\n";
    displayText += description + "\n\n";
    displayText += "Historical Context:\n" + history;
    
    // Set the text with appropriate color based on rank
    vector textColor = <0.9, 0.9, 0.9>; // White for common
    
    if (rank == RANK_NOBILITY) {
        textColor = <0.9, 0.8, 0.5>; // Gold for nobility
    }
    else if (rank == RANK_HIGH_NOBLE) {
        textColor = <0.8, 0.6, 0.2>; // Darker gold
    }
    else if (rank == RANK_COURT) {
        textColor = <0.5, 0.7, 0.9>; // Blue for court
    }
    else if (rank == RANK_ROYAL) {
        textColor = <0.8, 0.3, 0.3>; // Red for royal
    }
    else if (rank == RANK_IMPERIAL) {
        textColor = <0.9, 0.2, 0.2>; // Bright red for imperial
    }
    
    llSetText(displayText, textColor, 1.0);
}

// Function to show costume recommendations for an avatar
showRecommendations(key avatarKey, string avatarName) {
    // Get recommendations
    list recommendations = getRecommendations(avatarKey);
    
    if (llGetListLength(recommendations) == 0) {
        llRegionSayTo(avatarKey, 0, "No suitable costume recommendations found for your status.");
        return;
    }
    
    // Prepare recommendations message
    string recText = "Costume Recommendations for " + avatarName + ":\n\n";
    
    integer i;
    integer count = llGetListLength(recommendations);
    // Limit to top 5 recommendations
    integer displayCount = count > 5 ? 5 : count;
    
    for (i = 0; i < displayCount; i++) {
        integer index = llList2Integer(recommendations, i);
        string name = llList2String(costumeNames, index);
        integer occasion = llList2Integer(costumeOccasions, index);
        
        string occasionText = "Everyday wear";
        if (occasion == OCCASION_FORMAL) {
            occasionText = "Formal occasions";
        }
        else if (occasion == OCCASION_CEREMONY) {
            occasionText = "Ceremonial events";
        }
        else if (occasion == OCCASION_MILITARY) {
            occasionText = "Military functions";
        }
        else if (occasion == OCCASION_BALL) {
            occasionText = "Balls and evening events";
        }
        
        recText += "• " + name + " (" + occasionText + ")\n";
    }
    
    // Add a note if there are more recommendations
    if (count > 5) {
        recText += "\n(" + (string)(count - 5) + " more recommendations available)";
    }
    
    // Send recommendations to avatar
    llRegionSayTo(avatarKey, 0, recText);
    
    // If we have recommendations, display the first one
    if (count > 0) {
        integer index = llList2Integer(recommendations, 0);
        displayCostume(index);
        displayIndex = index;
    }
}

// Function to cycle to the next costume
cycleToNextCostume() {
    if (cyclePaused) return;
    
    // Get filtered costume list
    list filtered = getFilteredCostumes();
    integer count = llGetListLength(filtered);
    
    if (count == 0) {
        llSetText("No costumes match the current filters.", <1.0, 0.0, 0.0>, 1.0);
        return;
    }
    
    // Find current index in filtered list
    integer currentFilteredIndex = llListFindList(filtered, [displayIndex]);
    
    // Move to next or wrap around
    integer nextFilteredIndex = (currentFilteredIndex + 1) % count;
    integer nextIndex = llList2Integer(filtered, nextFilteredIndex);
    
    // Display the costume
    displayCostume(nextIndex);
    displayIndex = nextIndex;
}

// Function to set the display mode and filters
setDisplayMode(integer mode, integer genderFilter, integer rankFilter, integer occasionFilter) {
    currentDisplayMode = mode;
    currentGenderFilter = genderFilter;
    currentRankFilter = rankFilter;
    currentOccasionFilter = occasionFilter;
    
    // Get filtered costume list
    list filtered = getFilteredCostumes();
    
    if (llGetListLength(filtered) > 0) {
        // Display the first matching costume
        integer index = llList2Integer(filtered, 0);
        displayCostume(index);
        displayIndex = index;
    }
    else {
        llSetText("No costumes match the current filters.", <1.0, 0.0, 0.0>, 1.0);
    }
}

// Function to parse and process costume commands
processCostumeCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "ADD_COSTUME" && isTsar(senderKey)) {
        // Format: ADD_COSTUME|name|description|history|gender|rank|occasion|imageID
        if (llGetListLength(messageParts) >= 8) {
            string name = llList2String(messageParts, 1);
            string description = llList2String(messageParts, 2);
            string history = llList2String(messageParts, 3);
            integer gender = (integer)llList2String(messageParts, 4);
            integer rank = (integer)llList2String(messageParts, 5);
            integer occasion = (integer)llList2String(messageParts, 6);
            string imageID = llList2String(messageParts, 7);
            
            // Add to costume lists
            costumeNames += [name];
            costumeDescriptions += [description];
            costumeHistories += [history];
            costumeGenders += [gender];
            costumeRanks += [rank];
            costumeOccasions += [occasion];
            costumeImages += [imageID];
            
            llRegionSayTo(senderKey, 0, "Added \"" + name + "\" to the costume display.");
        }
    }
    else if (command == "SET_CYCLE_TIME" && isTsar(senderKey)) {
        // Format: SET_CYCLE_TIME|seconds
        if (llGetListLength(messageParts) >= 2) {
            integer seconds = (integer)llList2String(messageParts, 1);
            if (seconds >= 10) {
                cycleTime = seconds;
                llSetTimerEvent(cycleTime);
                llRegionSayTo(senderKey, 0, "Costume cycle time set to " + (string)cycleTime + " seconds.");
            }
        }
    }
}

default {
    state_entry() {
        // Initialize costume database
        initializeCostumes();
        
        // Start listening for system events
        listenHandle = llListen(COSTUME_CHANNEL, "", NULL_KEY, "");
        
        // Display the first costume
        if (llGetListLength(costumeNames) > 0) {
            displayCostume(0);
            displayIndex = 0;
        }
        
        // Start cycling timer
        llSetTimerEvent(cycleTime);
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Show menu with options
        list options = [
            "Show Recommendations", 
            "All Costumes", 
            "Male Costumes", 
            "Female Costumes"
        ];
        
        // Add rank-based filters
        if (isTsar(toucherKey)) {
            options += ["Imperial Attire"];
        }
        
        options += [
            "Court Attire", 
            "Ball Attire", 
            "Pause/Resume Cycle"
        ];
        
        llDialog(toucherKey, "Select a display option for the costume gallery:", options, COSTUME_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == COSTUME_CHANNEL) {
            // Process menu selections
            if (message == "Show Recommendations") {
                showRecommendations(id, name);
            }
            else if (message == "All Costumes") {
                setDisplayMode(0, GENDER_NEUTRAL, RANK_COMMON, OCCASION_DAILY);
                llRegionSayTo(id, 0, "Displaying all available costumes.");
            }
            else if (message == "Male Costumes") {
                setDisplayMode(1, GENDER_MALE, RANK_COMMON, OCCASION_DAILY);
                llRegionSayTo(id, 0, "Filtering to show male costumes.");
            }
            else if (message == "Female Costumes") {
                setDisplayMode(1, GENDER_FEMALE, RANK_COMMON, OCCASION_DAILY);
                llRegionSayTo(id, 0, "Filtering to show female costumes.");
            }
            else if (message == "Imperial Attire") {
                setDisplayMode(2, GENDER_NEUTRAL, RANK_IMPERIAL, OCCASION_CEREMONY);
                llRegionSayTo(id, 0, "Filtering to show Imperial family attire.");
            }
            else if (message == "Court Attire") {
                setDisplayMode(2, GENDER_NEUTRAL, RANK_COURT, OCCASION_FORMAL);
                llRegionSayTo(id, 0, "Filtering to show court attire.");
            }
            else if (message == "Ball Attire") {
                setDisplayMode(3, GENDER_NEUTRAL, RANK_NOBILITY, OCCASION_BALL);
                llRegionSayTo(id, 0, "Filtering to show ball and evening attire.");
            }
            else if (message == "Pause/Resume Cycle") {
                cyclePaused = !cyclePaused;
                if (cyclePaused) {
                    llRegionSayTo(id, 0, "Costume cycling paused.");
                } else {
                    llRegionSayTo(id, 0, "Costume cycling resumed.");
                    llSetTimerEvent(cycleTime);
                }
            }
            else {
                // May be a costume command
                processCostumeCommand(message, id);
            }
        }
    }
    
    timer() {
        cycleToNextCostume();
    }
    
    on_rez(integer start_param) {
        // Reset when rezzed
        llResetScript();
    }
}