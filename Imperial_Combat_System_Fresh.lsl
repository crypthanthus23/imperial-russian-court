// Imperial Combat System
// A simple touch-based weapon script

default {
    state_entry() {
        // Set up the object
        llSetObjectName("Dueling Pistol");
        llSetText("Touch to use", <1.0, 0.0, 0.0>, 1.0);
        
        // Set up listener for combat
        llListen(-98765, "", NULL_KEY, "");
        
        // Debug message
        llOwnerSay("Combat system initialized");
    }
    
    touch_start(integer num_detected) {
        // Get info about who touched
        key toucher = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Send messages
        llOwnerSay("WEAPON USED by: " + toucherName);
        llSay(0, toucherName + " prepares to use this weapon!");
        
        // Create a simple dialog
        llDialog(toucher, "Choose your action:", ["Attack", "Examine", "Cancel"], -98765);
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == -98765) {
            if (message == "Attack") {
                llSay(0, name + " attacks with the Dueling Pistol for 20 damage!");
            }
            else if (message == "Examine") {
                llSay(0, "This is a Dueling Pistol that does 20 damage.");
            }
            else if (message == "Cancel") {
                llSay(0, name + " lowers the weapon.");
            }
        }
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}