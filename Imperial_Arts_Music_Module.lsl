// Imperial Arts and Culture Module - Music Submodule
// Handles music, composers, and concert attendance

// Communication channels
integer ARTS_CORE_CHANNEL = -7654321;
integer MUSIC_MODULE_CHANNEL = -7654325;

// Music database
list compositions = [
    "Symphony No. 6 (Pathétique)", "Pyotr Tchaikovsky", "1893", "Emotionally intense symphony, premiered nine days before the composer's death",
    "Boris Godunov", "Modest Mussorgsky", "1874", "Opera about the Russian ruler, based on Pushkin's play",
    "The Seasons", "Pyotr Tchaikovsky", "1876", "Set of twelve piano pieces representing each month",
    "Prince Igor", "Alexander Borodin", "1890", "Epic opera based on the 12th-century Tale of Igor's Campaign",
    "Pictures at an Exhibition", "Modest Mussorgsky", "1874", "Piano suite later orchestrated by Ravel"
];

list russianComposers = [
    "Pyotr Tchaikovsky", "Composer", "1840-1893", "Renowned for ballets, symphonies, and operas",
    "Modest Mussorgsky", "Composer", "1839-1881", "Member of The Five, known for innovative compositions",
    "Nikolai Rimsky-Korsakov", "Composer", "1844-1908", "Master orchestrator from The Five",
    "Alexander Borodin", "Composer", "1833-1887", "Member of The Five, also a notable chemist",
    "Sergei Rachmaninoff", "Composer", "1873-1943", "Virtuoso pianist and late Romantic composer"
];

// Display music menu
integer displayMusicMenu(key id) {
    llDialog(id, "Russian Music\n\nSelect an option:",
        ["Compositions", "Composers", "Attend Concert", "Private Performance", "Patronize Music", "Back"], MUSIC_MODULE_CHANNEL);
    return TRUE;
}

// Display compositions
integer displayCompositions(key id) {
    string info = "Notable Russian Compositions:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(compositions); i += 4) {
        string title = llList2String(compositions, i);
        string composer = llList2String(compositions, i+1);
        string year = llList2String(compositions, i+2);
        string description = llList2String(compositions, i+3);
        
        info += title + "\n";
        info += "  Composer: " + composer + "\n";
        info += "  Composed: " + year + "\n";
        info += "  Description: " + description + "\n\n";
    }
    
    llDialog(id, info, ["Attend Concert", "Back to Music"], MUSIC_MODULE_CHANNEL);
    return TRUE;
}

// Display composers
integer displayComposers(key id) {
    string info = "Prominent Russian Composers:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(russianComposers); i += 4) {
        string name = llList2String(russianComposers, i);
        string profession = llList2String(russianComposers, i+1);
        string lifespan = llList2String(russianComposers, i+2);
        string note = llList2String(russianComposers, i+3);
        
        info += name + "\n";
        info += "  Profession: " + profession + "\n";
        info += "  Lived: " + lifespan + "\n";
        info += "  Note: " + note + "\n\n";
    }
    
    llDialog(id, info, ["Private Performance", "Back to Music"], MUSIC_MODULE_CHANNEL);
    return TRUE;
}

// Attend concert
integer attendConcert(key id) {
    // Different venues for variety
    list venues = [
        "the Mariinsky Theatre", "an orchestral performance",
        "the Bolshoi Kamenny Theatre", "an operatic production",
        "the Saint Petersburg Conservatory", "a piano recital", 
        "the Philharmonic Hall", "a chamber music concert"
    ];
    
    // Choose a random venue
    integer venueIndex = (integer)(llFrand(llGetListLength(venues) / 2)) * 2;
    
    string venueName = llList2String(venues, venueIndex);
    string performanceType = llList2String(venues, venueIndex + 1);
    
    // Choose a random composition
    integer numCompositions = llGetListLength(compositions) / 4;
    integer compositionIndex = (integer)(llFrand((float)numCompositions)) * 4;
    
    string compositionTitle = llList2String(compositions, compositionIndex);
    string compositionComposer = llList2String(compositions, compositionIndex + 1);
    
    llSay(0, llGetDisplayName(llGetOwner()) + " attends " + performanceType + " at " + venueName + ".");
    llSay(0, "The program features " + compositionTitle + " by " + compositionComposer + ", performed with technical precision and emotional depth.");
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "UPDATE_APPRECIATION=+3", NULL_KEY);
    
    // Social aspect
    llSay(0, "During the intermission, you engage in cultural discourse with other distinguished attendees, enhancing your social connections.");
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "UPDATE_INFLUENCE=+1", NULL_KEY);
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayMusicMenu(id);
    
    return TRUE;
}

// Host private performance
integer hostPrivatePerformance(key id) {
    // Choose a random composer
    integer numComposers = llGetListLength(russianComposers) / 4;
    integer composerIndex = (integer)(llFrand((float)numComposers)) * 4;
    
    string composerName = llList2String(russianComposers, composerIndex);
    
    // Choose a random composition
    integer numCompositions = llGetListLength(compositions) / 4;
    integer compositionIndex = (integer)(llFrand((float)numCompositions)) * 4;
    
    string compositionTitle = llList2String(compositions, compositionIndex);
    
    llSay(0, llGetDisplayName(llGetOwner()) + " hosts a private musical soirée featuring works by " + composerName + ".");
    llSay(0, "The highlight of the evening is an exquisite performance of " + compositionTitle + ", which earns enthusiastic appreciation from the select guests.");
    
    // Social impact
    llSay(0, "The exclusive nature of your musical gathering enhances your reputation as a discerning patron of the arts.");
    
    // Influence increase
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "UPDATE_INFLUENCE=+3", NULL_KEY);
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "UPDATE_APPRECIATION=+2", NULL_KEY);
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayMusicMenu(id);
    
    return TRUE;
}

// Patronize music
integer patronizeMusic(key id) {
    llSay(0, llGetDisplayName(llGetOwner()) + " becomes a patron of music, supporting composers, musicians, and musical organizations.");
    
    // Significant influence gain
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "UPDATE_INFLUENCE=+5", NULL_KEY);
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "SET_PREFERENCE=Music", NULL_KEY);
    
    // Special effects of patronage
    llOwnerSay("As a music patron, you commission new compositions, sponsor concerts, and support promising musicians. Composers dedicate works to you.");
    llOwnerSay("Your name becomes associated with musical excellence, and your opinions on musical matters are highly regarded.");
    
    // Return to main arts menu
    llSleep(3.0);
    llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
    
    return TRUE;
}

default {
    state_entry() {
        llListen(MUSIC_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == MUSIC_MODULE_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayMusicMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Music module initialized.");
            }
            else if(str == "PATRONIZE") {
                patronizeMusic(id);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == MUSIC_MODULE_CHANNEL) {
            if(message == "Compositions") {
                displayCompositions(id);
            }
            else if(message == "Composers") {
                displayComposers(id);
            }
            else if(message == "Attend Concert") {
                attendConcert(id);
            }
            else if(message == "Private Performance") {
                hostPrivatePerformance(id);
            }
            else if(message == "Patronize Music") {
                patronizeMusic(id);
            }
            else if(message == "Back to Music") {
                displayMusicMenu(id);
            }
            else if(message == "Back") {
                llMessageLinked(LINK_SET, MUSIC_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
}