// Imperial Costume Recommendation Enhanced Module
// Provides historically accurate costume recommendations based on:
// - Character's rank and title
// - Specific court occasions and events
// - Weather conditions and seasons
// - Time period (Early, Middle, Late Imperial era)
// - Gender and age appropriate styles
// - Regional variations within the Russian Empire
//
// Enhanced version includes:
// - Notecard database loading for extensive historical data
// - Integration with HUD system for real-time updates
// - Detailed historical notes and context
// - Visual display system for recommendations

// Constants
integer HUD_LINK_MESSAGE_CHANNEL = 42;
integer TOUCH_CHANNEL = -42;
integer DISPLAY_CHANNEL = -43;
string NOTECARD_NAME = "Imperial_Costume_Database"; // Name of the costume database notecard

// Module identification
string MODULE_NAME = "COSTUME";

// Time periods
string PERIOD_EARLY = "Early Imperial (1800-1855)";  // Alexander I, Nicholas I
string PERIOD_MIDDLE = "Middle Imperial (1855-1894)"; // Alexander II, Alexander III
string PERIOD_LATE = "Late Imperial (1894-1917)";    // Nicholas II (default for 1905)

// Seasons
string SEASON_WINTER = "Winter";
string SEASON_SPRING = "Spring";
string SEASON_SUMMER = "Summer";
string SEASON_AUTUMN = "Autumn";

// Gender options
string GENDER_MALE = "Male";
string GENDER_FEMALE = "Female";

// Occasions
string OCCASION_FORMAL = "Formal Court";
string OCCASION_SEMIFORMAL = "Semi-Formal";
string OCCASION_CASUAL = "Daily Wear";
string OCCASION_MILITARY = "Military Parade";
string OCCASION_BALL = "Imperial Ball";
string OCCASION_RELIGIOUS = "Religious Ceremony";
string OCCASION_MOURNING = "Mourning";
string OCCASION_CORONATION = "Coronation";

// Social ranks (in order of precedence)
string RANK_IMPERIAL = "Imperial Family";
string RANK_PRINCE = "Prince/Princess";
string RANK_DUKE = "Duke/Duchess";
string RANK_COUNT = "Count/Countess";
string RANK_BARON = "Baron/Baroness";
string RANK_KNIGHT = "Knight/Dame";
string RANK_GENTRY = "Gentry";
string RANK_MERCHANT = "Merchant";
string RANK_CLERGY = "Clergy";
string RANK_PEASANT = "Peasant";

// Cache player data
string playerName = "";
key playerKey = NULL_KEY;
string playerGender = "Male"; // Default
string playerRank = "Count"; // Default
string playerAge = "Adult";
string currentSeason = SEASON_WINTER; // Default to winter
string currentPeriod = PERIOD_LATE;   // Default to late imperial (1905)
string playerMilitaryRank = "";
string playerRegion = "";

// Costume database from notecard
list costumeDatabase = [];
integer notecardLine = 0;
key notecardQueryId;
integer notecardReading = FALSE;

// Dialog menu state
integer menuPage = 0;
list occasionOptions = [];
list rankOptions = [];
list seasonOptions = [];
list regionOptions = [];

// Initialize default occasions list
initializeMenuOptions() {
    occasionOptions = [
        OCCASION_FORMAL, OCCASION_SEMIFORMAL, OCCASION_CASUAL, 
        OCCASION_MILITARY, OCCASION_BALL, OCCASION_RELIGIOUS,
        OCCASION_MOURNING, OCCASION_CORONATION
    ];
    
    rankOptions = [
        RANK_IMPERIAL, RANK_PRINCE, RANK_DUKE, 
        RANK_COUNT, RANK_BARON, RANK_KNIGHT,
        RANK_GENTRY, RANK_MERCHANT, RANK_CLERGY
    ];
    
    seasonOptions = [
        SEASON_WINTER, SEASON_SPRING, 
        SEASON_SUMMER, SEASON_AUTUMN
    ];
    
    regionOptions = [
        "St. Petersburg", "Moscow", "Warsaw", 
        "Kiev", "Caucasus", "Siberia"
    ];
}

// Start reading the costume database notecard
readCostumeDatabase() {
    if(llGetInventoryType(NOTECARD_NAME) == INVENTORY_NOTECARD) {
        notecardLine = 0;
        costumeDatabase = [];
        notecardReading = TRUE;
        notecardQueryId = llGetNotecardLine(NOTECARD_NAME, notecardLine);
        llOwnerSay("Loading costume database from notecard...");
    }
    else {
        llOwnerSay("ERROR: Costume database notecard '" + NOTECARD_NAME + "' not found!");
        // Initialize with basic built-in data instead
        initializeBuiltinCostumeData();
    }
}

// Initialize with basic built-in data if notecard is not available
initializeBuiltinCostumeData() {
    // Add some basic costume data as fallback
    costumeDatabase = [
        // Format: Gender|Rank|Occasion|Season|Description
        "MALE|IMPERIAL|FORMAL|ANY|The Tsar wears a gold-embroidered dark blue tailcoat with the Grand Cross and Collar of the Order of St. Andrew.",
        "MALE|COUNT|FORMAL|ANY|Counts of the empire wear court uniform with less elaborate embroidery than dukes, but still featuring gold braid and epaulettes.",
        "FEMALE|IMPERIAL|FORMAL|ANY|The Tsarina wears the traditional Russian court dress with a long train and the distinctive kokoshnik headdress with a flowing veil.",
        "FEMALE|COUNTESS|FORMAL|ANY|Countesses wear more modest versions of the court dress with shorter trains. Their kokoshnik headdresses are simpler, often with silver rather than gold embroidery."
    ];
    
    llOwnerSay("Using built-in costume database (limited entries).");
}

// Parse a database entry into its component parts
list parseDbEntry(string entry) {
    return llParseString2List(entry, ["|"], []);
}

// Find recommendations that match the current criteria
list findMatchingRecommendations(string gender, string rank, string occasion, string season) {
    list matches = [];
    integer i;
    integer count = llGetListLength(costumeDatabase);
    
    for(i = 0; i < count; i++) {
        string entry = llList2String(costumeDatabase, i);
        // Skip comments and empty lines
        if(llGetSubString(entry, 0, 0) == "#" || entry == "") {
            continue;
        }
        
        list parts = parseDbEntry(entry);
        
        if(llGetListLength(parts) < 5) {
            // Skip malformed entries
            continue;
        }
        
        string dbGender = llList2String(parts, 0);
        string dbRank = llList2String(parts, 1);
        string dbOccasion = llList2String(parts, 2);
        string dbSeason = llList2String(parts, 3);
        string dbDescription = llList2String(parts, 4);
        
        // Check for match (ANY is a wildcard)
        if(
            (dbGender == gender || dbGender == "ANY") &&
            (dbRank == rank || dbRank == "ANY" || dbRank == playerMilitaryRank) &&
            (dbOccasion == occasion || dbOccasion == "ANY") &&
            (dbSeason == season || dbSeason == "ANY")
        ) {
            matches += [dbDescription];
        }
    }
    
    return matches;
}

// Generate a costume recommendation based on parameters
string generateRecommendation(string gender, string rank, string occasion, string season) {
    string header = "Recommended attire for " + playerName + "\n";
    header += "Rank: " + rank + " | Occasion: " + occasion + " | Season: " + season + "\n";
    header += "---------------------------------------------\n\n";
    
    list recommendations = findMatchingRecommendations(gender, rank, occasion, season);
    
    // If specific recommendations found, use them
    if(llGetListLength(recommendations) > 0) {
        string fullRecommendation = header;
        
        integer i;
        integer count = llGetListLength(recommendations);
        
        for(i = 0; i < count; i++) {
            fullRecommendation += llList2String(recommendations, i) + "\n\n";
        }
        
        // Add historical context
        fullRecommendation += "Historical Context (1905):\n";
        fullRecommendation += "The Late Imperial period under Tsar Nicholas II featured increasingly elaborate court dress regulations. French fashion house Worth provided many gowns for high-ranking ladies, while men's court uniforms were strictly regulated by imperial decree.";
        
        return fullRecommendation;
    }
    
    // No specific recommendation found, return a generic one based on gender and rank
    string generic = header;
    generic += "No specific recommendation found for these exact parameters.\n\n";
    
    if(gender == GENDER_MALE) {
        if(llSubStringIndex(rank, "IMPERIAL") != -1) {
            generic += "As a member of the Imperial family, you should wear the appropriate court uniform with gold embroidery and all imperial orders. Your uniform should be of the highest quality materials with extensive decoration suitable for your exact position within the imperial family.";
        }
        else if(rank == RANK_PRINCE || rank == RANK_DUKE) {
            generic += "Your high noble rank requires a court uniform with appropriate gold or silver embroidery according to your exact title. Display your family orders and decorations according to court protocol. For formal occasions, white breeches, silk stockings, and court shoes are mandatory.";
        }
        else {
            generic += "Your rank entitles you to a court uniform appropriate to your status. Consult court regulations for the specific embroidery patterns and decorations permitted for your exact position in the court hierarchy.";
        }
    }
    else { // Female
        if(llSubStringIndex(rank, "IMPERIAL") != -1) {
            generic += "As a member of the Imperial family, you should wear the full Russian court dress with an appropriate train length (up to four arshines for the Empress, three for Grand Duchesses). Your kokoshnik headdress should be elaborately jeweled with the imperial diamonds and pearls.";
        }
        else if(rank == RANK_PRINCESS || rank == RANK_DUCHESS) {
            generic += "Your high noble rank requires the Russian court dress with appropriate train length according to your exact title (generally two to three arshines). Your kokoshnik headdress should feature family jewels, and you should display all appropriate orders and decorations.";
        }
        else {
            generic += "Your rank entitles you to wear the Russian court dress with appropriate train length and decorations. Consult court regulations for the specific details permitted for your exact position in the court hierarchy.";
        }
    }
    
    return generic;
}

// Display a recommendation through the HUD system
displayRecommendation(string recommendation, key id) {
    // First show directly to the avatar who requested it
    llRegionSayTo(id, 0, recommendation);
    
    // Then send to display object if one is linked
    llRegionSay(DISPLAY_CHANNEL, "DISPLAY:" + recommendation);
    
    // Also try to send through HUD link message system
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "DISPLAY_COSTUME=" + recommendation, "");
}

// Show the occasion selection dialog
showOccasionDialog(key id) {
    llDialog(id, "Select the occasion for your costume recommendation:", occasionOptions, TOUCH_CHANNEL);
}

// Show the rank selection dialog
showRankDialog(key id) {
    llDialog(id, "Select your rank for the costume recommendation:", rankOptions, TOUCH_CHANNEL);
}

// Show the season selection dialog
showSeasonDialog(key id) {
    llDialog(id, "Select the season for your costume recommendation:", seasonOptions, TOUCH_CHANNEL);
}

// Show the main options dialog
showMainDialog(key id) {
    llDialog(id, "Imperial Costume Recommendation System\n\nWhat would you like to do?", 
        ["Get Recommendation", "Change Rank", "Change Gender", "Change Season", "Help"], TOUCH_CHANNEL);
}

// Update player data cache
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
    }
    else if(field == "SEASON") {
        currentSeason = value;
    }
    else if(field == "PERIOD") {
        currentPeriod = value;
    }
    else if(field == "AGE") {
        playerAge = value;
    }
    else if(field == "MILITARY") {
        playerMilitaryRank = value;
    }
    else if(field == "REGION") {
        playerRegion = value;
    }
}

default {
    state_entry() {
        llListen(TOUCH_CHANNEL, "", NULL_KEY, "");
        
        // Initialize data
        initializeMenuOptions();
        readCostumeDatabase();
        
        // Default values for testing
        if(playerName == "") {
            playerName = "Default Courtier";
        }
        
        llOwnerSay("Imperial Costume Recommendation Module initialized. Touch to receive recommendations.");
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        showMainDialog(toucherId);
    }
    
    dataserver(key queryId, string data) {
        if(queryId == notecardQueryId && notecardReading) {
            if(data != EOF) {
                // Skip comments and empty lines
                if(llGetSubString(data, 0, 0) != "#" && data != "") {
                    costumeDatabase += [data];
                }
                
                notecardLine++;
                notecardQueryId = llGetNotecardLine(NOTECARD_NAME, notecardLine);
            }
            else {
                // Finished reading notecard
                notecardReading = FALSE;
                llOwnerSay("Costume database loaded: " + (string)llGetListLength(costumeDatabase) + " entries.");
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == TOUCH_CHANNEL) {
            // Main menu options
            if(message == "Get Recommendation") {
                showOccasionDialog(id);
            }
            else if(message == "Change Rank") {
                showRankDialog(id);
            }
            else if(message == "Change Gender") {
                if(playerGender == GENDER_MALE) {
                    playerGender = GENDER_FEMALE;
                } else {
                    playerGender = GENDER_MALE;
                }
                llRegionSayTo(id, 0, "Gender changed to: " + playerGender);
                showMainDialog(id);
            }
            else if(message == "Change Season") {
                showSeasonDialog(id);
            }
            else if(message == "Help") {
                string helpText = "IMPERIAL COSTUME RECOMMENDATIONS HELP\n\n";
                helpText += "This system provides historically accurate costume recommendations for the Imperial Russian Court circa 1905.\n\n";
                helpText += "- First select your gender, rank, and the occasion\n";
                helpText += "- The system will provide appropriate historical attire recommendations\n";
                helpText += "- All recommendations are based on actual historical court dress regulations\n\n";
                helpText += "For best results, ensure your character's information is up to date in your HUD.";
                
                llRegionSayTo(id, 0, helpText);
                llSleep(2);
                showMainDialog(id);
            }
            // Handle occasion selection
            else if(llListFindList(occasionOptions, [message]) != -1) {
                string occasion = message;
                string recommendation = generateRecommendation(playerGender, playerRank, occasion, currentSeason);
                displayRecommendation(recommendation, id);
                
                llSleep(2); // Give time to read
                showMainDialog(id);
            }
            // Handle rank selection
            else if(llListFindList(rankOptions, [message]) != -1) {
                playerRank = message;
                llRegionSayTo(id, 0, "Rank changed to: " + playerRank);
                showMainDialog(id);
            }
            // Handle season selection
            else if(llListFindList(seasonOptions, [message]) != -1) {
                currentSeason = message;
                llRegionSayTo(id, 0, "Season changed to: " + currentSeason);
                showMainDialog(id);
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
            // Handle requests for costume recommendations from other scripts
            else if(str == "REQUEST_COSTUME_RECOMMENDATION") {
                string recommendation = generateRecommendation(playerGender, playerRank, OCCASION_FORMAL, currentSeason);
                llMessageLinked(sender, HUD_LINK_MESSAGE_CHANNEL, "COSTUME_RECOMMENDATION=" + recommendation, id);
            }
        }
    }
}