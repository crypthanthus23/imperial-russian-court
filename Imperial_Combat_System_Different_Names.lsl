// Imperial Combat System - Different Variable Names
// Using different names to avoid potential reserved word conflicts

// Dialog channels
integer WEAPON_CHANNEL;
integer ATTACK_CHANNEL;
integer TARGET_CHANNEL;

// State tracking
integer isPowerOn = FALSE;
integer isWeaponReady = TRUE;
integer targetSelected = FALSE;

// User info
key ownerKey;
key targetKey;
string ownerName;
string targetName;

// Initialize all variables and settings
initialize() {
    // Set up random dialog channels
    WEAPON_CHANNEL = -1000000 - (integer)llFrand(1000000);
    ATTACK_CHANNEL = -1000000 - (integer)llFrand(1000000);
    TARGET_CHANNEL = -1000000 - (integer)llFrand(1000000);
    
    // Get owner info
    ownerKey = llGetOwner();
    ownerName = llKey2Name(ownerKey);
    
    // Reset all states
    isPowerOn = TRUE;
    isWeaponReady = TRUE;
    targetSelected = FALSE;
    targetKey = NULL_KEY;
    targetName = "";
    
    // Set up object appearance
    llSetObjectName("Imperial Dueling Pistol");
    llSetText("Ready for combat", <1.0, 0.0, 0.0>, 1.0);
}

default {
    state_entry() {
        initialize();
        llOwnerSay("Imperial Combat System initialized");
    }
    
    touch_start(integer num_detected) {
        key toucher = llDetectedKey(0);
        
        // Only owner can use weapon
        if (toucher == ownerKey) {
            llListenRemove(WEAPON_CHANNEL);
            llDialog(toucher, "Select Weapon Action", ["Attack", "Examine", "Cancel"], WEAPON_CHANNEL);
            llListen(WEAPON_CHANNEL, "", toucher, "");
        }
        else {
            llSay(0, llDetectedName(0) + " tries to use " + ownerName + "'s weapon, but fails.");
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == WEAPON_CHANNEL) {
            if (message == "Attack") {
                // Start sensor to find targets
                llSensor("", "", AGENT, 20.0, PI);
            }
            else if (message == "Examine") {
                llOwnerSay("This is an Imperial Dueling Pistol used by nobility for settling disputes.");
            }
        }
        else if (channel == TARGET_CHANNEL) {
            // Process target selection
            integer index = (integer)message;
            if (index >= 0) {
                targetKey = llDetectedKey(index);
                targetName = llDetectedName(index);
                llOwnerSay("Selected target: " + targetName);
                attackTarget();
            }
        }
    }
    
    sensor(integer num_detected) {
        // Show target selection dialog
        if (num_detected > 0) {
            list targets = [];
            list buttons = [];
            
            integer i;
            for (i = 0; i < num_detected && i < 9; i++) {
                targets += [llDetectedName(i)];
                buttons += [(string)i];
            }
            
            string targetList = "Select target:\n";
            for (i = 0; i < llGetListLength(targets); i++) {
                targetList += "\n" + (string)i + ": " + llList2String(targets, i);
            }
            
            llListenRemove(TARGET_CHANNEL);
            llDialog(ownerKey, targetList, buttons, TARGET_CHANNEL);
            llListen(TARGET_CHANNEL, "", ownerKey, "");
        }
    }
    
    no_sensor(integer not_used) {
        llOwnerSay("No targets detected within range.");
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}

// Attack the selected target
attackTarget() {
    if (targetKey != NULL_KEY) {
        llSay(0, ownerName + " fires at " + targetName + " with the Imperial Dueling Pistol!");
        
        // This would normally send damage to the target's HUD via a link message
        llOwnerSay("Attack complete. Weapon ready for next use.");
        
        // Reset target
        targetKey = NULL_KEY;
        targetName = "";
    }
}