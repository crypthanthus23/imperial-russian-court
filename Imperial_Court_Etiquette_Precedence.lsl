// Imperial Court Etiquette Precedence Module
// Handles the order of precedence at court events and ceremonies

// Communication channels
integer ETIQUETTE_CORE_CHANNEL = -9876543;
integer ETIQUETTE_PRECEDENCE_CHANNEL = -9876545;

// Order of Precedence Database
// Format: [Rank, Precedence Order, Description]
list imperialPrecedence = [
    "Tsar/Emperor", "1", "Supreme authority in all matters",
    "Tsarina/Empress", "2", "Imperial consort",
    "Dowager Empress", "3", "Mother of the reigning Tsar",
    "Tsarevich", "4", "Heir to the throne",
    "Grand Dukes", "5", "Sons/brothers of the Tsar or Emperor",
    "Grand Duchesses", "6", "Daughters/sisters of the Tsar or Emperor",
    "Other Romanov Princes", "7", "Male descendants of the imperial line",
    "Other Romanov Princesses", "8", "Female descendants of the imperial line"
];

list courtPrecedence = [
    "Foreign Sovereigns", "9", "Visiting kings and queens",
    "Foreign Heirs", "10", "Visiting crown princes and princesses",
    "Ambassadors", "11", "Foreign diplomatic representatives",
    "Chancellor/Prime Minister", "12", "Head of government",
    "Ministers of State", "13", "Cabinet members",
    "High Nobility with Court Rank", "14", "Titled nobles with official positions",
    "Other Nobility", "15", "Titled nobles without official positions",
    "Clergy", "16", "Orthodox Church hierarchs",
    "Military Officers", "17", "By rank and seniority",
    "Court Officials", "18", "By rank and appointment",
    "Distinguished Visitors", "19", "Notable but untitled persons"
];

// Processional rules
list processionalRules = [
    "State Functions", "Emperor leads, followed by Empress, then in strict order of precedence",
    "Court Balls", "Emperor and Empress enter together, then order of precedence",
    "Diplomatic Receptions", "Ambassadors received in order of seniority at court",
    "Religious Ceremonies", "Clergy precede nobility except for the Imperial Family",
    "Military Reviews", "Emperor first, followed by military in order of rank"
];

// Seating rules
list seatingRules = [
    "Imperial Table", "Emperor at center, Empress on right, highest ranking guests proceeding outward",
    "State Dinners", "Alternating male-female placement with precedence determining proximity to imperial couple",
    "Theatre Boxes", "Imperial box centered, other boxes assigned by rank and relationship",
    "Religious Services", "Imperial Family at front right, nobles and officials behind",
    "Council Meetings", "Emperor at head, others by rank clockwise"
];

// Display precedence menu
integer displayPrecedenceMenu(key id) {
    llDialog(id, "Imperial Order of Precedence\n\nSelect a category to study:",
        ["Imperial Family", "Court Ranks", "Processional Rules", "Seating Rules", "Practice", "Back"], ETIQUETTE_PRECEDENCE_CHANNEL);
    return TRUE;
}

// Display specific precedence category
integer displayPrecedenceCategory(string category, key id) {
    string info = "Order of Precedence: " + category + "\n\n";
    list items;
    integer i;
    integer count;
    
    if(category == "Imperial Family") {
        items = imperialPrecedence;
        for(i = 0; i < llGetListLength(items); i += 3) {
            string rank = llList2String(items, i);
            string order = llList2String(items, i+1);
            string desc = llList2String(items, i+2);
            
            info += order + ". " + rank + "\n";
            info += "   " + desc + "\n\n";
        }
    }
    else if(category == "Court Ranks") {
        items = courtPrecedence;
        for(i = 0; i < llGetListLength(items); i += 3) {
            string rank = llList2String(items, i);
            string order = llList2String(items, i+1);
            string desc = llList2String(items, i+2);
            
            info += order + ". " + rank + "\n";
            info += "   " + desc + "\n\n";
        }
    }
    else if(category == "Processional Rules") {
        items = processionalRules;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string eventType = llList2String(items, i);
            string rule = llList2String(items, i+1);
            
            info += eventType + "\n";
            info += "   " + rule + "\n\n";
        }
    }
    else if(category == "Seating Rules") {
        items = seatingRules;
        for(i = 0; i < llGetListLength(items); i += 2) {
            string eventType = llList2String(items, i);
            string rule = llList2String(items, i+1);
            
            info += eventType + "\n";
            info += "   " + rule + "\n\n";
        }
    }
    
    llDialog(id, info, ["Back to Precedence", "Practice", "Main Menu"], ETIQUETTE_PRECEDENCE_CHANNEL);
    return TRUE;
}

// Practice precedence
integer practicePrecedence() {
    // Create questions about precedence
    list questions = [
        "Who takes precedence between the Dowager Empress and the Tsarevich?",
        "Where would foreign ambassadors be seated relative to Russian ministers?",
        "In a court ball, who enters the ballroom first?",
        "In a state dinner, who would sit closest to the Emperor?",
        "During a military review, what is the order of precedence?"
    ];
    
    list answers = [
        "The Dowager Empress (3) takes precedence over the Tsarevich (4).",
        "Ambassadors (11) take precedence over Ministers of State (13).",
        "The Emperor and Empress enter first, followed by others in order of precedence.",
        "The Empress would be on his right, followed by the highest ranking guests.",
        "The Emperor first, followed by military officers in order of rank."
    ];
    
    // Select random question
    integer randomIndex = (integer)(llFrand(llGetListLength(questions)));
    string randomQuestion = llList2String(questions, randomIndex);
    
    llOwnerSay("Practice Question: " + randomQuestion);
    llOwnerSay("(The answer will appear in 10 seconds)");
    
    // Set timer to reveal answer
    llSetTimerEvent(10.0);
    
    // Store current question index
    practiceQuestionIndex = randomIndex;
    
    return TRUE;
}

// Study intermediate precedence
integer studyIntermediatePrecedence() {
    llOwnerSay("The Court Chamberlain instructs you on the finer points of precedence at official events:");
    
    // Give detailed instruction on a specific aspect of precedence
    llOwnerSay("The most critical aspect of court precedence is understanding that the Imperial Family members always take absolute precedence over all other ranks.");
    llOwnerSay("Within the Imperial Family, the order is strictly defined: Emperor, Empress, Dowager Empress, Tsarevich, Grand Dukes, Grand Duchesses.");
    llOwnerSay("For processions, remember that proximity to the imperial couple is determined by rank and relationship. Grand Dukes related directly to the Tsar precede those further removed.");
    
    // Update etiquette mastery
    llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "UPDATE_MASTERY=+2", NULL_KEY);
    
    return TRUE;
}

// Current practice variables
integer practiceQuestionIndex = -1;

default {
    state_entry() {
        llListen(ETIQUETTE_PRECEDENCE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == ETIQUETTE_PRECEDENCE_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayPrecedenceMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Order of Precedence module initialized.");
            }
            else if(str == "STUDY_INTERMEDIATE") {
                studyIntermediatePrecedence();
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == ETIQUETTE_PRECEDENCE_CHANNEL) {
            if(message == "Imperial Family" || message == "Court Ranks" || 
               message == "Processional Rules" || message == "Seating Rules") {
                displayPrecedenceCategory(message, id);
            }
            else if(message == "Practice") {
                practicePrecedence();
            }
            else if(message == "Back to Precedence") {
                displayPrecedenceMenu(id);
            }
            else if(message == "Main Menu" || message == "Back") {
                llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
    
    timer() {
        llSetTimerEvent(0.0); // Stop timer
        
        // Reveal answer to practice question
        list answers = [
            "The Dowager Empress (3) takes precedence over the Tsarevich (4).",
            "Ambassadors (11) take precedence over Ministers of State (13).",
            "The Emperor and Empress enter first, followed by others in order of precedence.",
            "The Empress would be on his right, followed by the highest ranking guests.",
            "The Emperor first, followed by military officers in order of rank."
        ];
        
        if(practiceQuestionIndex >= 0 && practiceQuestionIndex < llGetListLength(answers)) {
            llOwnerSay("Answer: " + llList2String(answers, practiceQuestionIndex));
            
            // Provide feedback and update stats
            llMessageLinked(LINK_SET, ETIQUETTE_PRECEDENCE_CHANNEL, "UPDATE_MASTERY=+1", NULL_KEY);
        }
    }
}