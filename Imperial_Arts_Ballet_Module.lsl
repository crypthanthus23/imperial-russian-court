// Imperial Arts and Culture Module - Ballet Submodule
// Handles ballet performances, dancers, and imperial patronage

// Communication channels
integer ARTS_CORE_CHANNEL = -7654321;
integer BALLET_MODULE_CHANNEL = -7654322;

// Ballet database
list balletProductions = [
    "Swan Lake", "Tchaikovsky", "Imperial Mariinsky Theatre", "Legendary ballet about a princess turned into a swan",
    "The Sleeping Beauty", "Tchaikovsky", "Imperial Mariinsky Theatre", "Based on the fairy tale by Charles Perrault",
    "Giselle", "Adolphe Adam", "Imperial Bolshoi Kamenny Theatre", "Romantic ballet about a peasant girl who dies of a broken heart",
    "La Bayadère", "Ludwig Minkus", "Imperial Mariinsky Theatre", "Exotic tale set in ancient India",
    "The Nutcracker", "Tchaikovsky", "Imperial Mariinsky Theatre", "Christmas story of a girl and her nutcracker prince"
];

list balletDancers = [
    "Anna Pavlova", "Prima Ballerina", "Imperial Mariinsky Theatre", "Known for 'The Dying Swan' solo",
    "Tamara Karsavina", "Prima Ballerina", "Imperial Mariinsky Theatre", "Partner of Nijinsky in many ballets",
    "Vaslav Nijinsky", "Premier Danseur", "Imperial Mariinsky Theatre", "Revolutionary male dancer known for spectacular leaps",
    "Mathilde Kschessinska", "Prima Ballerina Assoluta", "Imperial Mariinsky Theatre", "Former mistress of Tsar Nicholas II",
    "Olga Preobrajenska", "Prima Ballerina", "Imperial Mariinsky Theatre", "Renowned for technical precision"
];

// Display ballet menu
integer displayBalletMenu(key id) {
    llDialog(id, "Imperial Ballet\n\nSelect an option:",
        ["Productions", "Famous Dancers", "Attend Performance", "Learn About Ballet", "Patronize Ballet", "Back"], BALLET_MODULE_CHANNEL);
    return TRUE;
}

// Display ballet productions
integer displayProductions(key id) {
    string info = "Notable Ballet Productions:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(balletProductions); i += 4) {
        string title = llList2String(balletProductions, i);
        string composer = llList2String(balletProductions, i+1);
        string venue = llList2String(balletProductions, i+2);
        string description = llList2String(balletProductions, i+3);
        
        info += title + "\n";
        info += "  Composer: " + composer + "\n";
        info += "  Venue: " + venue + "\n";
        info += "  Description: " + description + "\n\n";
    }
    
    llDialog(id, info, ["Attend Performance", "Back to Ballet"], BALLET_MODULE_CHANNEL);
    return TRUE;
}

// Display ballet dancers
integer displayDancers(key id) {
    string info = "Famous Ballet Dancers:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(balletDancers); i += 4) {
        string name = llList2String(balletDancers, i);
        string title = llList2String(balletDancers, i+1);
        string company = llList2String(balletDancers, i+2);
        string note = llList2String(balletDancers, i+3);
        
        info += name + "\n";
        info += "  Title: " + title + "\n";
        info += "  Company: " + company + "\n";
        info += "  Note: " + note + "\n\n";
    }
    
    llDialog(id, info, ["Back to Ballet"], BALLET_MODULE_CHANNEL);
    return TRUE;
}

// Attend ballet performance
integer attendPerformance(key id) {
    // Choose a random ballet
    integer numBallets = llGetListLength(balletProductions) / 4;
    integer balletIndex = (integer)(llFrand((float)numBallets)) * 4;
    
    string balletTitle = llList2String(balletProductions, balletIndex);
    string balletComposer = llList2String(balletProductions, balletIndex + 1);
    string balletVenue = llList2String(balletProductions, balletIndex + 2);
    
    // Choose a random dancer
    integer numDancers = llGetListLength(balletDancers) / 4;
    integer dancerIndex = (integer)(llFrand((float)numDancers)) * 4;
    
    string dancerName = llList2String(balletDancers, dancerIndex);
    
    // Describe the experience
    llSay(0, llGetDisplayName(llGetOwner()) + " attends a performance of " + balletTitle + " by " + balletComposer + " at the " + balletVenue + ".");
    llSay(0, "The legendary " + dancerName + " dances the principal role to thunderous applause.");
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "UPDATE_APPRECIATION=+3", NULL_KEY);
    
    // Random special event
    integer specialEvent = (integer)(llFrand(100.0));
    
    if(specialEvent > 80) {
        llSay(0, "Members of the Imperial family are in attendance. Their presence elevates the social significance of the event.");
        llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "UPDATE_INFLUENCE=+2", NULL_KEY);
    }
    else if(specialEvent > 60) {
        llSay(0, "During the intermission, you engage in stimulating conversation with cultural dignitaries about the artistic merits of the production.");
        llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "UPDATE_APPRECIATION=+1", NULL_KEY);
    }
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayBalletMenu(id);
    
    return TRUE;
}

// Learn about ballet history and techniques
integer learnBallet(key id) {
    string info = "The Art of Ballet in Imperial Russia:\n\n";
    info += "Russian Imperial Ballet represents the pinnacle of classical dance tradition, shaped by French and Italian influences but developed into a distinctive Russian style.\n\n";
    info += "The Imperial Theatre School (later the Vaganova Academy) trains dancers from childhood in rigorous technique. Ballet masters like Marius Petipa created the grand narrative ballets that define the Russian repertoire.\n\n";
    info += "Ballet in Russia is not merely entertainment but a sophisticated art form that embodies imperial prestige and cultural achievement. The Tsar's patronage elevates ballet to a symbol of Russian artistic excellence.";
    
    llDialog(id, info, ["Back to Ballet"], BALLET_MODULE_CHANNEL);
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "UPDATE_APPRECIATION=+2", NULL_KEY);
    
    return TRUE;
}

// Patronize ballet
integer patronizeBallet(key id) {
    llSay(0, llGetDisplayName(llGetOwner()) + " becomes a patron of the Imperial Ballet, providing financial support and social prestige to the company.");
    
    // Significant influence gain
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "UPDATE_INFLUENCE=+5", NULL_KEY);
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "SET_PREFERENCE=Ballet", NULL_KEY);
    
    // Special effects of patronage
    llOwnerSay("As a ballet patron, you gain privileged access to rehearsals and dancers' salons. The ballet master promises to dedicate an upcoming production to you.");
    llOwnerSay("Your patronage significantly enhances your cultural reputation in court society.");
    
    // Return to main arts menu
    llSleep(3.0);
    llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
    
    return TRUE;
}

default {
    state_entry() {
        llListen(BALLET_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == BALLET_MODULE_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayBalletMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Ballet module initialized.");
            }
            else if(str == "PATRONIZE") {
                patronizeBallet(id);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == BALLET_MODULE_CHANNEL) {
            if(message == "Productions") {
                displayProductions(id);
            }
            else if(message == "Famous Dancers") {
                displayDancers(id);
            }
            else if(message == "Attend Performance") {
                attendPerformance(id);
            }
            else if(message == "Learn About Ballet") {
                learnBallet(id);
            }
            else if(message == "Patronize Ballet") {
                patronizeBallet(id);
            }
            else if(message == "Back to Ballet") {
                displayBalletMenu(id);
            }
            else if(message == "Back") {
                llMessageLinked(LINK_SET, BALLET_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
}