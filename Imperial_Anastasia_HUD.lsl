// Imperial Anastasia HUD
// Special HUD for Grand Duchess Anastasia Nikolaevna Romanov
// Known as "The Imp" - Mischievous, humorous, energetic, playful
// Fourth and youngest daughter of Tsar Nicholas II and Tsarina Alexandra Feodorovna

// Constants
integer HUD_LINK_MESSAGE_CHANNEL = 42;
integer ANASTASIA_CHANNEL = -50;

// Player data
string playerName = "Anastasia Nikolaevna";
string playerTitle = "Her Imperial Highness Grand Duchess";
string playerFullTitle = "Her Imperial Highness Grand Duchess Anastasia Nikolaevna Romanov of Russia";
string playerNickname = "The Imp";
string playerBirth = "1901";
string playerHealth = "Excellent";
string playerFaith = "100";
string playerInfluence = "65";
string playerCharm = "90";
string playerWealth = "Imperial Allowance";
integer playerRubles = 5000;
integer isOOCMode = FALSE;
integer playerStress = 5; // Private stress level
string playerPersonality = "Mischievous, humorous, energetic, playful";
string playerTalent = "Mimicry, comedy, photography, climbing";

// Prank history - format: [prank, victim, success]
list prankHistory = [
    "Hidden Alarm Clock", "French Tutor", "Success",
    "Frogs in Shoes", "English Tutor", "Success",
    "Mustache Drawing", "Sleeping Guard", "Success",
    "Hidden Notes", "Sisters", "Partial Success",
    "Doorway Bucket", "Palace Staff", "Discovered"
];

// Photography collection - format: [subject, quality, notes]
list photoCollection = [
    "Family Informal", "Good", "Candid shots",
    "Palace Guards", "Fair", "Caught unaware",
    "Alexei Playing", "Excellent", "His favorite",
    "Sisters Laughing", "Very Good", "Natural poses",
    "Self-Portrait", "Good", "Silly faces"
];

// Mimicry targets - format: [person, accuracy, reaction]
list mimicryTargets = [
    "Tutor Gibbes", "Excellent", "Secretly Amused",
    "Court Official", "Very Good", "Offended",
    "Dowager Empress", "Good", "Would Be Appalled",
    "Baroness Buxhoeveden", "Excellent", "Embarrassed",
    "Father (the Tsar)", "Fair", "Tolerant"
];

// Family relationships - format: [name, relationship, closeness]
list familyRelationships = [
    "Nikolai II", "Father", "Daddy's Girl",
    "Alexandra Feodorovna", "Mother", "Mischievous With",
    "Alexei Nikolaevich", "Brother", "Inseparable",
    "Olga Nikolaevna", "Eldest Sister", "Teases Often",
    "Tatiana Nikolaevna", "Elder Sister", "Tests Patience Of",
    "Maria Nikolaevna", "Elder Sister", "Inseparable (The Little Pair)"
];

// Recreation activities - format: [activity, skill, enjoyment]
list recreationActivities = [
    "Climbing Trees", "Expert", "Very High",
    "Photography", "Intermediate", "High",
    "Snowball Fights", "Advanced", "Very High",
    "Playing with Pets", "Expert", "Very High",
    "Theatrical Performances", "Advanced", "High"
];

// Update HUD display
updateHUDDisplay() {
    string display = "";
    
    if(!isOOCMode) {
        display = playerFullTitle + "\n";
        display += playerNickname + " • Born: " + playerBirth + "\n";
        display += "Health: " + playerHealth + " • Faith: " + playerFaith + "\n";
        display += "Influence: " + playerInfluence + " • Charm: " + playerCharm + "\n";
        display += "Imperial Allowance: " + (string)playerRubles + " rubles\n";
        display += "✧ " + playerTalent + " ✧";
    } 
    else {
        display = "[OOC] " + llGetDisplayName(llGetOwner()) + " is out of character";
    }
    
    llSetText(display, <0.9, 0.8, 1.0>, 1.0);
}

// Generate family report
string generateFamilyReport() {
    string report = "Imperial Family Relationships:\n\n";
    
    integer i;
    integer count = llGetListLength(familyRelationships);
    
    for(i = 0; i < count; i += 3) {
        string name = llList2String(familyRelationships, i);
        string relation = llList2String(familyRelationships, i+1);
        string closeness = llList2String(familyRelationships, i+2);
        
        report += name + " (" + relation + ")\n";
        report += "   Relationship: " + closeness + "\n\n";
    }
    
    return report;
}

// Generate prank history report
string generatePrankReport() {
    string report = "Famous Pranks:\n\n";
    
    integer i;
    integer count = llGetListLength(prankHistory);
    
    for(i = 0; i < count; i += 3) {
        string prank = llList2String(prankHistory, i);
        string victim = llList2String(prankHistory, i+1);
        string success = llList2String(prankHistory, i+2);
        
        report += prank + "\n";
        report += "   Target: " + victim + "\n";
        report += "   Outcome: " + success + "\n\n";
    }
    
    return report;
}

// Generate photography report
string generatePhotographyReport() {
    string report = "Photography Collection:\n\n";
    
    integer i;
    integer count = llGetListLength(photoCollection);
    
    for(i = 0; i < count; i += 3) {
        string subject = llList2String(photoCollection, i);
        string quality = llList2String(photoCollection, i+1);
        string notes = llList2String(photoCollection, i+2);
        
        report += subject + "\n";
        report += "   Quality: " + quality + "\n";
        report += "   Notes: " + notes + "\n\n";
    }
    
    return report;
}

// Generate mimicry report
string generateMimicryReport() {
    string report = "Famous Impressions:\n\n";
    
    integer i;
    integer count = llGetListLength(mimicryTargets);
    
    for(i = 0; i < count; i += 3) {
        string person = llList2String(mimicryTargets, i);
        string accuracy = llList2String(mimicryTargets, i+1);
        string reaction = llList2String(mimicryTargets, i+2);
        
        report += person + "\n";
        report += "   Accuracy: " + accuracy + "\n";
        report += "   Reaction: " + reaction + "\n\n";
    }
    
    return report;
}

// Generate recreation report
string generateRecreationReport() {
    string report = "Favorite Activities:\n\n";
    
    integer i;
    integer count = llGetListLength(recreationActivities);
    
    for(i = 0; i < count; i += 3) {
        string activity = llList2String(recreationActivities, i);
        string skill = llList2String(recreationActivities, i+1);
        string enjoyment = llList2String(recreationActivities, i+2);
        
        report += activity + "\n";
        report += "   Skill Level: " + skill + "\n";
        report += "   Enjoyment: " + enjoyment + "\n\n";
    }
    
    return report;
}

// Execute prank
executePrank(string target) {
    string prankType = "";
    string outcome = "";
    integer success = (integer)(llFrand(100.0));
    
    // Different pranks for different targets
    if(target == "Tutors") {
        prankType = "Hiding textbooks";
        if(success > 30) outcome = "Success";
        else outcome = "Discovered";
        
        if(outcome == "Success") {
            llSay(0, playerFullTitle + " successfully hides the tutors' textbooks, causing a delay in lessons.");
            playerCharm = (string)((integer)playerCharm + 1);
            reduceStress(15);
        }
        else {
            llSay(0, playerFullTitle + " attempts to hide the tutors' textbooks but is caught in the act.");
            addStress(5);
        }
    }
    else if(target == "Sisters") {
        prankType = "Rearranging personal items";
        if(success > 50) outcome = "Success";
        else outcome = "Partial Success";
        
        if(outcome == "Success") {
            llSay(0, playerFullTitle + " rearranges her sisters' personal items, creating amusing confusion.");
            playerCharm = (string)((integer)playerCharm + 2);
            reduceStress(10);
        }
        else {
            llSay(0, playerFullTitle + " only manages to mildly confuse her sisters with her prank.");
            reduceStress(5);
        }
    }
    else if(target == "Palace Staff") {
        prankType = "Doorway bucket trap";
        if(success > 70) outcome = "Success";
        else outcome = "Discovered";
        
        if(outcome == "Success") {
            llSay(0, playerFullTitle + " successfully sets up a harmless prank for the palace staff, causing a great deal of laughter.");
            playerCharm = (string)((integer)playerCharm + 3);
            reduceStress(15);
        }
        else {
            llSay(0, playerFullTitle + " is caught setting up a prank for the palace staff and is gently scolded.");
            addStress(8);
        }
    }
    else if(target == "Guards") {
        prankType = "Distracting from posts";
        if(success > 80) outcome = "Success";
        else outcome = "Discovered";
        
        if(outcome == "Success") {
            llSay(0, playerFullTitle + " successfully distracts the palace guards with an elaborate ruse.");
            playerCharm = (string)((integer)playerCharm + 2);
            reduceStress(12);
        }
        else {
            llSay(0, playerFullTitle + " fails to distract the disciplined palace guards and receives a formal complaint.");
            addStress(10);
        }
    }
    
    // Add to prank history
    if(prankType != "") {
        // If we have too many entries, remove oldest
        if(llGetListLength(prankHistory) >= 18) { // Max 6 entries (6x3=18)
            prankHistory = llDeleteSubList(prankHistory, 0, 2);
        }
        
        prankHistory += [prankType, target, outcome];
    }
    
    updateHUDDisplay();
}

// Take photograph
takePhotograph(string subject) {
    string quality = "Fair";
    integer skill = (integer)((llFrand(1.0) * 50.0) + (llFrand(1.0) * (float)playerCharm));
    
    if(skill > 120) quality = "Excellent";
    else if(skill > 100) quality = "Very Good";
    else if(skill > 80) quality = "Good";
    else quality = "Fair";
    
    string notes = "";
    
    // Different subjects, different notes
    if(subject == "Family") {
        notes = "Candid family moment";
        llSay(0, playerFullTitle + " captures a " + quality + " photograph of the Imperial Family in an informal setting.");
    }
    else if(subject == "Alexei") {
        notes = "Joyful moment with brother";
        llSay(0, playerFullTitle + " takes a " + quality + " photograph of Tsarevich Alexei during playtime.");
    }
    else if(subject == "Palace") {
        notes = "Unique architectural angle";
        llSay(0, playerFullTitle + " photographs an interesting perspective of the palace architecture.");
    }
    else if(subject == "Silly Self-Portrait") {
        notes = "Characteristic silliness";
        llSay(0, playerFullTitle + " creates a " + quality + " humorous self-portrait displaying her playful personality.");
    }
    
    // Add to photo collection
    if(subject != "") {
        // If we have too many entries, remove oldest
        if(llGetListLength(photoCollection) >= 18) { // Max 6 entries (6x3=18)
            photoCollection = llDeleteSubList(photoCollection, 0, 2);
        }
        
        photoCollection += [subject, quality, notes];
    }
    
    playerCharm = (string)((integer)playerCharm + 1);
    reduceStress(8);
    updateHUDDisplay();
}

// Perform mimicry
performMimicry(string person) {
    string accuracy = "Good";
    integer skill = (integer)((llFrand(1.0) * 60.0) + (llFrand(1.0) * (float)playerCharm));
    
    if(skill > 130) accuracy = "Perfect";
    else if(skill > 110) accuracy = "Excellent";
    else if(skill > 90) accuracy = "Very Good";
    else accuracy = "Good";
    
    string reaction = "Amused";
    
    // Different targets, different reactions
    if(person == "Tutor Gibbes") {
        if(accuracy == "Perfect" || accuracy == "Excellent") reaction = "Secretly Impressed";
        else reaction = "Pretends Disapproval";
        
        llSay(0, playerFullTitle + " performs a " + accuracy + " mimicry of Mr. Gibbes, the English tutor, to everyone's amusement.");
    }
    else if(person == "Court Officials") {
        if(accuracy == "Perfect" || accuracy == "Excellent") reaction = "Would Be Scandalized";
        else reaction = "Fortunately Absent";
        
        llSay(0, playerFullTitle + " entertains her siblings with a " + accuracy + " impression of stuffed-up court officials.");
    }
    else if(person == "Family Members") {
        if(accuracy == "Perfect" || accuracy == "Excellent") reaction = "Good-Naturedly Embarassed";
        else reaction = "Tolerant";
        
        llSay(0, playerFullTitle + " performs " + accuracy + " impressions of various family members, capturing their mannerisms perfectly.");
    }
    else if(person == "Rasputin") {
        if(accuracy == "Perfect" || accuracy == "Excellent") reaction = "Scandalized Whispers";
        else reaction = "Nervous Laughter";
        
        llSay(0, playerFullTitle + " does a " + accuracy + " but dangerously irreverent impression of Father Grigori Rasputin.");
    }
    
    // Add to mimicry targets
    if(person != "") {
        // If we have too many entries, remove oldest
        if(llGetListLength(mimicryTargets) >= 18) { // Max 6 entries (6x3=18)
            mimicryTargets = llDeleteSubList(mimicryTargets, 0, 2);
        }
        
        mimicryTargets += [person, accuracy, reaction];
    }
    
    playerCharm = (string)((integer)playerCharm + 3);
    reduceStress(15);
    updateHUDDisplay();
}

// Engage in recreation
recreationalActivity(string activity) {
    if(activity == "Tree Climbing") {
        llSay(0, playerFullTitle + " expertly climbs trees in the palace garden, much to the horror of court officials.");
        reduceStress(15);
    }
    else if(activity == "Play with Brother") {
        llSay(0, playerFullTitle + " entertains Tsarevich Alexei with games and stories, being careful of his condition.");
        reduceStress(12);
        playerCharm = (string)((integer)playerCharm + 2);
    }
    else if(activity == "Tease Guards") {
        llSay(0, playerFullTitle + " playfully teases the stoic palace guards, trying to make them break their composure.");
        
        // 50% chance of success
        if(llFrand(1.0) > 0.5) {
            llSay(0, "She succeeds in making one guard smile briefly!");
            reduceStress(10);
            playerCharm = (string)((integer)playerCharm + 2);
        }
        else {
            llSay(0, "The guards maintain their professional composure despite her efforts.");
            reduceStress(5);
        }
    }
    else if(activity == "Hide from Tutors") {
        llSay(0, playerFullTitle + " cleverly finds hiding spots to temporarily avoid her lessons.");
        
        // 70% chance of success
        if(llFrand(1.0) > 0.3) {
            llSay(0, "She successfully extends her free time by half an hour!");
            reduceStress(12);
            playerCharm = (string)((integer)playerCharm + 1);
        }
        else {
            llSay(0, "Her tutors quickly locate her hiding spot, resulting in extra homework.");
            addStress(5);
        }
    }
    
    updateHUDDisplay();
}

// Spend time with family
familyTime(string member) {
    if(member == "Father") {
        llSay(0, playerFullTitle + " entertains her father, Tsar Nicholas II, with stories and impressions, making him laugh.");
        playerInfluence = (string)((integer)playerInfluence + 1);
        reduceStress(12);
    }
    else if(member == "Mother") {
        llSay(0, playerFullTitle + " behaves (mostly) properly with her mother, Empress Alexandra Feodorovna.");
        playerInfluence = (string)((integer)playerInfluence + 1);
        reduceStress(5);
    }
    else if(member == "Alexei") {
        llSay(0, playerFullTitle + " plays games with her beloved brother Tsarevich Alexei, bringing him joy and laughter.");
        playerCharm = (string)((integer)playerCharm + 2);
        reduceStress(15);
    }
    else if(member == "Sisters") {
        llDialog(llGetOwner(), "Choose which sister to interact with:", 
            ["Olga", "Tatiana", "Maria", "All Sisters", "Back"], ANASTASIA_CHANNEL);
        return;
    }
    
    updateHUDDisplay();
}

// Sister interaction
sisterInteraction(string sister) {
    if(sister == "Olga") {
        llSay(0, playerFullTitle + " teases her eldest sister Olga, testing her patience but ultimately making her smile.");
        reduceStress(8);
        playerCharm = (string)((integer)playerCharm + 1);
    }
    else if(sister == "Tatiana") {
        llSay(0, playerFullTitle + " disrupts her sister Tatiana's perfectly organized schedule with playful distractions.");
        reduceStress(10);
        playerCharm = (string)((integer)playerCharm + 1);
    }
    else if(sister == "Maria") {
        llSay(0, playerFullTitle + " and Grand Duchess Maria Nikolaevna (The Little Pair) share secret jokes and adventures together.");
        reduceStress(15);
        playerCharm = (string)((integer)playerCharm + 2);
    }
    else if(sister == "All Sisters") {
        llSay(0, playerFullTitle + " entertains all her sisters with impressions and stories, bringing laughter to the group.");
        reduceStress(12);
    }
    
    updateHUDDisplay();
}

// Add stress from duties
addStress(integer amount) {
    playerStress += amount;
    
    if(playerStress > 100) playerStress = 100;
    
    // High stress affects health
    if(playerStress > 80) {
        playerHealth = "Poor";
        llOwnerSay("Your pranks have backfired and caused you stress. Consider taking time for fun recreation.");
    }
    else if(playerStress > 60) {
        playerHealth = "Fair";
    }
    else if(playerStress > 40) {
        playerHealth = "Good";
    }
    else {
        playerHealth = "Excellent";
    }
    
    updateHUDDisplay();
}

// Reduce stress through activities
reduceStress(integer amount) {
    playerStress -= amount;
    
    if(playerStress < 0) playerStress = 0;
    
    // Update health based on stress level
    if(playerStress < 20) {
        playerHealth = "Excellent";
    }
    else if(playerStress < 40) {
        playerHealth = "Good";
    }
    else if(playerStress < 60) {
        playerHealth = "Fair";
    }
    else {
        playerHealth = "Poor";
    }
    
    updateHUDDisplay();
}

// Display main menu
displayMainMenu(key id) {
    llDialog(id, "Imperial Anastasia HUD\n" + playerFullTitle + "\n\nSelect a function:",
        ["Family", "Pranks", "Photography", "Mimicry", "Recreation", "OOC Mode"], ANASTASIA_CHANNEL);
}

// Toggle OOC mode
toggleOOCMode() {
    isOOCMode = !isOOCMode;
    
    if(isOOCMode) {
        llOwnerSay("You have entered OOC mode. Your imperial status is hidden.");
    }
    else {
        llOwnerSay("You have returned to IC mode. Your imperial status is visible.");
    }
    
    updateHUDDisplay();
}

default {
    state_entry() {
        llListen(ANASTASIA_CHANNEL, "", NULL_KEY, "");
        
        // Initialize display
        updateHUDDisplay();
        
        llOwnerSay("Imperial Anastasia HUD initialized. Touch to access functions for Grand Duchess Anastasia Nikolaevna Romanov.");
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        
        // Only respond to owner's touch
        if(toucherId == llGetOwner()) {
            displayMainMenu(toucherId);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Only process owner's commands
        if(id != llGetOwner()) return;
        
        if(channel == ANASTASIA_CHANNEL) {
            // Main menu options
            if(message == "Family") {
                string report = generateFamilyReport();
                llDialog(id, report, ["Father", "Mother", "Alexei", "Sisters", "Back"], ANASTASIA_CHANNEL);
            }
            else if(message == "Pranks") {
                string report = generatePrankReport();
                llDialog(id, report, ["Prank Tutors", "Prank Sisters", "Prank Staff", "Prank Guards", "Back"], ANASTASIA_CHANNEL);
            }
            else if(message == "Photography") {
                string report = generatePhotographyReport();
                llDialog(id, report, ["Photo Family", "Photo Alexei", "Photo Palace", "Silly Self-Portrait", "Back"], ANASTASIA_CHANNEL);
            }
            else if(message == "Mimicry") {
                string report = generateMimicryReport();
                llDialog(id, report, ["Mimic Tutor", "Mimic Officials", "Mimic Family", "Mimic Rasputin", "Back"], ANASTASIA_CHANNEL);
            }
            else if(message == "Recreation") {
                string report = generateRecreationReport();
                llDialog(id, report, ["Tree Climbing", "Play with Brother", "Tease Guards", "Hide from Tutors", "Back"], ANASTASIA_CHANNEL);
            }
            else if(message == "OOC Mode") {
                toggleOOCMode();
                displayMainMenu(id);
            }
            else if(message == "Back") {
                displayMainMenu(id);
            }
            // Family interactions
            else if(message == "Father" || message == "Mother" || message == "Alexei" || message == "Sisters") {
                familyTime(message);
            }
            // Sister interactions
            else if(message == "Olga" || message == "Tatiana" || message == "Maria" || message == "All Sisters") {
                sisterInteraction(message);
            }
            // Prank options
            else if(message == "Prank Tutors") {
                executePrank("Tutors");
            }
            else if(message == "Prank Sisters") {
                executePrank("Sisters");
            }
            else if(message == "Prank Staff") {
                executePrank("Palace Staff");
            }
            else if(message == "Prank Guards") {
                executePrank("Guards");
            }
            // Photography options
            else if(message == "Photo Family") {
                takePhotograph("Family");
            }
            else if(message == "Photo Alexei") {
                takePhotograph("Alexei");
            }
            else if(message == "Photo Palace") {
                takePhotograph("Palace");
            }
            else if(message == "Silly Self-Portrait") {
                takePhotograph("Silly Self-Portrait");
            }
            // Mimicry options
            else if(message == "Mimic Tutor") {
                performMimicry("Tutor Gibbes");
            }
            else if(message == "Mimic Officials") {
                performMimicry("Court Officials");
            }
            else if(message == "Mimic Family") {
                performMimicry("Family Members");
            }
            else if(message == "Mimic Rasputin") {
                performMimicry("Rasputin");
            }
            // Recreation options
            else if(message == "Tree Climbing") {
                recreationalActivity("Tree Climbing");
            }
            else if(message == "Play with Brother") {
                recreationalActivity("Play with Brother");
            }
            else if(message == "Tease Guards") {
                recreationalActivity("Tease Guards");
            }
            else if(message == "Hide from Tutors") {
                recreationalActivity("Hide from Tutors");
            }
        }
    }
    
    link_message(integer sender, integer num, string str, key id) {
        if(num == HUD_LINK_MESSAGE_CHANNEL) {
            // Process HUD communications
            list params = llParseString2List(str, ["="], []);
            if(llGetListLength(params) == 2) {
                string cmd = llList2String(params, 0);
                string value = llList2String(params, 1);
                
                // Update relevant cached values
                if(cmd == "HEALTH") {
                    playerHealth = value;
                    updateHUDDisplay();
                }
                else if(cmd == "FAITH") {
                    playerFaith = value;
                    updateHUDDisplay();
                }
                else if(cmd == "INFLUENCE") {
                    playerInfluence = value;
                    updateHUDDisplay();
                }
                else if(cmd == "CHARM") {
                    playerCharm = value;
                    updateHUDDisplay();
                }
                else if(cmd == "RUBLES") {
                    playerRubles = (integer)value;
                    updateHUDDisplay();
                }
            }
        }
    }
}