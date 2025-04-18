// Imperial Costume Recommendation Module
// Provides historically accurate costume recommendations based on:
// - Character's rank and title
// - Specific court occasions and events
// - Weather conditions and seasons
// - Time period (Early, Middle, Late Imperial era)
// - Gender and age appropriate styles
// - Regional variations within the Russian Empire

// Constants
integer HUD_LINK_MESSAGE_CHANNEL = 42;
integer TOUCH_CHANNEL = -42;

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
string RANK_MARQUESS = "Marquess/Marchioness";
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
string playerGender = "Unknown";
string playerRank = "";
string playerAge = "Adult";
string currentSeason = SEASON_WINTER; // Default to winter
string currentPeriod = PERIOD_LATE;   // Default to late imperial (1905)

// Costume databases (stored as nested lists)
list maleCoatStyles = [];
list femaleGownStyles = [];
list headwearOptions = [];
list footwearOptions = [];
list accessoryOptions = [];
list militaryUniforms = [];
list clericalVestments = [];
list courtAttire = [];
list formalRegalia = [];

// Initialize costume databases with historically accurate options
initializeCostumeData() {
    // Male coat styles by period and rank
    maleCoatStyles = [
        PERIOD_LATE, RANK_IMPERIAL, "Gold-embroidered dark blue tailcoat with Orders of St. Andrew and St. Alexander Nevsky",
        PERIOD_LATE, RANK_PRINCE, "Navy blue tailcoat with silver embroidery and Order of St. Vladimir",
        PERIOD_LATE, RANK_COUNT, "Black tailcoat with modest embroidery and family crest buttons",
        PERIOD_LATE, RANK_IMPERIAL, OCCASION_MILITARY, "General-Admiral naval uniform with gold epaulettes and full decorations",
        PERIOD_LATE, RANK_DUKE, OCCASION_BALL, "White tie formal wear with decorations and medals on red sash",
        PERIOD_LATE, RANK_COUNT, OCCASION_CASUAL, "Morning coat in gray or black with single decoration",
        PERIOD_LATE, RANK_BARON, OCCASION_SEMIFORMAL, "Dark frock coat with minimal embroidery"
    ];
    
    // Female gown styles by period and rank
    femaleGownStyles = [
        PERIOD_LATE, RANK_IMPERIAL, "Court dress in the Russian style with long train, kokoshnik headdress with pearls and diamonds",
        PERIOD_LATE, RANK_PRINCESS, "White satin gown with silver embroidery, three-arsheen train and tiara",
        PERIOD_LATE, RANK_COUNTESS, "Silk gown with modest train, family jewels and small tiara or hair ornaments",
        PERIOD_LATE, RANK_IMPERIAL, OCCASION_BALL, "Worth gown in pastel silk with crystal embellishments and diamond parure",
        PERIOD_LATE, RANK_DUCHESS, OCCASION_RELIGIOUS, "High-necked silk gown with long sleeves and lace details, covered head",
        PERIOD_LATE, RANK_COUNTESS, OCCASION_CASUAL, "Walking dress in wool or lightweight silk with modest bustle",
        PERIOD_LATE, RANK_BARONESS, OCCASION_MOURNING, "Black bombazine dress with crepe trim and jet jewelry"
    ];
    
    // Headwear options by gender, rank and occasion
    headwearOptions = [
        GENDER_FEMALE, RANK_IMPERIAL, OCCASION_FORMAL, "Diamond and pearl kokoshnik with veil",
        GENDER_FEMALE, RANK_PRINCESS, OCCASION_BALL, "Small diamond tiara with aigrette",
        GENDER_FEMALE, RANK_COUNTESS, OCCASION_CASUAL, "Feathered hat with netting",
        GENDER_MALE, RANK_IMPERIAL, OCCASION_MILITARY, "Gilded helmet with double-headed eagle",
        GENDER_MALE, RANK_PRINCE, OCCASION_FORMAL, "Court bicorn with plumes and cockade",
        GENDER_MALE, RANK_COUNT, OCCASION_CASUAL, "Top hat in black silk"
    ];
    
    // Footwear options by gender and occasion
    footwearOptions = [
        GENDER_FEMALE, OCCASION_BALL, "Satin slippers with small heels and ribbon ties",
        GENDER_FEMALE, OCCASION_CASUAL, "Buttoned leather boots with modest heels",
        GENDER_MALE, OCCASION_FORMAL, "Patent leather court shoes with silver buckles",
        GENDER_MALE, OCCASION_MILITARY, "Polished thigh-high boots with spurs"
    ];
    
    // Uniform regulations for different military ranks
    militaryUniforms = [
        "General", "Dark green uniform with gold epaulettes, red facings, gold aiguillette, and Orders of St. George and St. Vladimir",
        "Colonel", "Dark green uniform with silver epaulettes, regiment-specific facings, and Order of St. Anna",
        "Captain", "Dark green uniform with small epaulettes and single decoration",
        "Imperial Guard", "Special parade uniform with brass breastplate and helmet with plume"
    ];
    
    // Religious vestments and clerical wear
    clericalVestments = [
        "Metropolitan", "Gold and purple sakkos with omophorion and mitre with cross",
        "Bishop", "Purple vestments with panagia and staff",
        "Priest", "Simple black cassock with pectoral cross and skufia"
    ];
    
    // Court attire for special functions
    courtAttire = [
        GENDER_MALE, OCCASION_CORONATION, "Embroidered velvet kaftans in imperial blue with gold thread",
        GENDER_FEMALE, OCCASION_CORONATION, "Russian court dress with heavy embroidery and jeweled kokoshnik"
    ];
    
    // Formal regalia for highest ranks
    formalRegalia = [
        RANK_IMPERIAL, "Purple velvet mantle with ermine trim, gold chain of the Order of St. Andrew",
        RANK_PRINCE, "Shorter crimson mantle with miniver lining, gold chain of family order",
        RANK_DUKE, "Short cape in family colors with gold braid and decorations"
    ];
}

// Recommend costume based on player data and occasion
string recommendCostume(string occasion, string season) {
    string recommendation = "Recommended attire for " + playerName + " (" + playerGender + ", " + playerRank + "):\n\n";
    
    if(playerGender == GENDER_MALE) {
        // Process male recommendations
        recommendation += "Coat: ";
        recommendation += findMatchingStyle(maleCoatStyles, occasion, season);
        recommendation += "\n\n";
        
        recommendation += "Headwear: ";
        recommendation += findMatchingHeadwear(occasion);
        recommendation += "\n\n";
        
        recommendation += "Footwear: ";
        recommendation += findMatchingFootwear(occasion);
        recommendation += "\n\n";
        
        // Special military uniform if appropriate
        if(occasion == OCCASION_MILITARY || playerRank == "General" || playerRank == "Colonel" || playerRank == "Captain") {
            recommendation += "Military Specifics: ";
            recommendation += findMilitaryUniform();
            recommendation += "\n\n";
        }
    }
    else {
        // Process female recommendations
        recommendation += "Gown: ";
        recommendation += findMatchingStyle(femaleGownStyles, occasion, season);
        recommendation += "\n\n";
        
        recommendation += "Headwear: ";
        recommendation += findMatchingHeadwear(occasion);
        recommendation += "\n\n";
        
        recommendation += "Footwear: ";
        recommendation += findMatchingFootwear(occasion);
        recommendation += "\n\n";
    }
    
    // Special recommendations based on occasion
    if(occasion == OCCASION_MOURNING) {
        recommendation += "Mourning Etiquette: Black attire is mandatory. Family members should observe full mourning (all black with no jewelry except jet). Court mourning requires black armbands for men and black dresses for women.\n\n";
    }
    else if(occasion == OCCASION_RELIGIOUS) {
        recommendation += "Religious Etiquette: Women must cover their heads with veils or scarves. Men should remove headwear. Modest, conservative styling is expected.\n\n";
    }
    else if(occasion == OCCASION_BALL) {
        recommendation += "Ball Etiquette: Full decorations and orders must be worn. White gloves are mandatory. Ladies should wear appropriate jewelry according to rank.\n\n";
    }
    
    // Weather-specific additions
    if(season == SEASON_WINTER) {
        recommendation += "Winter Addition: Fur-lined cloak or shuba in sable or fox. Fur muffs for ladies. Felt-lined boots.\n\n";
    }
    else if(season == SEASON_SUMMER) {
        recommendation += "Summer Modification: Lighter fabrics permitted. Men may wear white trousers for some occasions. Ladies may opt for parasols outdoors.\n\n";
    }
    
    // Add historical accuracy note
    recommendation += "Historical Note: This recommendation is accurate for the " + currentPeriod + " era of the Russian Imperial Court.";
    
    return recommendation;
}

// Find matching style from database
string findMatchingStyle(list stylesList, string occasion, string season) {
    integer i;
    integer length = llGetListLength(stylesList);
    
    // First try to find an exact match with period, rank, and occasion
    for(i = 0; i < length - 2; i += 3) {
        if(llList2String(stylesList, i) == currentPeriod && 
           llList2String(stylesList, i+1) == playerRank && 
           llList2String(stylesList, i+2) == occasion) {
            return llList2String(stylesList, i+3);
        }
    }
    
    // If no exact match, try to find by period and rank only
    for(i = 0; i < length - 1; i += 2) {
        if(llList2String(stylesList, i) == currentPeriod && 
           llList2String(stylesList, i+1) == playerRank) {
            return llList2String(stylesList, i+2);
        }
    }
    
    // If still no match, find closest match by rank precedence
    list rankOrder = [RANK_IMPERIAL, RANK_PRINCE, RANK_DUKE, RANK_MARQUESS, 
                     RANK_COUNT, RANK_BARON, RANK_KNIGHT, RANK_GENTRY];
    
    integer playerRankIndex = llListFindList(rankOrder, [playerRank]);
    
    // If player rank not found in order list, default to gentry
    if(playerRankIndex == -1) playerRankIndex = 7; // index of RANK_GENTRY
    
    // Try to find closest higher rank that has a style
    integer j;
    for(j = playerRankIndex - 1; j >= 0; j--) {
        string higherRank = llList2String(rankOrder, j);
        
        for(i = 0; i < length - 1; i += 2) {
            if(llList2String(stylesList, i) == currentPeriod && 
               llList2String(stylesList, i+1) == higherRank) {
                return "A simplified version of " + llList2String(stylesList, i+2) + " (appropriate for your rank)";
            }
        }
    }
    
    return "No specific recommendation found for your rank and occasion. Please consult a court dresser.";
}

// Find matching headwear
string findMatchingHeadwear(string occasion) {
    integer i;
    integer length = llGetListLength(headwearOptions);
    
    // Try to find exact match
    for(i = 0; i < length - 2; i += 3) {
        if(llList2String(headwearOptions, i) == playerGender && 
           llList2String(headwearOptions, i+1) == playerRank && 
           llList2String(headwearOptions, i+2) == occasion) {
            return llList2String(headwearOptions, i+3);
        }
    }
    
    // Try to find by gender and occasion
    for(i = 0; i < length - 2; i += 3) {
        if(llList2String(headwearOptions, i) == playerGender && 
           llList2String(headwearOptions, i+2) == occasion) {
            return llList2String(headwearOptions, i+3);
        }
    }
    
    // Try to find by gender only
    for(i = 0; i < length - 2; i += 3) {
        if(llList2String(headwearOptions, i) == playerGender) {
            return llList2String(headwearOptions, i+3);
        }
    }
    
    return "Standard " + occasion + " headwear appropriate for your rank";
}

// Find matching footwear
string findMatchingFootwear(string occasion) {
    integer i;
    integer length = llGetListLength(footwearOptions);
    
    // Try to find exact match
    for(i = 0; i < length - 1; i += 2) {
        if(llList2String(footwearOptions, i) == playerGender && 
           llList2String(footwearOptions, i+1) == occasion) {
            return llList2String(footwearOptions, i+2);
        }
    }
    
    // Try to find by gender only
    for(i = 0; i < length - 1; i += 2) {
        if(llList2String(footwearOptions, i) == playerGender) {
            return llList2String(footwearOptions, i+2);
        }
    }
    
    if(playerGender == GENDER_MALE) {
        return "Polished black leather boots suitable for court wear";
    } else {
        return "Leather or satin shoes appropriate for the occasion";
    }
}

// Find military uniform if applicable
string findMilitaryUniform() {
    integer i;
    integer length = llGetListLength(militaryUniforms);
    
    for(i = 0; i < length; i += 2) {
        if(llList2String(militaryUniforms, i) == playerRank) {
            return llList2String(militaryUniforms, i+1);
        }
    }
    
    return "Standard military uniform appropriate for your rank";
}

// Update cache from HUD
updateCache(string name, string value) {
    if(name == "PLAYERNAME") {
        playerName = value;
    }
    else if(name == "PLAYERKEY") {
        playerKey = (key)value;
    }
    else if(name == "GENDER") {
        playerGender = value;
    }
    else if(name == "RANK") {
        playerRank = value;
    }
    else if(name == "SEASON") {
        currentSeason = value;
    }
    else if(name == "PERIOD") {
        currentPeriod = value;
    }
    else if(name == "AGE") {
        playerAge = value;
    }
}

default {
    state_entry() {
        llListen(TOUCH_CHANNEL, "", NULL_KEY, "");
        initializeCostumeData();
        
        // Default values for testing
        playerGender = GENDER_MALE;
        playerRank = RANK_COUNT;
        playerName = "Default Courtier";
        currentPeriod = PERIOD_LATE;
        currentSeason = SEASON_WINTER;
        
        llOwnerSay("Imperial Costume Recommendation Module initialized. Touch to receive recommendations.");
    }
    
    touch_start(integer total_number) {
        llDialog(llDetectedKey(0), "Select costume occasion:", 
            [OCCASION_FORMAL, OCCASION_SEMIFORMAL, OCCASION_CASUAL, 
             OCCASION_MILITARY, OCCASION_BALL, OCCASION_RELIGIOUS,
             OCCASION_MOURNING, OCCASION_CORONATION], TOUCH_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == TOUCH_CHANNEL) {
            string occasion = message;
            string recommendation = recommendCostume(occasion, currentSeason);
            llDialog(id, recommendation, ["Change Gender", "Change Rank", "Change Season", "Close"], TOUCH_CHANNEL);
        }
        else if(message == "Change Gender") {
            if(playerGender == GENDER_MALE) {
                playerGender = GENDER_FEMALE;
            } else {
                playerGender = GENDER_MALE;
            }
            llOwnerSay("Gender changed to: " + playerGender);
        }
        else if(message == "Change Rank") {
            // Cycle through ranks
            if(playerRank == RANK_IMPERIAL) playerRank = RANK_PRINCE;
            else if(playerRank == RANK_PRINCE) playerRank = RANK_DUKE;
            else if(playerRank == RANK_DUKE) playerRank = RANK_COUNT;
            else if(playerRank == RANK_COUNT) playerRank = RANK_BARON;
            else if(playerRank == RANK_BARON) playerRank = RANK_KNIGHT;
            else if(playerRank == RANK_KNIGHT) playerRank = RANK_GENTRY;
            else playerRank = RANK_IMPERIAL;
            
            llOwnerSay("Rank changed to: " + playerRank);
        }
        else if(message == "Change Season") {
            // Cycle through seasons
            if(currentSeason == SEASON_WINTER) currentSeason = SEASON_SPRING;
            else if(currentSeason == SEASON_SPRING) currentSeason = SEASON_SUMMER;
            else if(currentSeason == SEASON_SUMMER) currentSeason = SEASON_AUTUMN;
            else currentSeason = SEASON_WINTER;
            
            llOwnerSay("Season changed to: " + currentSeason);
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == HUD_LINK_MESSAGE_CHANNEL) {
            list params = llParseString2List(str, ["="], []);
            if(llGetListLength(params) == 2) {
                string cmd = llList2String(params, 0);
                string value = llList2String(params, 1);
                
                updateCache(cmd, value);
            }
        }
    }
}