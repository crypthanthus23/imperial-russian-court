// Imperial Russian Court Combat System - Minimal Version
// Basic combat parameters
string weaponName = "Dueling Pistol";
integer baseDamage = 20;
float accuracy = 0.7;
integer cooldownSeconds = 30;
integer lethalMode = FALSE;
float maxRange = 10.0;

// Dialog channels - will be initialized at runtime
integer COMBAT_CHANNEL;
integer CONFIRM_CHANNEL;
integer TARGET_CHANNEL;

// Stats channel
integer METER_STATS_CHANNEL = -987654321;

// Combat state variables
list cooldowns = [];
string currentAction = "";

// Initialize the weapon
initialize() {
    // Set object name
    if (llGetObjectName() == "Object") {
        llSetObjectName(weaponName);
    }
    
    // Set up random channels for dialog menus
    COMBAT_CHANNEL = -6000000 - (integer)llFrand(999999);
    CONFIRM_CHANNEL = COMBAT_CHANNEL - 1;
    TARGET_CHANNEL = COMBAT_CHANNEL - 2;
    
    // Set up listeners
    llListen(COMBAT_CHANNEL, "", NULL_KEY, "");
    llListen(CONFIRM_CHANNEL, "", NULL_KEY, "");
    llListen(TARGET_CHANNEL, "", NULL_KEY, "");
    
    // Set up hover text
    llSetText(weaponName + "\nDamage: " + (string)baseDamage, <0.8, 0.2, 0.2>, 1.0);
}

// Show weapon menu to user
showWeaponMenu(key userID) {
    string menuText = "\n=== " + weaponName + " ===\n\n";
    menuText += "Damage: " + (string)baseDamage + "\n";
    menuText += "What would you like to do?";
    
    list buttons = ["Attack", "Examine", "Cancel"];
    
    llDialog(userID, menuText, buttons, COMBAT_CHANNEL);
}

// Show target selection menu
showTargetMenu(key userID) {
    // Scan for potential targets
    llSensor("", "", AGENT, maxRange, PI);
    
    // Store the action for when sensor returns
    currentAction = "attack";
}

// Process attack
processAttack(key attackerID, key targetID) {
    // Calculate hit success based on accuracy
    integer hitSuccess = (llFrand(1.0) <= accuracy);
    
    if (hitSuccess) {
        // Calculate damage
        integer damage = baseDamage;
        
        // Send damage command to target's HUD
        llRegionSayTo(targetID, METER_STATS_CHANNEL, "TAKE_DAMAGE|" + (string)damage + "|" + 
            llKey2Name(attackerID) + "|physical");
        
        // Notify attacker
        llRegionSayTo(attackerID, 0, "You successfully hit " + llKey2Name(targetID) + 
            " with your " + weaponName + " for " + (string)damage + " damage!");
        
        // Notify target
        llRegionSayTo(targetID, 0, "You have been hit by " + llKey2Name(attackerID) + 
            "'s " + weaponName + " for " + (string)damage + " damage!");
    } else {
        // Attack missed
        llRegionSayTo(attackerID, 0, "Your attack with the " + weaponName + " missed " + 
            llKey2Name(targetID) + "!");
        
        // Notify target
        llRegionSayTo(targetID, 0, llKey2Name(attackerID) + " tried to attack you with a " + 
            weaponName + " but missed!");
    }
    
    // Apply cooldown
    integer index = llListFindList(cooldowns, [attackerID]);
    
    if (index != -1) {
        // Update cooldown
        cooldowns = llListReplaceList(cooldowns, [attackerID, llGetUnixTime()], index, index + 1);
    } else {
        // Add new cooldown
        cooldowns += [attackerID, llGetUnixTime()];
    }
}

default {
    state_entry() {
        initialize();
    }
    
    on_rez(integer start_param) {
        initialize();
    }
    
    touch_start(integer num_detected) {
        key toucher = llDetectedKey(0);
        
        // Show weapon menu
        showWeaponMenu(toucher);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == COMBAT_CHANNEL) {
            if (message == "Cancel") {
                return;
            }
            else if (message == "Attack") {
                // Show target selection menu
                showTargetMenu(id);
            }
            else if (message == "Examine") {
                // Provide detailed description
                string examineText = "You examine the " + weaponName + " closely.\n\n";
                examineText += "This is a physical weapon that deals " + (string)baseDamage + " damage.";
                llRegionSayTo(id, 0, examineText);
            }
        }
        // Handle target selection for attacks
        else if (channel == TARGET_CHANNEL) {
            list parts = llParseString2List(message, ["|"], []);
            
            if (llGetListLength(parts) >= 2) {
                string targetName = llList2String(parts, 0);
                key targetID = (key)llList2String(parts, 1);
                
                // Process attack
                processAttack(id, targetID);
            }
        }
    }
    
    sensor(integer num_detected) {
        // Create a list of nearby targets
        list buttons = [];
        list targets = [];
        
        // Get the owner key - we should exclude the owner from targets
        key owner = llGetOwner();
        
        integer i;
        for (i = 0; i < num_detected && i < 9; i++) {
            string targetName = llDetectedName(i);
            key targetID = llDetectedKey(i);
            
            // Skip the owner who initiated the action
            if (targetID != owner) {
                targets += [targetName + "|" + (string)targetID];
                buttons += [targetName];
            }
        }
        
        buttons += ["Cancel"];
        
        // Show target selection dialog
        string menuText = "\n=== Select Target ===\n\n";
        menuText += "Select a target to attack:";
        
        llDialog(owner, menuText, buttons, TARGET_CHANNEL);
    }
    
    no_sensor(integer not_used) {
        // No targets found
        llSay(0, "No valid targets found within range.");
    }
}