// Imperial Arts and Culture Module - Literature Submodule
// Handles literary works, authors, and literary salons

// Communication channels
integer ARTS_CORE_CHANNEL = -7654321;
integer LITERATURE_MODULE_CHANNEL = -7654323;

// Literature database
list literaryWorks = [
    "War and Peace", "Leo Tolstoy", "1869", "Epic novel of Russian society during the Napoleonic era",
    "Anna Karenina", "Leo Tolstoy", "1877", "Tragic tale of a married aristocrat and her affair with Count Vronsky",
    "Crime and Punishment", "Fyodor Dostoevsky", "1866", "Psychological novel about a poor student who commits murder",
    "The Brothers Karamazov", "Fyodor Dostoevsky", "1880", "Complex novel about faith, doubt, and moral struggles",
    "Eugene Onegin", "Alexander Pushkin", "1833", "Novel in verse about a selfish hero who rejects a young woman's love"
];

list russianAuthors = [
    "Leo Tolstoy", "Novelist", "1828-1910", "Count who wrote epic novels and later became a moral thinker",
    "Fyodor Dostoevsky", "Novelist", "1821-1881", "Psychological novelist exploring human nature and spirituality",
    "Alexander Pushkin", "Poet", "1799-1837", "Founder of modern Russian literature, died in a duel",
    "Anton Chekhov", "Playwright", "1860-1904", "Master of the short story and dramatic realism",
    "Ivan Turgenev", "Novelist", "1818-1883", "Chronicler of social change and generational conflict"
];

// Display literature menu
integer displayLiteratureMenu(key id) {
    llDialog(id, "Russian Literature\n\nSelect an option:",
        ["Notable Works", "Famous Authors", "Literary Discussion", "Private Reading", "Patronize Literature", "Back"], LITERATURE_MODULE_CHANNEL);
    return TRUE;
}

// Display literary works
integer displayWorks(key id) {
    string info = "Notable Literary Works:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(literaryWorks); i += 4) {
        string title = llList2String(literaryWorks, i);
        string author = llList2String(literaryWorks, i+1);
        string year = llList2String(literaryWorks, i+2);
        string description = llList2String(literaryWorks, i+3);
        
        info += title + "\n";
        info += "  Author: " + author + "\n";
        info += "  Published: " + year + "\n";
        info += "  Description: " + description + "\n\n";
    }
    
    llDialog(id, info, ["Discuss Literature", "Back to Literature"], LITERATURE_MODULE_CHANNEL);
    return TRUE;
}

// Display Russian authors
integer displayAuthors(key id) {
    string info = "Prominent Russian Authors:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(russianAuthors); i += 4) {
        string name = llList2String(russianAuthors, i);
        string profession = llList2String(russianAuthors, i+1);
        string lifespan = llList2String(russianAuthors, i+2);
        string note = llList2String(russianAuthors, i+3);
        
        info += name + "\n";
        info += "  Profession: " + profession + "\n";
        info += "  Lived: " + lifespan + "\n";
        info += "  Note: " + note + "\n\n";
    }
    
    llDialog(id, info, ["Back to Literature"], LITERATURE_MODULE_CHANNEL);
    return TRUE;
}

// Literary discussion
integer discussLiterature(key id) {
    // Choose a random work to discuss
    integer numWorks = llGetListLength(literaryWorks) / 4;
    integer workIndex = (integer)(llFrand((float)numWorks)) * 4;
    
    string workTitle = llList2String(literaryWorks, workIndex);
    string workAuthor = llList2String(literaryWorks, workIndex + 1);
    
    // Generate discussion
    llSay(0, llGetDisplayName(llGetOwner()) + " leads an intellectual discussion on " + workTitle + " by " + workAuthor + ".");
    
    // Generate random insights based on the work
    list possibleInsights = [
        "explores the conflict between tradition and modernity in Russian society.",
        "represents the struggle of the individual against societal constraints.",
        "examines questions of morality and the nature of human suffering.",
        "presents a critique of aristocratic superficiality while honoring authentic human connections.",
        "reflects the philosophical questions dominating Russian intellectual life of the period."
    ];
    
    integer insightIndex = (integer)(llFrand(llGetListLength(possibleInsights)));
    
    llSay(0, "The discussion particularly focuses on how the work " + llList2String(possibleInsights, insightIndex));
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "UPDATE_APPRECIATION=+4", NULL_KEY);
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "UPDATE_INFLUENCE=+2", NULL_KEY);
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayLiteratureMenu(id);
    
    return TRUE;
}

// Private reading
integer privateReading(key id) {
    // Choose a random work to read
    integer numWorks = llGetListLength(literaryWorks) / 4;
    integer workIndex = (integer)(llFrand((float)numWorks)) * 4;
    
    string workTitle = llList2String(literaryWorks, workIndex);
    string workAuthor = llList2String(literaryWorks, workIndex + 1);
    string workDescription = llList2String(literaryWorks, workIndex + 3);
    
    llOwnerSay("You spend a quiet evening engaged in reading " + workTitle + " by " + workAuthor + ".");
    llOwnerSay("The work " + workDescription);
    
    // Reflection on reading
    list possibleReflections = [
        "You find yourself deeply moved by the profound themes explored in the text.",
        "The author's insights into human nature resonate with your own observations of court society.",
        "You appreciate the mastery of language and the vivid portrayal of Russian life.",
        "The moral questions raised by the narrative prompt personal reflection on your own values.",
        "You recognize both the artistic merit and the philosophical significance of the work."
    ];
    
    integer reflectionIndex = (integer)(llFrand(llGetListLength(possibleReflections)));
    
    llOwnerSay(llList2String(possibleReflections, reflectionIndex));
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "UPDATE_APPRECIATION=+2", NULL_KEY);
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayLiteratureMenu(id);
    
    return TRUE;
}

// Patronize literature
integer patronizeLiterature(key id) {
    llSay(0, llGetDisplayName(llGetOwner()) + " becomes a patron of literature, supporting writers and hosting literary salons.");
    
    // Significant influence gain
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "UPDATE_INFLUENCE=+5", NULL_KEY);
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "SET_PREFERENCE=Literature", NULL_KEY);
    
    // Special effects of patronage
    llOwnerSay("As a literary patron, you commission works and support journals that publish important writers. Authors seek your opinion and dedicate works to you.");
    llOwnerSay("Your salon becomes known as an essential gathering place for intellectual discussion and cultural exchange.");
    
    // Return to main arts menu
    llSleep(3.0);
    llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
    
    return TRUE;
}

default {
    state_entry() {
        llListen(LITERATURE_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == LITERATURE_MODULE_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayLiteratureMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Literature module initialized.");
            }
            else if(str == "PATRONIZE") {
                patronizeLiterature(id);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == LITERATURE_MODULE_CHANNEL) {
            if(message == "Notable Works") {
                displayWorks(id);
            }
            else if(message == "Famous Authors") {
                displayAuthors(id);
            }
            else if(message == "Literary Discussion" || message == "Discuss Literature") {
                discussLiterature(id);
            }
            else if(message == "Private Reading") {
                privateReading(id);
            }
            else if(message == "Patronize Literature") {
                patronizeLiterature(id);
            }
            else if(message == "Back to Literature") {
                displayLiteratureMenu(id);
            }
            else if(message == "Back") {
                llMessageLinked(LINK_SET, LITERATURE_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
}