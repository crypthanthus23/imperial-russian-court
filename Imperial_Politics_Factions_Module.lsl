// Imperial Russian Court Roleplay System
// Script: Imperial Politics and Factions Module
// Version: 1.0
// Description: Module for political affiliations, factions, and court influence

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer POLITICS_CHANNEL = -8675331; // Specific channel for politics module

// Political factions
integer FACTION_NONE = 0;        // Unaffiliated
integer FACTION_MONARCHIST = 1;  // Traditional monarchists
integer FACTION_REFORMIST = 2;   // Political reformers
integer FACTION_MILITARY = 3;    // Military party
integer FACTION_ORTHODOX = 4;    // Orthodox church faction
integer FACTION_WESTERN = 5;     // Western-leaning liberals
integer FACTION_SLAVOPHILE = 6;  // Slavophiles/traditionalists

// Influence levels
integer INFLUENCE_NONE = 0;      // No influence
integer INFLUENCE_LOW = 1;       // Low influence
integer INFLUENCE_MEDIUM = 2;    // Medium influence
integer INFLUENCE_HIGH = 3;      // High influence
integer INFLUENCE_DOMINANT = 4;  // Dominant position

// Military ranks
integer RANK_NONE = 0;           // No military rank
integer RANK_OFFICER = 1;        // Junior officer
integer RANK_CAPTAIN = 2;        // Captain
integer RANK_COLONEL = 3;        // Colonel
integer RANK_GENERAL = 4;        // General

// Academic positions
integer ACADEMIC_NONE = 0;       // No academic position
integer ACADEMIC_STUDENT = 1;    // Student
integer ACADEMIC_PROFESSOR = 2;  // Professor
integer ACADEMIC_RECTOR = 3;     // University rector
integer ACADEMIC_ACADEMY = 4;    // Academy member

// Status variables
integer currentFaction = FACTION_NONE;
integer courtInfluence = INFLUENCE_NONE;
integer militaryRank = RANK_NONE;
integer academicPosition = ACADEMIC_NONE;
string politicalStance = "Neutral";
string specialExpertise = "None";
integer relationshipTsar = 50;    // 0-100 scale of relationship with Tsar
integer relationshipChurch = 50;  // 0-100 scale of relationship with Church
integer foreignConnections = 0;   // 0-100 scale of foreign connections
integer traditionalism = 50;      // 0-100 scale (0 = progressive, 100 = traditional)
string currentPoliticalEvent = "None";
integer eventInfluence = 0;      // Temporary influence from events
integer isActive = FALSE;        // Is module active
integer listenHandle;            // Handle for the listen event

// Faction data storage
list factionNames = [];
list factionDescriptions = [];
list factionBenefits = [];
list politicalSkills = [];

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to initialize faction data
initializeFactions() {
    // Initialize faction names
    factionNames = [
        "Unaffiliated",
        "Monarchist Party",
        "Reformists",
        "Military Party",
        "Orthodox Faction",
        "Westernizers",
        "Slavophiles"
    ];
    
    // Initialize faction descriptions
    factionDescriptions = [
        "No political affiliation",
        "Stalwart supporters of absolute monarchy and the Tsar's divine right to rule.",
        "Advocates for moderate political reforms while maintaining the monarchy's authority.",
        "Emphasizes military strength and the defense of Russian interests abroad.",
        "Promotes the Orthodox Church's influence in state affairs and society.",
        "Favors adopting Western political and social ideas to modernize Russia.",
        "Champions traditional Russian values and Slavic cultural identity."
    ];
    
    // Initialize faction benefits
    factionBenefits = [
        "None",
        "+10 Court Influence, +15 Traditionalism",
        "+5 Court Influence, -10 Traditionalism",
        "+10 Military Standing, +5 Court Influence",
        "+15 Church Relations, +10 Traditionalism",
        "+15 Foreign Connections, -15 Traditionalism",
        "+10 Traditionalism, -5 Foreign Connections"
    ];
    
    // Initialize political skills
    politicalSkills = [
        "Diplomacy",
        "Oratory",
        "Intrigue",
        "Military Strategy",
        "Religious Rhetoric",
        "Economic Policy",
        "Intelligence Gathering",
        "Propaganda",
        "Negotiation",
        "Blackmail"
    ];
}

// Function to set faction affiliation
setFaction(integer faction) {
    currentFaction = faction;
    
    // Apply faction effects
    if (faction == FACTION_MONARCHIST) {
        courtInfluence += 1;
        traditionalism = llMin(100, traditionalism + 15);
    }
    else if (faction == FACTION_REFORMIST) {
        traditionalism = llMax(0, traditionalism - 10);
    }
    else if (faction == FACTION_MILITARY) {
        if (militaryRank == RANK_NONE) {
            militaryRank = RANK_OFFICER;
        }
    }
    else if (faction == FACTION_ORTHODOX) {
        relationshipChurch = llMin(100, relationshipChurch + 15);
        traditionalism = llMin(100, traditionalism + 10);
    }
    else if (faction == FACTION_WESTERN) {
        foreignConnections = llMin(100, foreignConnections + 15);
        traditionalism = llMax(0, traditionalism - 15);
    }
    else if (faction == FACTION_SLAVOPHILE) {
        traditionalism = llMin(100, traditionalism + 10);
        foreignConnections = llMax(0, foreignConnections - 5);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce faction change
    string factionName = llList2String(factionNames, faction);
    llSay(0, "You have affiliated yourself with the " + factionName + ".");
    llSay(0, "Benefit: " + llList2String(factionBenefits, faction));
}

// Function to set military rank
setMilitaryRank(integer rank) {
    militaryRank = rank;
    
    // Apply rank effects
    if (rank == RANK_OFFICER) {
        courtInfluence = llMax(INFLUENCE_LOW, courtInfluence);
    }
    else if (rank == RANK_CAPTAIN) {
        courtInfluence = llMax(INFLUENCE_LOW, courtInfluence);
    }
    else if (rank == RANK_COLONEL) {
        courtInfluence = llMax(INFLUENCE_MEDIUM, courtInfluence);
    }
    else if (rank == RANK_GENERAL) {
        courtInfluence = llMax(INFLUENCE_HIGH, courtInfluence);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce rank change
    string rankName = "";
    if (rank == RANK_OFFICER) {
        rankName = "Junior Officer";
    }
    else if (rank == RANK_CAPTAIN) {
        rankName = "Captain";
    }
    else if (rank == RANK_COLONEL) {
        rankName = "Colonel";
    }
    else if (rank == RANK_GENERAL) {
        rankName = "General";
    }
    
    llSay(0, "Your military rank is now: " + rankName);
}

// Function to set academic position
setAcademicPosition(integer position) {
    academicPosition = position;
    
    // Apply position effects
    if (position == ACADEMIC_STUDENT) {
        // No special effects for students
    }
    else if (position == ACADEMIC_PROFESSOR) {
        courtInfluence = llMax(INFLUENCE_LOW, courtInfluence);
    }
    else if (position == ACADEMIC_RECTOR) {
        courtInfluence = llMax(INFLUENCE_MEDIUM, courtInfluence);
    }
    else if (position == ACADEMIC_ACADEMY) {
        courtInfluence = llMax(INFLUENCE_HIGH, courtInfluence);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce position change
    string positionName = "";
    if (position == ACADEMIC_STUDENT) {
        positionName = "Student";
    }
    else if (position == ACADEMIC_PROFESSOR) {
        positionName = "Professor";
    }
    else if (position == ACADEMIC_RECTOR) {
        positionName = "University Rector";
    }
    else if (position == ACADEMIC_ACADEMY) {
        positionName = "Academy Member";
    }
    
    llSay(0, "Your academic position is now: " + positionName);
}

// Function to set political stance
setPoliticalStance(string stance) {
    politicalStance = stance;
    
    // Apply stance effects
    if (stance == "Reactionary") {
        traditionalism = llMin(100, traditionalism + 20);
        relationshipTsar = llMin(100, relationshipTsar + 10);
        foreignConnections = llMax(0, foreignConnections - 10);
    }
    else if (stance == "Conservative") {
        traditionalism = llMin(100, traditionalism + 10);
        relationshipTsar = llMin(100, relationshipTsar + 5);
    }
    else if (stance == "Moderate") {
        // Balanced stance
    }
    else if (stance == "Liberal") {
        traditionalism = llMax(0, traditionalism - 10);
        foreignConnections = llMin(100, foreignConnections + 5);
    }
    else if (stance == "Radical") {
        traditionalism = llMax(0, traditionalism - 20);
        relationshipTsar = llMax(0, relationshipTsar - 10);
        foreignConnections = llMin(100, foreignConnections + 15);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce stance change
    llSay(0, "Your political stance is now: " + stance);
}

// Function to set court influence
setCourtInfluence(integer influence) {
    courtInfluence = influence;
    
    // Update module display
    updateModuleDisplay();
    
    // Announce influence change
    string influenceDesc = "";
    if (influence == INFLUENCE_NONE) {
        influenceDesc = "None";
    }
    else if (influence == INFLUENCE_LOW) {
        influenceDesc = "Low";
    }
    else if (influence == INFLUENCE_MEDIUM) {
        influenceDesc = "Medium";
    }
    else if (influence == INFLUENCE_HIGH) {
        influenceDesc = "High";
    }
    else if (influence == INFLUENCE_DOMINANT) {
        influenceDesc = "Dominant";
    }
    
    llSay(0, "Your court influence is now: " + influenceDesc);
}

// Function to set relationship with Tsar
setTsarRelationship(integer level) {
    relationshipTsar = level;
    
    // Update module display
    updateModuleDisplay();
    
    // Announce relationship change
    string relationDesc = "Neutral";
    
    if (level < 20) {
        relationDesc = "Very Poor";
    }
    else if (level < 40) {
        relationDesc = "Poor";
    }
    else if (level < 60) {
        relationDesc = "Neutral";
    }
    else if (level < 80) {
        relationDesc = "Good";
    }
    else {
        relationDesc = "Excellent";
    }
    
    llSay(0, "Your relationship with the Tsar is now: " + relationDesc);
}

// Function to create a political event
createPoliticalEvent(string event, integer effect) {
    currentPoliticalEvent = event;
    eventInfluence = effect;
    
    // Announce event
    llSay(0, "Political Event: " + event);
    llSay(0, "This event provides " + (string)effect + " temporary influence points.");
    
    // Update module display
    updateModuleDisplay();
}

// Function to attempt a political action
attemptPoliticalAction(string action, integer difficulty) {
    // Calculate success chance based on influence, connections, and random factors
    integer baseChance = 50;
    integer totalInfluence = courtInfluence * 10 + eventInfluence;
    
    // Faction adjustments
    if (action == "Court Intrigue" && currentFaction == FACTION_MONARCHIST) {
        baseChance += 10;
    }
    else if (action == "Policy Reform" && currentFaction == FACTION_REFORMIST) {
        baseChance += 15;
    }
    else if (action == "Military Reform" && currentFaction == FACTION_MILITARY) {
        baseChance += 15;
    }
    else if (action == "Religious Legislation" && currentFaction == FACTION_ORTHODOX) {
        baseChance += 15;
    }
    
    // Calculate final chance
    integer finalChance = baseChance + totalInfluence - difficulty;
    finalChance = llMax(5, llMin(95, finalChance)); // Bound between 5-95%
    
    // Roll for success
    integer roll = llFloor(llFrand(100));
    integer success = (roll < finalChance);
    
    // Return result
    if (success) {
        llSay(0, "Political action successful: " + action);
        llSay(0, "Your influence and strategic position have improved.");
        courtInfluence = llMin(INFLUENCE_DOMINANT, courtInfluence + 1);
    }
    else {
        llSay(0, "Political action failed: " + action);
        llSay(0, "This setback may affect your position at court.");
        
        // Small chance of more serious consequences
        if (roll > 90) {
            llSay(0, "Your failure has attracted negative attention.");
            courtInfluence = llMax(INFLUENCE_NONE, courtInfluence - 1);
        }
    }
    
    // Update module display
    updateModuleDisplay();
    
    return success;
}

// Function to update module display
updateModuleDisplay() {
    string displayText = "Politics & Factions Module\n";
    
    // Show faction
    string factionName = llList2String(factionNames, currentFaction);
    displayText += "Faction: " + factionName + "\n";
    
    // Show influence
    string influenceDesc = "";
    if (courtInfluence == INFLUENCE_NONE) {
        influenceDesc = "None";
    }
    else if (courtInfluence == INFLUENCE_LOW) {
        influenceDesc = "Low";
    }
    else if (courtInfluence == INFLUENCE_MEDIUM) {
        influenceDesc = "Medium";
    }
    else if (courtInfluence == INFLUENCE_HIGH) {
        influenceDesc = "High";
    }
    else if (courtInfluence == INFLUENCE_DOMINANT) {
        influenceDesc = "Dominant";
    }
    
    displayText += "Court Influence: " + influenceDesc;
    
    // Show military rank if applicable
    if (militaryRank != RANK_NONE) {
        string rankName = "";
        if (militaryRank == RANK_OFFICER) {
            rankName = "Junior Officer";
        }
        else if (militaryRank == RANK_CAPTAIN) {
            rankName = "Captain";
        }
        else if (militaryRank == RANK_COLONEL) {
            rankName = "Colonel";
        }
        else if (militaryRank == RANK_GENERAL) {
            rankName = "General";
        }
        
        displayText += "\nMilitary Rank: " + rankName;
    }
    
    // Show academic position if applicable
    if (academicPosition != ACADEMIC_NONE) {
        string positionName = "";
        if (academicPosition == ACADEMIC_STUDENT) {
            positionName = "Student";
        }
        else if (academicPosition == ACADEMIC_PROFESSOR) {
            positionName = "Professor";
        }
        else if (academicPosition == ACADEMIC_RECTOR) {
            positionName = "University Rector";
        }
        else if (academicPosition == ACADEMIC_ACADEMY) {
            positionName = "Academy Member";
        }
        
        displayText += "\nAcademic: " + positionName;
    }
    
    // Show political stance
    displayText += "\nStance: " + politicalStance;
    
    // Show current event if any
    if (currentPoliticalEvent != "None") {
        displayText += "\nEvent: " + currentPoliticalEvent;
    }
    
    // Set the text
    llSetText(displayText, <0.8, 0.8, 1.0>, 1.0);
}

// Process commands from other system components
processPoliticsCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "FACTION_SET") {
        // Format: FACTION_SET|factionID
        if (llGetListLength(messageParts) >= 2) {
            integer faction = (integer)llList2String(messageParts, 1);
            setFaction(faction);
        }
    }
    else if (command == "MILITARY_SET") {
        // Format: MILITARY_SET|rankID
        if (llGetListLength(messageParts) >= 2) {
            integer rank = (integer)llList2String(messageParts, 1);
            setMilitaryRank(rank);
        }
    }
    else if (command == "ACADEMIC_SET") {
        // Format: ACADEMIC_SET|positionID
        if (llGetListLength(messageParts) >= 2) {
            integer position = (integer)llList2String(messageParts, 1);
            setAcademicPosition(position);
        }
    }
    else if (command == "STANCE_SET") {
        // Format: STANCE_SET|stanceName
        if (llGetListLength(messageParts) >= 2) {
            string stance = llList2String(messageParts, 1);
            setPoliticalStance(stance);
        }
    }
    else if (command == "INFLUENCE_SET") {
        // Format: INFLUENCE_SET|level
        if (llGetListLength(messageParts) >= 2) {
            integer level = (integer)llList2String(messageParts, 1);
            setCourtInfluence(level);
        }
    }
    else if (command == "RELATIONSHIP_TSAR_SET") {
        // Format: RELATIONSHIP_TSAR_SET|level
        if (llGetListLength(messageParts) >= 2) {
            integer level = (integer)llList2String(messageParts, 1);
            setTsarRelationship(level);
        }
    }
    else if (command == "EVENT_CREATE" && isTsar(senderKey)) {
        // Format: EVENT_CREATE|eventName|effect
        if (llGetListLength(messageParts) >= 3) {
            string event = llList2String(messageParts, 1);
            integer effect = (integer)llList2String(messageParts, 2);
            createPoliticalEvent(event, effect);
        }
    }
    else if (command == "ACTION_ATTEMPT") {
        // Format: ACTION_ATTEMPT|actionName|difficulty
        if (llGetListLength(messageParts) >= 3) {
            string action = llList2String(messageParts, 1);
            integer difficulty = (integer)llList2String(messageParts, 2);
            attemptPoliticalAction(action, difficulty);
        }
    }
    else if (command == "ACTIVATE") {
        isActive = TRUE;
        updateModuleDisplay();
    }
    else if (command == "DEACTIVATE") {
        isActive = FALSE;
        llSetText("", <0,0,0>, 0);
    }
}

default {
    state_entry() {
        // Initialize faction data
        initializeFactions();
        
        // Start listening for system events
        listenHandle = llListen(POLITICS_CHANNEL, "", NULL_KEY, "");
        
        // Update display
        updateModuleDisplay();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        
        // Main menu options
        list options = [
            "Select Faction",
            "Military Career",
            "Academic Career",
            "Political Stance",
            "Political Actions",
            "View Influence"
        ];
        
        // Special options for Tsar
        if (isTsar(toucherKey)) {
            options += ["Create Political Event"];
        }
        
        // Show menu
        llDialog(toucherKey, "Imperial Politics and Factions Module", options, POLITICS_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Check if this is on the politics channel
        if (channel == POLITICS_CHANNEL) {
            // Process main menu selections
            if (message == "Select Faction") {
                // Show faction options
                list factionOptions = [];
                integer i;
                for (i = 1; i < llGetListLength(factionNames); i++) {
                    factionOptions += [llList2String(factionNames, i)];
                }
                llDialog(id, "Select your political faction:", factionOptions, POLITICS_CHANNEL + 1);
            }
            else if (message == "Military Career") {
                // Show military rank options
                list rankOptions = [
                    "Junior Officer",
                    "Captain",
                    "Colonel",
                    "General",
                    "No Military Rank"
                ];
                llDialog(id, "Select your military rank:", rankOptions, POLITICS_CHANNEL + 2);
            }
            else if (message == "Academic Career") {
                // Show academic options
                list academicOptions = [
                    "Student",
                    "Professor",
                    "University Rector",
                    "Academy Member",
                    "No Academic Position"
                ];
                llDialog(id, "Select academic position:", academicOptions, POLITICS_CHANNEL + 3);
            }
            else if (message == "Political Stance") {
                // Show stance options
                list stanceOptions = [
                    "Reactionary",
                    "Conservative",
                    "Moderate",
                    "Liberal",
                    "Radical"
                ];
                llDialog(id, "Select political stance:", stanceOptions, POLITICS_CHANNEL + 4);
            }
            else if (message == "Political Actions") {
                // Show action options
                list actionOptions = [
                    "Court Intrigue",
                    "Policy Reform",
                    "Military Reform",
                    "Religious Legislation",
                    "Foreign Relations"
                ];
                llDialog(id, "Select political action:", actionOptions, POLITICS_CHANNEL + 5);
            }
            else if (message == "View Influence") {
                // Show current status
                string influenceDesc = "";
                if (courtInfluence == INFLUENCE_NONE) {
                    influenceDesc = "None";
                }
                else if (courtInfluence == INFLUENCE_LOW) {
                    influenceDesc = "Low";
                }
                else if (courtInfluence == INFLUENCE_MEDIUM) {
                    influenceDesc = "Medium";
                }
                else if (courtInfluence == INFLUENCE_HIGH) {
                    influenceDesc = "High";
                }
                else if (courtInfluence == INFLUENCE_DOMINANT) {
                    influenceDesc = "Dominant";
                }
                
                string factionName = llList2String(factionNames, currentFaction);
                
                string statusMsg = "Political Status:\n";
                statusMsg += "Faction: " + factionName + "\n";
                statusMsg += "Court Influence: " + influenceDesc + "\n";
                statusMsg += "Stance: " + politicalStance + "\n";
                statusMsg += "Tsar Relationship: " + (string)relationshipTsar + "/100\n";
                statusMsg += "Church Relationship: " + (string)relationshipChurch + "/100\n";
                statusMsg += "Foreign Connections: " + (string)foreignConnections + "/100\n";
                statusMsg += "Traditionalism: " + (string)traditionalism + "/100\n";
                
                llDialog(id, statusMsg, ["Return to Main Menu"], POLITICS_CHANNEL);
            }
            else if (message == "Create Political Event" && isTsar(id)) {
                // Show event options
                list eventOptions = [
                    "War Crisis",
                    "Diplomatic Victory",
                    "Religious Holiday",
                    "Economic Reform",
                    "Royal Celebration"
                ];
                llDialog(id, "Select political event:", eventOptions, POLITICS_CHANNEL + 6);
            }
            else {
                // Check if it's a system command
                processPoliticsCommand(message, id);
            }
        }
        else if (channel == POLITICS_CHANNEL + 1) {
            // Process faction selection
            if (message == "Monarchist Party") {
                setFaction(FACTION_MONARCHIST);
            }
            else if (message == "Reformists") {
                setFaction(FACTION_REFORMIST);
            }
            else if (message == "Military Party") {
                setFaction(FACTION_MILITARY);
            }
            else if (message == "Orthodox Faction") {
                setFaction(FACTION_ORTHODOX);
            }
            else if (message == "Westernizers") {
                setFaction(FACTION_WESTERN);
            }
            else if (message == "Slavophiles") {
                setFaction(FACTION_SLAVOPHILE);
            }
        }
        else if (channel == POLITICS_CHANNEL + 2) {
            // Process military rank selection
            if (message == "Junior Officer") {
                setMilitaryRank(RANK_OFFICER);
            }
            else if (message == "Captain") {
                setMilitaryRank(RANK_CAPTAIN);
            }
            else if (message == "Colonel") {
                setMilitaryRank(RANK_COLONEL);
            }
            else if (message == "General") {
                setMilitaryRank(RANK_GENERAL);
            }
            else if (message == "No Military Rank") {
                setMilitaryRank(RANK_NONE);
            }
        }
        else if (channel == POLITICS_CHANNEL + 3) {
            // Process academic position selection
            if (message == "Student") {
                setAcademicPosition(ACADEMIC_STUDENT);
            }
            else if (message == "Professor") {
                setAcademicPosition(ACADEMIC_PROFESSOR);
            }
            else if (message == "University Rector") {
                setAcademicPosition(ACADEMIC_RECTOR);
            }
            else if (message == "Academy Member") {
                setAcademicPosition(ACADEMIC_ACADEMY);
            }
            else if (message == "No Academic Position") {
                setAcademicPosition(ACADEMIC_NONE);
            }
        }
        else if (channel == POLITICS_CHANNEL + 4) {
            // Process political stance selection
            setPoliticalStance(message);
        }
        else if (channel == POLITICS_CHANNEL + 5) {
            // Process political action selection
            // Actions have different difficulties
            integer difficulty = 50; // Base difficulty
            
            if (message == "Court Intrigue") {
                difficulty = 40 + llFloor(llFrand(20)); // 40-60
            }
            else if (message == "Policy Reform") {
                difficulty = 50 + llFloor(llFrand(30)); // 50-80
            }
            else if (message == "Military Reform") {
                difficulty = 55 + llFloor(llFrand(25)); // 55-80
            }
            else if (message == "Religious Legislation") {
                difficulty = 60 + llFloor(llFrand(20)); // 60-80
            }
            else if (message == "Foreign Relations") {
                difficulty = 45 + llFloor(llFrand(30)); // 45-75
            }
            
            attemptPoliticalAction(message, difficulty);
        }
        else if (channel == POLITICS_CHANNEL + 6 && isTsar(id)) {
            // Process event creation by Tsar
            integer effect = 15; // Base effect
            
            if (message == "War Crisis") {
                effect = 15;
                createPoliticalEvent("War Crisis - Tensions rising with foreign powers", effect);
            }
            else if (message == "Diplomatic Victory") {
                effect = 10;
                createPoliticalEvent("Diplomatic Success - Treaty negotiated favorably", effect);
            }
            else if (message == "Religious Holiday") {
                effect = 5;
                createPoliticalEvent("Religious Celebration - Honoring Orthodox traditions", effect);
            }
            else if (message == "Economic Reform") {
                effect = 12;
                createPoliticalEvent("Economic Reform - New fiscal policies implemented", effect);
            }
            else if (message == "Royal Celebration") {
                effect = 8;
                createPoliticalEvent("Royal Celebration - Court festivities announced", effect);
            }
        }
    }
}