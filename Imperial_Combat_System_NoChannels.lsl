// Imperial Combat System - No Channels Version
// A minimal weapon script with no dialog channels

default {
    state_entry() {
        // Set up the object
        llSetObjectName("Dueling Pistol");
        llSetText("Touch to use", <1.0, 0.0, 0.0>, 1.0);
        
        // Debug message
        llOwnerSay("Combat system initialized");
    }
    
    touch_start(integer num_detected) {
        // Get info about who touched
        key toucher = llDetectedKey(0);
        string toucherName = llDetectedName(0);
        
        // Send messages
        llOwnerSay("WEAPON USED by: " + toucherName);
        llSay(0, toucherName + " attacks with the Dueling Pistol for 20 damage!");
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}