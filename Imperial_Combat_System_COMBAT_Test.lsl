// Imperial Combat System - COMBAT Variable Test
// Testing if the COMBAT variable name specifically is the issue

integer COMBAT; // Using the variable name that seems to cause problems

default {
    state_entry() {
        // Initialize the variable
        COMBAT = 1;
        
        // Debug message
        llOwnerSay("COMBAT = " + (string)COMBAT);
    }
}