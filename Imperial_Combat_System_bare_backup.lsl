// Imperial Russian Court Combat System - Bare Minimum
// This is a minimal test script

default {
    state_entry() {
        llSay(0, "Combat system initialized");
    }
    
    touch_start(integer num) {
        llSay(0, "Touched");
    }
}