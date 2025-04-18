// Imperial Court Etiquette Customs Module
// Handles court customs, ceremonies, and rituals

// Communication channels
integer ETIQUETTE_CORE_CHANNEL = -9876543;
integer ETIQUETTE_CUSTOMS_CHANNEL = -9876546;

// Court Customs Database
list greetingCustoms = [
    "Imperial Family", "Deep bow (men) or court curtsy (women), no handshake unless offered", 
    "Court officials", "Bow or curtsy according to rank, wait for permission to speak",
    "Foreign dignitaries", "Formal bow, address according to diplomatic protocol",
    "Clergy", "Bow and receive blessing, kiss ring for high-ranking clergy",
    "Military officers", "Salute for those in uniform, bow for those in civilian dress"
];

list formalEvents = [
    "Court Ball", "Annual formal social gathering with structured dances and imperial presentations",
    "State Dinner", "Formal banquet with elaborate protocols for toasts and speeches",
    "Imperial Reception", "Formal gathering where selected subjects are presented to the imperial family",
    "Diplomatic Corps Reception", "Annual event honoring foreign representatives",
    "Military Parade", "Ceremonial display of armed forces attended by imperial family",
    "Religious Ceremony", "Orthodox ritual with special protocols for imperial participation"
];

list specialRituals = [
    "Trooping the Colors", "Military ceremony with specific placement and recognition protocols",
    "Ceremonial Guard Change", "Daily ritual at imperial residences with precise timing and movements",
    "Easter Egg Exchange", "Traditional presentation of ornate eggs to the imperial family",
    "Imperial Birthday Observance", "Formal congratulations in order of precedence",
    "Name Day Celebration", "Religious observance of a person's saint's day, requiring specific gifts and greetings",
    "New Year's Reception", "Annual ceremony with specific toasts and well-wishes"
];

list courtEtiquetteRules = [
    "Never turn your back on the Imperial Family", "Always remain facing them when departing their presence",
    "Wait to be addressed", "Do not speak first to members of the Imperial Family",
    "Proper titles must always be used", "Never use diminutives or informal address in court settings",
    "Request permission to sit", "Remain standing until given permission to be seated",
    "Do not leave before the Imperial Family", "Wait for the imperial party to depart first",
    "Accept refreshments when offered", "Refusing imperial hospitality is considered an insult",
    "Criticizing court decisions is forbidden", "All matters of state are above public critique",
    "Formal court dress is mandatory", "Specific attire for each type of event must be strictly observed"
];

// Display customs menu
integer displayCustomsMenu(key id) {
    llDialog(id, "Imperial Court Customs\n\nSelect a category to study:",
        ["Greeting Protocols", "Formal Events", "Special Rituals", "Court Rules", "Practice", "Back"], ETIQUETTE_CUSTOMS_CHANNEL);
    return TRUE;
}

// Display specific customs category
integer displayCustomsCategory(string category, key id) {
    string info = "Court Customs: " + category + "\n\n";
    list items;
    integer i;
    integer count;
    
    if(category == "Greeting Protocols") {
        items = greetingCustoms;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string rank = llList2String(items, i);
            string protocol = llList2String(items, i+1);
            
            info += rank + ":\n";
            info += "   " + protocol + "\n\n";
        }
    }
    else if(category == "Formal Events") {
        items = formalEvents;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string eventName = llList2String(items, i);
            string description = llList2String(items, i+1);
            
            info += eventName + ":\n";
            info += "   " + description + "\n\n";
        }
    }
    else if(category == "Special Rituals") {
        items = specialRituals;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string ritual = llList2String(items, i);
            string description = llList2String(items, i+1);
            
            info += ritual + ":\n";
            info += "   " + description + "\n\n";
        }
    }
    else if(category == "Court Rules") {
        items = courtEtiquetteRules;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string rule = llList2String(items, i);
            string explanation = llList2String(items, i+1);
            
            info += rule + ":\n";
            info += "   " + explanation + "\n\n";
        }
    }
    
    llDialog(id, info, ["Back to Customs", "Practice", "Main Menu"], ETIQUETTE_CUSTOMS_CHANNEL);
    return TRUE;
}

// Practice court customs
integer practiceCustoms() {
    // Create scenarios to test knowledge of court customs
    list scenarios = [
        "You are attending a Court Ball and the Tsar enters the room. What should you do?",
        "During a State Dinner, when should you begin eating?",
        "At a formal reception, how should you greet a Grand Duchess?",
        "You need to depart from an imperial reception early. What is the proper protocol?",
        "During a ceremony, the Tsarina offers you a glass of wine. What is the appropriate response?",
        "You wish to present a petition to the Tsar. How should you proceed?"
    ];
    
    list responses = [
        "Stop all activity, stand, and bow/curtsy deeply. Remain standing until given permission to resume activities.",
        "Wait for the Tsar to take his first bite before beginning to eat your own meal.",
        "Perform a court curtsy (women) or deep bow (men) and address her as 'Your Imperial Highness'.",
        "Request permission from the Master of Ceremonies, exit discreetly, never turning your back on the imperial family.",
        "Accept with gratitude, take a small sip, and express appreciation for the honor.",
        "Submit your request to the appropriate court official. Never approach the Tsar directly unless specifically invited."
    ];
    
    // Select random scenario
    integer randomIndex = (integer)(llFrand(llGetListLength(scenarios)));
    string randomScenario = llList2String(scenarios, randomIndex);
    
    llOwnerSay("Practice Scenario: " + randomScenario);
    llOwnerSay("(The proper response will appear in 10 seconds)");
    
    // Set timer to reveal answer
    llSetTimerEvent(10.0);
    
    // Store current scenario index
    practiceScenarioIndex = randomIndex;
    
    return TRUE;
}

// Study advanced court customs
integer studyAdvancedCustoms() {
    llOwnerSay("The Court Chamberlain provides advanced instruction on imperial court protocol:");
    
    // Give detailed instruction on special court customs
    llOwnerSay("The most nuanced aspect of court protocol is the handling of imperial audiences. When granted a private audience with the Tsar:");
    llOwnerSay("1. Enter when announced, make three steps, bow/curtsy, then another three steps and bow/curtsy again");
    llOwnerSay("2. Address the Tsar as 'Your Imperial Majesty' for the first address, then 'Sire' thereafter");
    llOwnerSay("3. Speak only when questioned, keep answers concise and direct");
    llOwnerSay("4. Accept any refreshment offered immediately with gratitude");
    llOwnerSay("5. When dismissed, bow/curtsy, back away three steps, bow/curtsy again, then turn at the door");
    
    // Update etiquette mastery
    llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "UPDATE_RANK=+2", NULL_KEY);
    llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "UPDATE_MASTERY=+2", NULL_KEY);
    
    return TRUE;
}

// Current practice variables
integer practiceScenarioIndex = -1;

default {
    state_entry() {
        llListen(ETIQUETTE_CUSTOMS_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == ETIQUETTE_CUSTOMS_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayCustomsMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Court Customs module initialized.");
            }
            else if(str == "STUDY_ADVANCED") {
                studyAdvancedCustoms();
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == ETIQUETTE_CUSTOMS_CHANNEL) {
            if(message == "Greeting Protocols" || message == "Formal Events" || 
               message == "Special Rituals" || message == "Court Rules") {
                displayCustomsCategory(message, id);
            }
            else if(message == "Practice") {
                practiceCustoms();
            }
            else if(message == "Back to Customs") {
                displayCustomsMenu(id);
            }
            else if(message == "Main Menu" || message == "Back") {
                llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
    
    timer() {
        llSetTimerEvent(0.0); // Stop timer
        
        // Reveal answer to practice scenario
        list responses = [
            "Stop all activity, stand, and bow/curtsy deeply. Remain standing until given permission to resume activities.",
            "Wait for the Tsar to take his first bite before beginning to eat your own meal.",
            "Perform a court curtsy (women) or deep bow (men) and address her as 'Your Imperial Highness'.",
            "Request permission from the Master of Ceremonies, exit discreetly, never turning your back on the imperial family.",
            "Accept with gratitude, take a small sip, and express appreciation for the honor.",
            "Submit your request to the appropriate court official. Never approach the Tsar directly unless specifically invited."
        ];
        
        if(practiceScenarioIndex >= 0 && practiceScenarioIndex < llGetListLength(responses)) {
            llOwnerSay("Proper Response: " + llList2String(responses, practiceScenarioIndex));
            
            // Provide feedback and update stats
            llMessageLinked(LINK_SET, ETIQUETTE_CUSTOMS_CHANNEL, "UPDATE_RANK=+1", NULL_KEY);
        }
    }
}