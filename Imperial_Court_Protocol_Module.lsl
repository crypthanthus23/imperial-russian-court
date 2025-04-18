/**
 * Imperial Court Protocol and Etiquette Module
 * Part of the Imperial Russian Court RP System
 * Created: April 2025
 * 
 * This module manages the strict protocols, ceremonies, and etiquette
 * of the Imperial Russian Court circa 1905, with historical accuracy
 * for court functions, protocols, and social hierarchies.
 */

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II UUID
key TSAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Tsarevich Aleksei UUID
integer HUD_LINK_MESSAGE_CHANNEL = -55555; // Communication with other modules
integer DIALOG_CHANNEL; // Will be set dynamically
string VERSION = "1.0.0";

// Court ranks and precedence (Table of Ranks - 1905 version)
list COURT_RANKS = [
    "Chancellor (Class I)",
    "Actual Privy Councillor (Class II)",
    "Privy Councillor (Class III)",
    "Actual State Councillor (Class IV)",
    "State Councillor (Class V)",
    "Collegiate Councillor (Class VI)",
    "Court Councillor (Class VII)",
    "Collegiate Assessor (Class VIII)",
    "Titular Councillor (Class IX)",
    "Collegiate Secretary (Class X)",
    "Court Registrar (Class XIV)"
];

// Court positions in the Imperial Household
list COURT_POSITIONS = [
    "Master of Ceremonies",
    "Grand Marshal of the Court",
    "Ober-Hofmeister",
    "Ober-Schenk",
    "Ober-Jägermeister",
    "Ober-Stallmeister",
    "Ober-Kammerherr",
    "Kammerherr (Chamberlain)",
    "Kammer-Junker (Gentleman of the Chamber)",
    "Hoffräulein (Lady-in-Waiting)",
    "Kammerfräulein (Maid of Honor)"
];

// Court ceremonies and events
list COURT_CEREMONIES = [
    "Winter Palace New Year's Levee",
    "Blessing of the Waters (Epiphany)",
    "Imperial Easter Egg Presentation",
    "Opening of the State Duma",
    "Tsarskoye Selo Court Reception",
    "Imperial Birthday Celebrations",
    "Diplomatic Corps Reception",
    "Military Parade and Review",
    "Grand Court Ball",
    "State Dinner",
    "Private Imperial Tea"
];

// Court clothing and dress code requirements
list COURT_ATTIRE = [
    "Men's Gala Court Uniform",
    "Ladies' Russian Court Dress",
    "Formal Military Uniform",
    "Court Ball Attire",
    "Everyday Court Dress",
    "Winter Palace Ceremonial Dress",
    "Summer Palace Informal Attire",
    "Orthodox Ceremony Attire",
    "State Mourning Dress",
    "Afternoon Reception Attire"
];

// Appropriate formal addresses
list FORMAL_ADDRESSES = [
    "Your Imperial Majesty", // For Tsar and Tsarina
    "Your Imperial Highness", // For immediate imperial family
    "Your Highness", // For grand dukes and duchesses
    "Your Serene Highness", // For certain princes
    "Your Excellency", // For high officials (Class I-III)
    "Your Honor", // For mid-rank officials (Class IV-VIII)
    "Your Nobility", // For lower officials (Class IX-XIV)
    "Your Reverence" // For clergy
];

// State variables
integer listener;
key ownerKey;
string playerRank = "Unranked Visitor";
string playerPosition = "None";
integer playerEtiquetteLevel = 50; // 0-100 scale
integer menuPage = 0;
integer ITEMS_PER_PAGE = 6;
integer imperialPresence = FALSE; // Whether Tsar or Tsarevich is present

// Helper Functions
init()
{
    DIALOG_CHANNEL = -1 - (integer)("0x" + llGetSubString((string)llGetKey(), -8, -1));
    ownerKey = llGetOwner();
    
    // Special handling for imperial family
    if(ownerKey == TSAR_UUID) {
        playerRank = "Emperor of All Russia";
        playerPosition = "Sovereign";
        playerEtiquetteLevel = 100;
    } else if(ownerKey == TSAREVICH_UUID) {
        playerRank = "Tsarevich";
        playerPosition = "Heir Apparent";
        playerEtiquetteLevel = 95;
    }
    
    llOwnerSay("Imperial Court Protocol Module v" + VERSION + " initialized.");
}

resetListeners()
{
    llListenRemove(listener);
}

showMainMenu()
{
    resetListeners();
    list buttons = [
        "Court Protocols", "Etiquette Guide", "Ceremonies",
        "Court Dress", "Your Status", "Practice Etiquette"
    ];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Imperial Court Protocol Module\nYour Rank: " + playerRank + 
             "\nPosition: " + playerPosition + 
             "\nEtiquette Level: " + (string)playerEtiquetteLevel + "/100", buttons, DIALOG_CHANNEL);
}

showRanksMenu(integer page)
{
    resetListeners();
    integer totalRanks = llGetListLength(COURT_RANKS);
    integer startIdx = page * ITEMS_PER_PAGE;
    integer endIdx = startIdx + ITEMS_PER_PAGE - 1;
    if(endIdx >= totalRanks) endIdx = totalRanks - 1;
    
    list buttons = [];
    integer i;
    for(i = startIdx; i <= endIdx; i++) {
        buttons += [llList2String(COURT_RANKS, i)];
    }
    
    // Add navigation buttons
    if(page > 0) buttons += ["◄ Previous"];
    buttons += ["Main Menu"];
    if(endIdx < totalRanks - 1) buttons += ["Next ►"];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Court Ranks (Table of Ranks)\nPage " + (string)(page+1) + "/" + 
             (string)((totalRanks + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE), buttons, DIALOG_CHANNEL);
}

showPositionsMenu(integer page)
{
    resetListeners();
    integer totalPositions = llGetListLength(COURT_POSITIONS);
    integer startIdx = page * ITEMS_PER_PAGE;
    integer endIdx = startIdx + ITEMS_PER_PAGE - 1;
    if(endIdx >= totalPositions) endIdx = totalPositions - 1;
    
    list buttons = [];
    integer i;
    for(i = startIdx; i <= endIdx; i++) {
        buttons += [llList2String(COURT_POSITIONS, i)];
    }
    
    // Add navigation buttons
    if(page > 0) buttons += ["◄ Previous"];
    buttons += ["Main Menu"];
    if(endIdx < totalPositions - 1) buttons += ["Next ►"];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Court Positions in the Imperial Household\nPage " + (string)(page+1) + "/" + 
             (string)((totalPositions + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE), buttons, DIALOG_CHANNEL);
}

showCeremoniesMenu(integer page)
{
    resetListeners();
    integer totalCeremonies = llGetListLength(COURT_CEREMONIES);
    integer startIdx = page * ITEMS_PER_PAGE;
    integer endIdx = startIdx + ITEMS_PER_PAGE - 1;
    if(endIdx >= totalCeremonies) endIdx = totalCeremonies - 1;
    
    list buttons = [];
    integer i;
    for(i = startIdx; i <= endIdx; i++) {
        buttons += [llList2String(COURT_CEREMONIES, i)];
    }
    
    // Add navigation buttons
    if(page > 0) buttons += ["◄ Previous"];
    buttons += ["Main Menu"];
    if(endIdx < totalCeremonies - 1) buttons += ["Next ►"];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Court Ceremonies and Events\nPage " + (string)(page+1) + "/" + 
             (string)((totalCeremonies + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE), buttons, DIALOG_CHANNEL);
}

showAttireMenu(integer page)
{
    resetListeners();
    integer totalAttire = llGetListLength(COURT_ATTIRE);
    integer startIdx = page * ITEMS_PER_PAGE;
    integer endIdx = startIdx + ITEMS_PER_PAGE - 1;
    if(endIdx >= totalAttire) endIdx = totalAttire - 1;
    
    list buttons = [];
    integer i;
    for(i = startIdx; i <= endIdx; i++) {
        buttons += [llList2String(COURT_ATTIRE, i)];
    }
    
    // Add navigation buttons
    if(page > 0) buttons += ["◄ Previous"];
    buttons += ["Main Menu"];
    if(endIdx < totalAttire - 1) buttons += ["Next ►"];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Court Attire Requirements\nPage " + (string)(page+1) + "/" + 
             (string)((totalAttire + ITEMS_PER_PAGE - 1) / ITEMS_PER_PAGE), buttons, DIALOG_CHANNEL);
}

showEtiquetteMenu()
{
    resetListeners();
    list buttons = [
        "Imperial Presence", "Addressing Nobility", "Court Precedence",
        "Movement Protocol", "Conversation Rules", "Main Menu"
    ];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Court Etiquette Guide\nLearn the proper conduct expected at the Imperial Russian Court.", buttons, DIALOG_CHANNEL);
}

showPracticeMenu()
{
    resetListeners();
    list buttons = [
        "Bow/Curtsy", "Formal Address", "Request Audience",
        "Table Etiquette", "Court Dance", "Main Menu"
    ];
    
    listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
    llDialog(ownerKey, "Practice Court Etiquette\nCurrent Etiquette Level: " + (string)playerEtiquetteLevel + "/100", buttons, DIALOG_CHANNEL);
}

string getRankDetail(string rank)
{
    if(rank == "Chancellor (Class I)") {
        return "The highest civil rank in the Empire, equivalent to Field Marshal in military. Addressed as 'Your High Excellency'. Only a few people ever held this rank simultaneously.";
    }
    else if(rank == "Actual Privy Councillor (Class II)") {
        return "Very senior rank granted to ministers and top officials. Typically addressed as 'Your Excellency'. Holders automatically received hereditary nobility.";
    }
    else if(rank == "Privy Councillor (Class III)") {
        return "Senior officials such as Vice-Ministers, Provincial Governors, and senior diplomats. Addressed as 'Your Excellency'.";
    }
    else if(rank == "Actual State Councillor (Class IV)") {
        return "Governors, department directors, and experienced officials. First rank that automatically granted hereditary nobility. Addressed as 'Your Excellency'.";
    }
    else if(rank == "Collegiate Councillor (Class VI)") {
        return "Mid-level officials, district judges, and senior academics. Equivalent to colonel in military. Personal nobility, not hereditary.";
    }
    else if(rank == "Titular Councillor (Class IX)") {
        return "Common rank for regular officials. Famously difficult for non-nobles to progress beyond this rank, as depicted in Russian literature.";
    }
    
    return "A rank in the Imperial Table of Ranks. The Table of Ranks was established by Peter the Great to organize the Russian civil, military, and court service.";
}

string getPositionDetail(string position)
{
    if(position == "Master of Ceremonies") {
        return "Oversees court ceremonial and protocol. Arranges all formal court occasions and ensures proper procedure.";
    }
    else if(position == "Grand Marshal of the Court") {
        return "One of the highest court positions. Supervises all court ceremonies and state occasions. Carries ceremonial staff as symbol of office.";
    }
    else if(position == "Ober-Hofmeister") {
        return "Chief overseer of the court's internal affairs. Manages palace administration and court appointments. Must be of high noble birth.";
    }
    else if(position == "Kammerherr (Chamberlain)") {
        return "Distinguished position granted to nobles of high birth. Entitled to wear a gold key on the back of uniform. Serves in personal attendance of the Imperial family.";
    }
    else if(position == "Hoffräulein (Lady-in-Waiting)") {
        return "High-ranking female court position. Ladies-in-waiting attend the Empress and Grand Duchesses. Must be of noble birth and unmarried.";
    }
    
    return "A position in the Imperial Russian Court hierarchy. Court positions conferred status and access to the Imperial family.";
}

string getCeremonyDetail(string ceremony)
{
    if(ceremony == "Winter Palace New Year's Levee") {
        return "Formal reception held on January 1st. The Tsar and Imperial family receive diplomats, high officials, and nobility. Elaborate ceremony with strict protocol in the grand halls of the Winter Palace.";
    }
    else if(ceremony == "Blessing of the Waters (Epiphany)") {
        return "January 19th (Old Style Jan 6). Religious ceremony where the Tsar leads procession to the Neva River. A hole is cut in ice and water blessed by Metropolitan. Traditionally, the Tsar's guards immerse themselves in the freezing water.";
    }
    else if(ceremony == "Imperial Easter Egg Presentation") {
        return "The Tsar presents specially commissioned Fabergé eggs to the Tsarina and Dowager Empress on Easter morning, continuing tradition started by Alexander III. Elaborate eggs contain surprises and are masterpieces of craftsmanship.";
    }
    else if(ceremony == "Grand Court Ball") {
        return "Magnificent formal balls held at Winter Palace during season (Jan-Feb). Strict dress code: men in court uniforms/military dress, women in Russian Court Dress with trains. Begins with polonaise led by Tsar and diplomatic spouses.";
    }
    else if(ceremony == "State Dinner") {
        return "Formal dinner with strict seating protocol based on rank. Imperial table service of gold plate. Each place setting includes up to 9 glasses for different wines and up to 8 pieces of silver for each course.";
    }
    
    return "An official ceremony of the Imperial Russian Court. Court ceremonies followed strict protocols dating back centuries.";
}

string getAttireDetail(string attire)
{
    if(attire == "Men's Gala Court Uniform") {
        return "For highest state functions. Dark green tailcoat with red collar and cuffs, heavily embroidered with gold according to rank. White breeches, white silk stockings, and shoes with gold buckles. Orders and decorations must be worn.";
    }
    else if(attire == "Ladies' Russian Court Dress") {
        return "Required for women at formal court functions. White dress with train of regulated length (longer for higher ranks), square décolletage. Velvet overdress in deep jewel tones. Kokoshnik headdress with white veil. Court jewels expected.";
    }
    else if(attire == "Formal Military Uniform") {
        return "Military officers wear full dress uniform with all decorations for court functions. Guards regiments have particularly elaborate uniforms. Tsarist military style emphasized ornate elements and traditional Russian features.";
    }
    else if(attire == "Winter Palace Ceremonial Dress") {
        return "The most formal version of court dress required for Winter Palace ceremonies. For men, includes cocked hat carried under arm and ceremonial sword. For women, the longest train length and most elaborate kokoshnik.";
    }
    else if(attire == "State Mourning Dress") {
        return "Black attire with specific requirements depending on relationship to deceased and level of court mourning declared. Men wear crepe armbands. Women wear black dresses with specific jewelry restrictions.";
    }
    
    return "Court dress at the Imperial Russian Court was highly regulated and indicative of rank and status.";
}

string getEtiquetteDetail(string topic)
{
    if(topic == "Imperial Presence") {
        return "When the Tsar enters a room, all must stand and bow/curtsy. No one may sit until the Tsar is seated. No one may leave a room before the Tsar unless dismissed. Never turn your back to the Tsar. Speak only when addressed directly by the Tsar.";
    }
    else if(topic == "Addressing Nobility") {
        return "Address the Tsar as 'Your Imperial Majesty' initially, then 'Sire'. The Tsarina as 'Your Imperial Majesty' then 'Madame'. Grand Dukes/Duchesses as 'Your Imperial Highness'. Lower ranks by appropriate title ('Your Excellency', 'Your Highness', etc.).";
    }
    else if(topic == "Court Precedence") {
        return "Strict order of precedence must be observed in processions, seating, and receiving lines. Order: Imperial family by proximity to throne, foreign royalty, Russian nobility by rank, military by rank, civil service by rank. Women take precedence from husbands.";
    }
    else if(topic == "Movement Protocol") {
        return "Walk deliberately, never run. Men bow from waist, women curtsy deeply to imperial family. Keep 3 paces from Tsar unless invited closer. Back away from imperial presence, never turn back. At formal dinners, all rise when Imperial family rises.";
    }
    else if(topic == "Conversation Rules") {
        return "Never initiate conversation with Imperial family. Respond concisely when addressed. Avoid politics, scandals, and personal matters. Use formal language and titles. Never interrupt anyone of higher rank. Never contradict the Tsar or Tsarina.";
    }
    
    return "Court etiquette at the Imperial Russian Court was among the most formal and strict in Europe.";
}

practiceCourt(string action)
{
    if(action == "Bow/Curtsy") {
        string gesture;
        if(llFrand(1.0) > 0.5) {
            gesture = "bow";
        } else {
            gesture = "curtsy";
        }
        llSay(0, "/me practices the proper " + gesture + " required in Imperial presence.");
        playerEtiquetteLevel += 3;
        llOwnerSay("You practice the correct depth and duration of formal court greeting. Etiquette +3");
    }
    else if(action == "Formal Address") {
        llSay(0, "/me rehearses the proper forms of address for various ranks of Russian nobility.");
        playerEtiquetteLevel += 2;
        llOwnerSay("You memorize the correct modes of address for each rank. Etiquette +2");
    }
    else if(action == "Request Audience") {
        llSay(0, "/me practices the formal protocol for requesting an Imperial audience.");
        playerEtiquetteLevel += 5;
        llOwnerSay("You master the complex procedure for seeking audience with the Imperial family. Etiquette +5");
    }
    else if(action == "Table Etiquette") {
        llSay(0, "/me studies the elaborate table etiquette required at Imperial state dinners.");
        playerEtiquetteLevel += 4;
        llOwnerSay("You learn the proper use of the numerous pieces of silver and crystal at a state dinner. Etiquette +4");
    }
    else if(action == "Court Dance") {
        llSay(0, "/me practices the polonaise, mazurka, and other dances performed at court balls.");
        playerEtiquetteLevel += 6;
        llOwnerSay("You perfect your dancing skills for the next Imperial ball. Etiquette +6");
    }
    
    // Ensure etiquette stays within bounds
    if(playerEtiquetteLevel > 100) playerEtiquetteLevel = 100;
    
    // Update other modules
    llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "UPDATE_ETIQUETTE|" + (string)playerEtiquetteLevel, NULL_KEY);
}

// Event Handlers
default
{
    state_entry()
    {
        init();
    }
    
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) == ownerKey) {
            showMainMenu();
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(channel == DIALOG_CHANNEL && id == ownerKey) {
            if(message == "Court Protocols") {
                menuPage = 0;
                list buttons = ["Court Ranks", "Court Positions", "Main Menu"];
                listener = llListen(DIALOG_CHANNEL, "", ownerKey, "");
                llDialog(ownerKey, "Court Protocol Categories\nSelect an area to explore.", buttons, DIALOG_CHANNEL);
            }
            else if(message == "Court Ranks") {
                menuPage = 0;
                showRanksMenu(menuPage);
            }
            else if(message == "Court Positions") {
                menuPage = 0;
                showPositionsMenu(menuPage);
            }
            else if(message == "Etiquette Guide") {
                showEtiquetteMenu();
            }
            else if(message == "Ceremonies") {
                menuPage = 0;
                showCeremoniesMenu(menuPage);
            }
            else if(message == "Court Dress") {
                menuPage = 0;
                showAttireMenu(menuPage);
            }
            else if(message == "Your Status") {
                string statusText = "Your Court Status\n";
                statusText += "━━━━━━━━━━━━━━━━━━━━━━\n";
                statusText += "Rank: " + playerRank + "\n";
                statusText += "Position: " + playerPosition + "\n";
                statusText += "Etiquette Level: " + (string)playerEtiquetteLevel + "/100\n\n";
                
                string proper_address = "Your proper form of address is unknown.";
                
                if(ownerKey == TSAR_UUID) {
                    proper_address = "You are to be addressed as 'Your Imperial Majesty' initially, then as 'Sire'.";
                } else if(ownerKey == TSAREVICH_UUID) {
                    proper_address = "You are to be addressed as 'Your Imperial Highness'.";
                } else if(llSubStringIndex(playerRank, "Class I") != -1 || llSubStringIndex(playerRank, "Class II") != -1 || llSubStringIndex(playerRank, "Class III") != -1) {
                    proper_address = "You are to be addressed as 'Your Excellency'.";
                } else if(playerRank != "Unranked Visitor") {
                    proper_address = "You are to be addressed according to your rank.";
                }
                
                statusText += proper_address;
                
                llOwnerSay(statusText);
                showMainMenu();
            }
            else if(message == "Practice Etiquette") {
                showPracticeMenu();
            }
            else if(message == "◄ Previous") {
                menuPage--;
                if(menuPage < 0) menuPage = 0;
                showRanksMenu(menuPage); // This needs to be smarter about what menu we're in
            }
            else if(message == "Next ►") {
                menuPage++;
                showRanksMenu(menuPage); // This needs to be smarter about what menu we're in
            }
            else if(message == "Main Menu") {
                showMainMenu();
            }
            // Handle rank selection
            else if(llListFindList(COURT_RANKS, [message]) != -1) {
                // Selected a specific rank
                llOwnerSay(message + ": " + getRankDetail(message));
            }
            // Handle position selection
            else if(llListFindList(COURT_POSITIONS, [message]) != -1) {
                // Selected a specific position
                llOwnerSay(message + ": " + getPositionDetail(message));
            }
            // Handle ceremony selection
            else if(llListFindList(COURT_CEREMONIES, [message]) != -1) {
                // Selected a specific ceremony
                llOwnerSay(message + ": " + getCeremonyDetail(message));
            }
            // Handle attire selection
            else if(llListFindList(COURT_ATTIRE, [message]) != -1) {
                // Selected a specific attire
                llOwnerSay(message + ": " + getAttireDetail(message));
            }
            // Handle etiquette topics
            else if(message == "Imperial Presence" || message == "Addressing Nobility" || 
                   message == "Court Precedence" || message == "Movement Protocol" || 
                   message == "Conversation Rules") {
                llOwnerSay(message + ":\n" + getEtiquetteDetail(message));
            }
            // Handle practice actions
            else if(message == "Bow/Curtsy" || message == "Formal Address" || 
                   message == "Request Audience" || message == "Table Etiquette" || 
                   message == "Court Dance") {
                practiceCourt(message);
                showPracticeMenu();
            }
        }
    }
    
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(num == HUD_LINK_MESSAGE_CHANNEL) {
            list params = llParseString2List(str, ["|"], []);
            string cmd = llList2String(params, 0);
            
            if(cmd == "IMPERIAL_PRESENCE") {
                key imperial_id = (key)llList2String(params, 1);
                if(imperial_id == TSAR_UUID || imperial_id == TSAREVICH_UUID) {
                    imperialPresence = TRUE;
                    
                    // Only alert if the player is not imperial themselves
                    if(ownerKey != TSAR_UUID && ownerKey != TSAREVICH_UUID) {
                        string imperialTitle;
                        if(imperial_id == TSAR_UUID) {
                            imperialTitle = "Tsar";
                        } else {
                            imperialTitle = "Tsarevich";
                        }
                        llOwnerSay("IMPERIAL PRESENCE ALERT: The " + imperialTitle + 
                                  " has entered. Proper protocol is required.");
                        
                        // If etiquette is good, automatically perform correct behavior
                        if(playerEtiquetteLevel > 70) {
                            string gesture;
                            if(llFrand(1.0) > 0.5) {
                                gesture = "bow";
                            } else {
                                gesture = "curtsy";
                            }
                            
                            string formalTitle;
                            if(imperial_id == TSAR_UUID) {
                                formalTitle = "Tsar";
                            } else {
                                formalTitle = "Tsarevich";
                            }
                            
                            llSay(0, "/me immediately stands and performs a formal " + 
                                 gesture + " as the " + formalTitle + " enters.");
                        }
                    }
                }
            }
            else if(cmd == "IMPERIAL_DEPARTURE") {
                imperialPresence = FALSE;
                llOwnerSay("The Imperial presence has departed.");
            }
            else if(cmd == "SET_RANK") {
                playerRank = llList2String(params, 1);
                llOwnerSay("Your court rank has been updated to " + playerRank + ".");
            }
            else if(cmd == "SET_POSITION") {
                playerPosition = llList2String(params, 1);
                llOwnerSay("Your court position has been updated to " + playerPosition + ".");
            }
            else if(cmd == "CHECK_ETIQUETTE") {
                llMessageLinked(LINK_SET, HUD_LINK_MESSAGE_CHANNEL, "ETIQUETTE_LEVEL|" + (string)playerEtiquetteLevel, id);
            }
        }
    }
}