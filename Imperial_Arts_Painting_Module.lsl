// Imperial Arts and Culture Module - Painting Submodule
// Handles painting, visual arts, and exhibitions

// Communication channels
integer ARTS_CORE_CHANNEL = -7654321;
integer PAINTING_MODULE_CHANNEL = -7654324;

// Painting database
list paintings = [
    "Reply of the Zaporozhian Cossacks", "Ilya Repin", "1891", "Historical scene depicting Cossacks mocking the Ottoman Sultan",
    "The Ninth Wave", "Ivan Aivazovsky", "1850", "Dramatic seascape showing survivors after a shipwreck",
    "The Boyarynya Morozova", "Vasily Surikov", "1887", "Historical scene of an Old Believer being arrested",
    "Barge Haulers on the Volga", "Ilya Repin", "1873", "Social realist depiction of men pulling a barge",
    "Morning in a Pine Forest", "Ivan Shishkin", "1889", "Naturalistic forest scene with bear cubs"
];

list russianArtists = [
    "Ilya Repin", "Realist Painter", "1844-1930", "Leading figure of the Peredvizhniki movement",
    "Ivan Aivazovsky", "Romantic Painter", "1817-1900", "Celebrated for his seascapes",
    "Vasily Surikov", "Historical Painter", "1848-1916", "Master of large historical canvases",
    "Ivan Shishkin", "Landscape Painter", "1832-1898", "Known as 'Forest Tsar' for his woodland scenes",
    "Viktor Vasnetsov", "Historical Painter", "1848-1926", "Known for mythological and historical subjects"
];

// Display painting menu
integer displayPaintingMenu(key id) {
    llDialog(id, "Russian Painting\n\nSelect an option:",
        ["Notable Works", "Famous Artists", "Visit Gallery", "Commission Portrait", "Patronize Painting", "Back"], PAINTING_MODULE_CHANNEL);
    return TRUE;
}

// Display notable paintings
integer displayPaintings(key id) {
    string info = "Notable Russian Paintings:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(paintings); i += 4) {
        string title = llList2String(paintings, i);
        string artist = llList2String(paintings, i+1);
        string year = llList2String(paintings, i+2);
        string description = llList2String(paintings, i+3);
        
        info += title + "\n";
        info += "  Artist: " + artist + "\n";
        info += "  Created: " + year + "\n";
        info += "  Description: " + description + "\n\n";
    }
    
    llDialog(id, info, ["Visit Gallery", "Back to Painting"], PAINTING_MODULE_CHANNEL);
    return TRUE;
}

// Display Russian artists
integer displayArtists(key id) {
    string info = "Prominent Russian Artists:\n\n";
    
    integer i;
    for(i = 0; i < llGetListLength(russianArtists); i += 4) {
        string name = llList2String(russianArtists, i);
        string specialty = llList2String(russianArtists, i+1);
        string lifespan = llList2String(russianArtists, i+2);
        string note = llList2String(russianArtists, i+3);
        
        info += name + "\n";
        info += "  Specialty: " + specialty + "\n";
        info += "  Lived: " + lifespan + "\n";
        info += "  Note: " + note + "\n\n";
    }
    
    llDialog(id, info, ["Commission Portrait", "Back to Painting"], PAINTING_MODULE_CHANNEL);
    return TRUE;
}

// Visit art gallery
integer visitGallery(key id) {
    // Different gallery options for variety
    list galleries = [
        "the Hermitage Museum", "you admire the extensive collection of European and Russian masterpieces.",
        "the Imperial Academy of Arts", "you view the latest works by the Academy's students and professors.",
        "the private collection of Prince Yusupov", "you appreciate the curated selection of both Russian and foreign artists.",
        "the Tretyakov Gallery", "you explore the definitive collection of native Russian art."
    ];
    
    // Choose a random gallery
    integer galleryIndex = (integer)(llFrand(llGetListLength(galleries) / 2)) * 2;
    
    string galleryName = llList2String(galleries, galleryIndex);
    string galleryExperience = llList2String(galleries, galleryIndex + 1);
    
    llSay(0, llGetDisplayName(llGetOwner()) + " visits " + galleryName + ", where " + galleryExperience);
    
    // Choose a random painting to focus on
    integer numPaintings = llGetListLength(paintings) / 4;
    integer paintingIndex = (integer)(llFrand((float)numPaintings)) * 4;
    
    string paintingTitle = llList2String(paintings, paintingIndex);
    string paintingArtist = llList2String(paintings, paintingIndex + 1);
    
    llSay(0, "You spend considerable time contemplating " + paintingTitle + " by " + paintingArtist + ", noting the artistic techniques and symbolic elements.");
    
    // Increase art appreciation
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "UPDATE_APPRECIATION=+3", NULL_KEY);
    
    // Special event possibility
    if(llFrand(100.0) > 70.0) {
        llSay(0, "You engage in conversation with a knowledgeable art curator who offers fascinating insights about the painting's historical context.");
        llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "UPDATE_APPRECIATION=+1", NULL_KEY);
    }
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayPaintingMenu(id);
    
    return TRUE;
}

// Commission portrait
integer commissionPortrait(key id) {
    // Choose a random artist
    integer numArtists = llGetListLength(russianArtists) / 4;
    integer artistIndex = (integer)(llFrand((float)numArtists)) * 4;
    
    string artistName = llList2String(russianArtists, artistIndex);
    
    llSay(0, llGetDisplayName(llGetOwner()) + " commissions " + artistName + " to paint an official portrait.");
    
    // Portrait description
    list portraitStyles = [
        "The portrait depicts you in formal court attire, emphasizing your dignity and noble bearing.",
        "The artist captures your likeness in a thoughtful pose with symbols of your cultural interests.",
        "The composition places you in an elegant interior that reflects your refined aesthetic sensibilities.",
        "The portrait balances formal dignity with a suggestion of your individual character and intellect."
    ];
    
    integer styleIndex = (integer)(llFrand(llGetListLength(portraitStyles)));
    
    llSay(0, llList2String(portraitStyles, styleIndex));
    
    // Social impact
    llSay(0, "The commission enhances your status as a cultural patron and provides meaningful support to a significant artist.");
    
    // Influence increase
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "UPDATE_INFLUENCE=+3", NULL_KEY);
    
    // Return to menu after a short delay
    llSleep(2.0);
    displayPaintingMenu(id);
    
    return TRUE;
}

// Patronize painting
integer patronizePainting(key id) {
    llSay(0, llGetDisplayName(llGetOwner()) + " becomes a patron of painting, supporting artists and sponsoring exhibitions.");
    
    // Significant influence gain
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "UPDATE_INFLUENCE=+5", NULL_KEY);
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "SET_PREFERENCE=Painting", NULL_KEY);
    
    // Special effects of patronage
    llOwnerSay("As a patron of painting, you collect important works, commission artists, and fund exhibitions that shape artistic taste in Russian society.");
    llOwnerSay("Artists seek your approval and dedicate works to you, while your art collection becomes known for its quality and vision.");
    
    // Return to main arts menu
    llSleep(3.0);
    llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
    
    return TRUE;
}

default {
    state_entry() {
        llListen(PAINTING_MODULE_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == PAINTING_MODULE_CHANNEL) {
            if(str == "DISPLAY_MENU") {
                displayPaintingMenu(id);
            }
            else if(str == "INIT") {
                // Initialization from core
                llOwnerSay("Painting module initialized.");
            }
            else if(str == "PATRONIZE") {
                patronizePainting(id);
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == PAINTING_MODULE_CHANNEL) {
            if(message == "Notable Works") {
                displayPaintings(id);
            }
            else if(message == "Famous Artists") {
                displayArtists(id);
            }
            else if(message == "Visit Gallery") {
                visitGallery(id);
            }
            else if(message == "Commission Portrait") {
                commissionPortrait(id);
            }
            else if(message == "Patronize Painting") {
                patronizePainting(id);
            }
            else if(message == "Back to Painting") {
                displayPaintingMenu(id);
            }
            else if(message == "Back") {
                llMessageLinked(LINK_SET, PAINTING_MODULE_CHANNEL, "DISPLAY_CORE_MENU", id);
            }
        }
    }
}