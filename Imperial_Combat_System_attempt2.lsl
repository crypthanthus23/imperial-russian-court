string weaponName = "Dueling Pistol";
integer baseDamage = 20;
float accuracy = 0.7;
integer cooldownSeconds = 30;
integer lethalMode = FALSE;
float maxRange = 10.0;
integer COMBAT_CHANNEL;
integer CONFIRM_CHANNEL;
integer TARGET_CHANNEL;
integer METER_STATS_CHANNEL = -987654321;
list cooldowns = [];
string currentAction = "";

initialize() {
    if (llGetObjectName() == "Object") {
        llSetObjectName(weaponName);
    }
    
    COMBAT_CHANNEL = -6000000 - (integer)llFrand(999999);
    CONFIRM_CHANNEL = COMBAT_CHANNEL - 1;
    TARGET_CHANNEL = COMBAT_CHANNEL - 2;
    
    llListen(COMBAT_CHANNEL, "", NULL_KEY, "");
    llListen(CONFIRM_CHANNEL, "", NULL_KEY, "");
    llListen(TARGET_CHANNEL, "", NULL_KEY, "");
    
    llSetText(weaponName + "\nDamage: " + (string)baseDamage, <0.8, 0.2, 0.2>, 1.0);
}

default {
    state_entry() {
        initialize();
    }
    
    touch_start(integer num_detected) {
        key toucher = llDetectedKey(0);
        llSay(0, "Weapon touched by " + llKey2Name(toucher));
    }
}