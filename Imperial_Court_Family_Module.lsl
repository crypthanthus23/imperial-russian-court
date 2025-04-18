// Imperial Russian Court HUD - Family Module
// Handles family lineage, dynasty functions, and heir management
// This module communicates with the main HUD

// ============= CONSTANTS =============
// Communication Channels
integer MAIN_HUD_CHANNEL = -9876543; // Channel to communicate with main HUD
integer FAMILY_CHANNEL = -98015;      // Channel for family lineage menus
integer FAMILY_DATABASE_CHANNEL = -987654322; // Channel for family database communications

// ============= VARIABLES =============
// Basic Character Data
key ownerID;
string firstName = "";
string familyName = "";
integer playerClass = -1; 
integer rank = 0;

// Family System
string dynastyName = ""; // Family dynasty name
key familyHeadID = NULL_KEY; // UUID of family head
string familyHeadName = ""; // Name of family head
list familyMembers = []; // List of family member UUIDs
list familyNames = []; // List of family member names
list familyRelations = []; // List of relations to head
integer familyRank = -1; // Rank within family
integer foundedFamily = FALSE; // Whether player founded a family
integer isHeir = FALSE; // Whether player is the heir

// System Variables
list activeListeners = []; // Track active listeners
string currentState = "INIT"; // Track current menu/state

// ============= FUNCTIONS =============
// Function to show family menu
showFamilyMenu() {
    string menuText = "\n=== FAMILY & DYNASTY ===\n\n";
    
    if (foundedFamily) {
        menuText += "You are the head of the " + dynastyName + " dynasty.\n";
        menuText += "Members: " + (string)llGetListLength(familyMembers) + "\n\n";
        menuText += "What would you like to do?";
        
        list buttons = ["View Members", "Appoint Heir", "Remove Member", "Family Fortune", "Back"];
        
        llDialog(ownerID, menuText, buttons, FAMILY_CHANNEL);
    } 
    else if (familyHeadID != NULL_KEY) {
        menuText += "You are a member of the " + dynastyName + " dynasty.\n";
        menuText += "Head: " + familyHeadName + "\n";
        if (isHeir) {
            menuText += "Status: Heir to the dynasty\n";
        }
        menuText += "\nWhat would you like to do?";
        
        list buttons = ["View Members", "Leave Family", "Family History", "Back"];
        
        llDialog(ownerID, menuText, buttons, FAMILY_CHANNEL);
    } 
    else {
        menuText += "You are not part of any dynasty.\n\n";
        menuText += "Would you like to:";
        
        list buttons = ["Found Dynasty", "Join Dynasty", "Back"];
        
        llDialog(ownerID, menuText, buttons, FAMILY_CHANNEL);
    }
    
    currentState = "FAMILY_MENU";
}

// Function to handle family founding
foundDynasty(string name) {
    if (name == "") {
        llTextBox(ownerID, "Enter the name of your dynasty:", FAMILY_CHANNEL);
        return;
    }
    
    dynastyName = name;
    foundedFamily = TRUE;
    familyHeadID = ownerID;
    familyHeadName = firstName + " " + familyName;
    
    // Add self to family members
    familyMembers = [(string)ownerID];
    familyNames = [firstName + " " + familyName];
    familyRelations = ["Head"];
    
    llOwnerSay("You have founded the " + dynastyName + " dynasty.");
    
    // Send complete update to main HUD
    // Format: FAMILY_UPDATE|dynastyName|foundedFamily|familyHeadID|familyHeadName|isHeir|memberList
    
    // Create member list string (format: "ID:Name:Relation;ID:Name:Relation")
    string memberString = "";
    integer i;
    for (i = 0; i < llGetListLength(familyMembers); i++) {
        if (i > 0) memberString += ";";
        memberString += llList2String(familyMembers, i) + ":" + 
                       llList2String(familyNames, i) + ":" + 
                       llList2String(familyRelations, i);
    }
    
    llMessageLinked(LINK_SET, 0, "FAMILY_UPDATE|" + dynastyName + "|" + 
                   (string)foundedFamily + "|" + (string)familyHeadID + "|" + 
                   familyHeadName + "|" + (string)isHeir + "|" + memberString, NULL_KEY);
    
    showFamilyMenu();
}

// Function to handle heir appointment
appointHeir() {
    if (!foundedFamily) {
        llOwnerSay("Only the head of a dynasty can appoint an heir.");
        showFamilyMenu();
        return;
    }
    
    string menuText = "\n=== APPOINT HEIR ===\n\n";
    menuText += "Select a family member to appoint as your heir:";
    
    list buttons = [];
    integer i;
    for (i = 0; i < llGetListLength(familyMembers); i++) {
        if (llList2String(familyMembers, i) != (string)ownerID) {
            buttons += [llList2String(familyNames, i)];
        }
    }
    
    if (llGetListLength(buttons) == 0) {
        llOwnerSay("You have no family members who can be appointed heir.");
        showFamilyMenu();
        return;
    }
    
    buttons += ["Cancel"];
    
    llDialog(ownerID, menuText, buttons, FAMILY_CHANNEL);
    currentState = "APPOINT_HEIR";
}

// Process heir appointment
processHeirAppointment(string heirName) {
    integer index = llListFindList(familyNames, [heirName]);
    
    if (index != -1) {
        key heirID = (key)llList2String(familyMembers, index);
        
        // Send update to database (in a real implementation)
        llRegionSay(FAMILY_DATABASE_CHANNEL, "APPOINT_HEIR|" + (string)heirID + "|" + (string)ownerID + "|" + dynastyName);
        
        llOwnerSay("You have appointed " + heirName + " as the heir to the " + dynastyName + " dynasty.");
    }
    
    showFamilyMenu();
}

// Function to view family members
viewFamilyMembers() {
    string menuText = "\n=== FAMILY MEMBERS ===\n\n";
    menuText += "Dynasty: " + dynastyName + "\n";
    menuText += "Head: " + familyHeadName + "\n\n";
    menuText += "Members:\n";
    
    integer i;
    for (i = 0; i < llGetListLength(familyMembers); i++) {
        string memberName = llList2String(familyNames, i);
        string relation = llList2String(familyRelations, i);
        
        menuText += "- " + memberName + " (" + relation + ")\n";
    }
    
    list buttons = ["Back"];
    
    llDialog(ownerID, menuText, buttons, FAMILY_CHANNEL);
    currentState = "VIEW_MEMBERS";
}

// Initialize the module
initialize() {
    // Get owner key
    ownerID = llGetOwner();
    
    // Reset dialog listeners
    integer i;
    for (i = 0; i < llGetListLength(activeListeners); i++) {
        llListenRemove(llList2Integer(activeListeners, i));
    }
    activeListeners = [];
    
    // Set up listeners
    activeListeners += [llListen(FAMILY_CHANNEL, "", NULL_KEY, "")];
    
    // Request data from main HUD
    llMessageLinked(LINK_SET, 0, "REQUEST_FAMILY_DATA", NULL_KEY);
    
    llOwnerSay("Family Module initialized.");
}

default {
    state_entry() {
        initialize();
    }
    
    listen(integer channel, string name, key id, string message) {
        if (id != ownerID) return;
        
        if (channel == FAMILY_CHANNEL) {
            if (currentState == "FAMILY_MENU") {
                if (message == "View Members") {
                    viewFamilyMembers();
                }
                else if (message == "Appoint Heir") {
                    appointHeir();
                }
                else if (message == "Found Dynasty") {
                    llTextBox(ownerID, "Enter the name of your dynasty:", FAMILY_CHANNEL);
                    currentState = "FOUND_DYNASTY";
                }
                else if (message == "Back") {
                    // Tell main HUD to show main menu
                    llMessageLinked(LINK_SET, 0, "SHOW_MAIN_MENU", NULL_KEY);
                }
            }
            else if (currentState == "FOUND_DYNASTY") {
                foundDynasty(message);
            }
            else if (currentState == "APPOINT_HEIR") {
                if (message != "Cancel") {
                    processHeirAppointment(message);
                } else {
                    showFamilyMenu();
                }
            }
            else if (currentState == "VIEW_MEMBERS") {
                if (message == "Back") {
                    showFamilyMenu();
                }
            }
        }
    }
    
    touch_start(integer total_number) {
        if (llDetectedKey(0) == llGetOwner()) {
            // Request updated data before showing the menu
            llMessageLinked(LINK_SET, 0, "REQUEST_FAMILY_DATA", NULL_KEY);
            llSleep(0.2); // Short delay to allow time for data to be received
            showFamilyMenu();
        }
    }
    
    link_message(integer sender_num, integer num, string message, key id) {
        list msgParts = llParseString2List(message, ["|"], []);
        string command = llList2String(msgParts, 0);
        
        if (command == "FAMILY_DATA") {
            // Receiving family data from main HUD
            if (llGetListLength(msgParts) >= 6) {
                firstName = llList2String(msgParts, 1);
                familyName = llList2String(msgParts, 2);
                dynastyName = llList2String(msgParts, 3);
                foundedFamily = (integer)llList2String(msgParts, 4);
                familyHeadID = (key)llList2String(msgParts, 5);
                familyHeadName = llList2String(msgParts, 6);
                isHeir = (integer)llList2String(msgParts, 7);
                
                // Process family members if present
                if (llGetListLength(msgParts) >= 9) {
                    string memberString = llList2String(msgParts, 8);
                    list memberPairs = llParseString2List(memberString, [";"], []);
                    
                    familyMembers = [];
                    familyNames = [];
                    familyRelations = [];
                    
                    integer i;
                    for (i = 0; i < llGetListLength(memberPairs); i++) {
                        list memberInfo = llParseString2List(llList2String(memberPairs, i), [":"], []);
                        if (llGetListLength(memberInfo) >= 3) {
                            familyMembers += [llList2String(memberInfo, 0)];
                            familyNames += [llList2String(memberInfo, 1)];
                            familyRelations += [llList2String(memberInfo, 2)];
                        }
                    }
                }
            }
        }
        else if (command == "SHOW_FAMILY_MENU") {
            showFamilyMenu();
        }
    }
}