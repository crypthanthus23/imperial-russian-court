// Imperial Court Etiquette Forms Module
// Handles forms of address for different ranks and titles

// Communication channels
integer ETIQUETTE_CORE_CHANNEL = -9876543;
integer ETIQUETTE_FORMS_CHANNEL = -9876544;

// Forms of Address Database
list imperialFamilyAddress = [
    "Tsar/Emperor", "Your Imperial Majesty", "Sovereign Emperor and Autocrat of All the Russias",
    "Tsarina/Empress", "Your Imperial Majesty", "Sovereign Empress",
    "Tsarevich", "Your Imperial Highness", "Heir Apparent",
    "Grand Duke", "Your Imperial Highness", "Son/Brother/Uncle of the Tsar",
    "Grand Duchess", "Your Imperial Highness", "Daughter/Sister/Aunt of the Tsar"
];

list nobilityAddress = [
    "Prince/Princess", "Your Serene Highness", "For members of princely families",
    "Count/Countess", "Your Excellency", "Senior aristocracy",
    "Baron/Baroness", "Your Lordship/Ladyship", "Lesser nobility",
    "Gentleman/Lady of the Chamber", "Honorable Sir/Madam", "Court officials"
];

list clergyAddress = [
    "Metropolitan", "Your Eminence", "Senior Orthodox Church leader",
    "Archbishop", "Your Grace", "Orthodox Church regional leader",
    "Bishop", "Right Reverend Father", "Orthodox Church local leader",
    "Abbot/Abbess", "Venerable Father/Mother", "Monastery leader",
    "Priest", "Father", "Parish leader"
];

list militaryAddress = [
    "Field Marshal", "Your Excellency", "Highest military rank",
    "General", "General", "Senior Army officer",
    "Colonel", "Colonel", "Regimental commander",
    "Captain", "Captain", "Company commander"
];

// Current practice variables
string practiceRank = "";

// Function to get proper form of address
string getProperAddress(string rank) {
    integer idx;
    
    // Check imperial family
    idx = llListFindList(imperialFamilyAddress, [rank]);
    if(idx != -1) {
        return llList2String(imperialFamilyAddress, idx + 1);
    }
    
    // Check nobility
    idx = llListFindList(nobilityAddress, [rank]);
    if(idx != -1) {
        return llList2String(nobilityAddress, idx + 1);
    }
    
    // Check clergy
    idx = llListFindList(clergyAddress, [rank]);
    if(idx != -1) {
        return llList2String(clergyAddress, idx + 1);
    }
    
    // Check military
    idx = llListFindList(militaryAddress, [rank]);
    if(idx != -1) {
        return llList2String(militaryAddress, idx + 1);
    }
    
    // Default address
    return "Sir/Madam";
}

// Display forms of address menu
integer displayFormsMenu(key id) {
    llDialog(id, "Imperial Forms of Address\n\nSelect a category to study:",
        ["Imperial Family", "Nobility", "Clergy", "Military", "Practice", "Back"], ETIQUETTE_FORMS_CHANNEL);
    return TRUE;
}

// Display specific category
integer displayCategory(string category, key id) {
    string info = "Forms of Address: " + category + "\n\n";
    list items;
    integer i;
    integer count;
    
    if(category == "Imperial Family") {
        items = imperialFamilyAddress;
    }
    else if(category == "Nobility") {
        items = nobilityAddress;
    }
    else if(category == "Clergy") {
        items = clergyAddress;
    }
    else if(category == "Military") {
        items = militaryAddress;
    }
    
    count = llGetListLength(items);
    
    for(i = 0; i < count; i += 3) {
        string title = llList2String(items, i);
        string address = llList2String(items, i+1);
        string desc = llList2String(items, i+2);
        
        info += title + "\n";
        info += "   Address as: " + address + "\n";
        info += "   Notes: " + desc + "\n\n";
    }
    
    llDialog(id, info, ["Back to Forms", "Practice", "Main Menu"], ETIQUETTE_FORMS_CHANNEL);
    return TRUE;
}

// Practice forms of address
integer practiceAddressing() {
    // Generate random rank to practice addressing
    list allRanks = [];
    
    // Collect all titles from the various lists
    integer i;
    for(i = 0; i < llGetListLength(imperialFamilyAddress); i += 3) {
        allRanks += llList2String(imperialFamilyAddress, i);
    }
    for(i = 0; i < llGetListLength(nobilityAddress); i += 3) {
        allRanks += llList2String(nobilityAddress, i);
    }
    for(i = 0; i < llGetListLength(clergyAddress); i += 3) {
        allRanks += llList2String(clergyAddress, i);
    }
    for(i = 0; i < llGetListLength(militaryAddress); i += 3) {
        allRanks += llList2String(militaryAddress, i);
    }
    
    // Select random rank
    integer randomIndex = (integer)(llFrand(llGetListLength(allRanks)));
    string randomRank = llList2String(allRanks, randomIndex);
    
    llOwnerSay("Practice Question: How would you properly address a " + randomRank + "?");
    llOwnerSay("(The answer will appear in 5 seconds)");
    
    // Set timer to reveal answer
    llSetTimerEvent(5.0);
    
    // Store current practice rank
    practiceRank = randomRank;
    
    return TRUE;
}

// Study basic forms
integer studyBasicForms() {
    llOwnerSay("The Court Chamberlain instructs you on the basic forms of address for the Imperial Family:");
    
    integer i;
    for(i = 0; i < 5*3; i += 3) { // First 5 entries of Imperial Family
        string title = llList2String(imperialFamilyAddress, i);
        string address = llList2String(imperialFamilyAddress, i+1);
        
        llOwnerSay(title + " should be addressed as \"" + address + "\"");
    }
    
    // Update etiquette rank
    llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "UPDATE_RANK=+1", NULL_KEY);
    
    return TRUE;
}

default {
    state_entry() {
        llListen(ETIQUETTE_FORMS_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == ETIQUETTE_FORMS_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayFormsMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Forms of Address module initialized.");
            }
            else if(str == "STUDY_BASIC") {
                studyBasicForms();
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == ETIQUETTE_FORMS_CHANNEL) {
            if(message == "Imperial Family" || message == "Nobility" || 
               message == "Clergy" || message == "Military") {
                displayCategory(message, id);
            }
            else if(message == "Practice") {
                practiceAddressing();
            }
            else if(message == "Back to Forms") {
                displayFormsMenu(id);
            }
            else if(message == "Main Menu" || message == "Back") {
                llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
    
    timer() {
        llSetTimerEvent(0.0); // Stop timer
        
        // Reveal answer to practice question
        string correctAddress = getProperAddress(practiceRank);
        llOwnerSay("Answer: A " + practiceRank + " should be addressed as \"" + correctAddress + "\"");
        
        // Provide feedback and update stats
        llMessageLinked(LINK_SET, ETIQUETTE_FORMS_CHANNEL, "UPDATE_MASTERY=+1", NULL_KEY);
    }
}