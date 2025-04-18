// Imperial Combat System - Variable Test
// Testing if the COMBAT variable name is the issue

integer MY_VAR; // Using a completely different variable name

default {
    state_entry() {
        // Initialize variables
        MY_VAR = (integer)llFrand(1000000);
        
        // Set up the object
        llSetObjectName("Test Object");
        llSetText("Touch me", <1.0, 0.0, 0.0>, 1.0);
        
        llOwnerSay("MY_VAR = " + (string)MY_VAR);
    }
    
    touch_start(integer num_detected) {
        // Simple touch response
        key toucher = llDetectedKey(0);
        llSay(0, "Touched by " + llDetectedName(0));
    }
}