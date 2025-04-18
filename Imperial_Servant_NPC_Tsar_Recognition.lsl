// Imperial Servant NPC with Tsar Recognition
// This script creates palace servants that recognize and properly attend to Tsar Nikolai II

// Constants for avatar recognition
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II's UUID
float DETECTION_RANGE = 15.0; // How far to detect avatars
float SERVICE_RANGE = 10.0; // How close to offer service

// Servant state variables
integer SERVANT_STATE_IDLE = 0;
integer SERVANT_STATE_TSAR_PRESENT = 1;
integer SERVANT_STATE_ATTENDING = 2;
integer SERVANT_STATE_SERVING = 3;
integer SERVANT_STATE_ANNOUNCING = 4;
integer currentState = SERVANT_STATE_IDLE;

// Tsar detection variables
integer tsarDetected = FALSE;
integer tsarAttended = FALSE;
float lastTsarAttendanceTime = 0.0;
float tsarAttendanceCooldown = 180.0; // 3 minutes between formal attendances

// Servant configuration
string servantType = "Footman"; // Could be Butler, Footman, Lady's Maid, etc.
string servantName = "Ivan";
list servantDuties = [
    "Serving refreshments",
    "Announcing visitors",
    "Attending to noble needs",
    "Maintaining palace order"
];

// Formal addresses
list tsarAddresses = [
    "Your Imperial Majesty", 
    "Sire", 
    "Your Majesty", 
    "my Tsar"
];

list nobleAddresses = [
    "Your Excellency",
    "Your Grace", 
    "my Lord/Lady", 
    "Your Highness"
];

// Service offerings for nobles
list nobleServices = [
    "Would you care for refreshments?",
    "May I attend to any of your needs?",
    "Would you like me to announce you to the court?",
    "May I take your coat/hat/gloves?"
];

// Special services for Tsar
list tsarServices = [
    "May I bring you anything, Your Imperial Majesty?",
    "The palace staff awaits your commands, Your Majesty.",
    "Shall I summon anyone for you, Your Imperial Majesty?",
    "Would Your Majesty care for refreshments?"
];

// Animation names
string BOW_ANIMATION = "bow";
string CURTSY_ANIMATION = "curtsy";
string SERVE_ANIMATION = "serve";
string IDLE_ANIMATION = "stand";

// Listener channels
// PUBLIC_CHANNEL is a built-in constant in LSL (channel 0)
integer servantChannel;

// Initialize the servant
default
{
    state_entry()
    {
        // Set up a random channel for servant communications
        servantChannel = ((integer)llFrand(1000000) + 10000) * -1;
        
        // Start listening for commands and nearby avatars
        llListen(PUBLIC_CHANNEL, "", NULL_KEY, "");
        
        // Set up sensor to detect avatars
        llSensorRepeat("", NULL_KEY, AGENT_BY_LEGACY_NAME, DETECTION_RANGE, PI, 2.0);
        
        // Start in idle servant state
        llSetText(servantType + "\n" + servantName, <0.8, 0.8, 0.8>, 1.0);
        
        // Play idle animation
        llStartAnimation(IDLE_ANIMATION);
        
        // Set timer for random servant behaviors
        llSetTimerEvent(45.0);
    }
    
    // Detect nearby avatars, especially the Tsar
    sensor(integer total_number)
    {
        tsarDetected = FALSE;
        
        // Check if Tsar is among detected avatars
        integer i;
        for(i = 0; i < total_number; i++)
        {
            key detectedKey = llDetectedKey(i);
            
            // If Tsar is detected
            if(detectedKey == TSAR_UUID)
            {
                tsarDetected = TRUE;
                
                // Calculate distance to Tsar
                vector tsarPos = llDetectedPos(i);
                float distance = llVecDist(llGetPos(), tsarPos);
                
                // If close enough for service and not recently attended
                float currentTime = llGetUnixTime();
                if(distance <= SERVICE_RANGE && !tsarAttended && (currentTime - lastTsarAttendanceTime > tsarAttendanceCooldown))
                {
                    // Attend to Tsar
                    currentState = SERVANT_STATE_ATTENDING;
                    tsarAttended = TRUE;
                    lastTsarAttendanceTime = currentTime;
                    
                    // Stop idle animation
                    llStopAnimation(IDLE_ANIMATION);
                    
                    // Bow or curtsy to Tsar (based on servant type)
                    if(servantType == "Footman" || servantType == "Butler")
                    {
                        llStartAnimation(BOW_ANIMATION);
                    }
                    else
                    {
                        llStartAnimation(CURTSY_ANIMATION);
                    }
                    
                    // Formal greeting
                    integer address_index = (integer)llFrand(llGetListLength(tsarAddresses));
                    string formalAddress = llList2String(tsarAddresses, address_index);
                    
                    llSay(PUBLIC_CHANNEL, formalAddress + ", how may I serve you today?");
                    
                    // Offer service after a short delay
                    llSetTimerEvent(3.0);
                }
                else if(distance <= SERVICE_RANGE && currentState != SERVANT_STATE_ATTENDING && currentState != SERVANT_STATE_SERVING)
                {
                    // Acknowledge Tsar's presence without full formal attendance
                    currentState = SERVANT_STATE_TSAR_PRESENT;
                    
                    // Brief bow of head
                    llStopAnimation(IDLE_ANIMATION);
                    llStartAnimation(BOW_ANIMATION);
                    llSetTimerEvent(2.0);
                }
            }
            // Recognition of other nobles/players
            else
            {
                // Skip if currently attending to Tsar or already serving
                if(currentState == SERVANT_STATE_ATTENDING || currentState == SERVANT_STATE_SERVING)
                {
                    continue;
                }
                
                // Calculate distance to player
                vector playerPos = llDetectedPos(i);
                float distance = llVecDist(llGetPos(), playerPos);
                
                // If close enough and random chance (don't want to be too pushy)
                if(distance <= SERVICE_RANGE && llFrand(1.0) < 0.3 && currentState == SERVANT_STATE_IDLE)
                {
                    // Determine player's rank (this would integrate with HUD system)
                    // For demonstration, we'll assume all players are nobles
                    integer noble_address_index = (integer)llFrand(llGetListLength(nobleAddresses));
                    string playerRankAddress = llList2String(nobleAddresses, noble_address_index);
                    
                    // Offer service
                    integer service_index = (integer)llFrand(llGetListLength(nobleServices));
                    string serviceOffer = llList2String(nobleServices, service_index);
                    
                    llSay(PUBLIC_CHANNEL, playerRankAddress + ", " + serviceOffer);
                    
                    // Brief bow
                    llStopAnimation(IDLE_ANIMATION);
                    llStartAnimation(BOW_ANIMATION);
                    
                    currentState = SERVANT_STATE_ATTENDING;
                    llSetTimerEvent(5.0);
                }
            }
        }
        
        // Update state if Tsar is no longer present
        if(!tsarDetected && (currentState == SERVANT_STATE_TSAR_PRESENT || currentState == SERVANT_STATE_ATTENDING) && !llTimerIsRunning())
        {
            currentState = SERVANT_STATE_IDLE;
            llStopAnimation(BOW_ANIMATION);
            llStopAnimation(CURTSY_ANIMATION);
            llStartAnimation(IDLE_ANIMATION);
            llSetTimerEvent(45.0);
        }
    }
    
    // Handle no avatars detected
    no_sensor(integer not_used) {
        tsarDetected = FALSE;
        
        // Return to idle state if not serving
        if(currentState != SERVANT_STATE_SERVING && currentState != SERVANT_STATE_IDLE)
        {
            currentState = SERVANT_STATE_IDLE;
            llStopAnimation(BOW_ANIMATION);
            llStopAnimation(CURTSY_ANIMATION);
            llStartAnimation(IDLE_ANIMATION);
            llSetTimerEvent(45.0);
        }
    }
    
    // Listen for commands from Tsar or other players
    listen(integer channel, string name, key id, string message)
    {
        // Special responses to Tsar's commands
        if(id == TSAR_UUID)
        {
            // Attend to Tsar's requests
            currentState = SERVANT_STATE_SERVING;
            
            // Stop other animations
            llStopAnimation(IDLE_ANIMATION);
            llStopAnimation(BOW_ANIMATION);
            llStopAnimation(CURTSY_ANIMATION);
            
            // Begin serve animation
            llStartAnimation(SERVE_ANIMATION);
            
            // Immediate acknowledgment
            integer address_index = (integer)llFrand(llGetListLength(tsarAddresses));
            string formalAddress = llList2String(tsarAddresses, address_index);
            llSay(PUBLIC_CHANNEL, "At once, " + formalAddress + ".");
            
            // Check for specific service requests
            if(llSubStringIndex(llToLower(message), "tea") != -1)
            {
                llSay(PUBLIC_CHANNEL, "*" + servantName + " bows deeply* I shall bring your tea immediately, Your Imperial Majesty.");
                // Here we would implement a tea service routine
                llSetTimerEvent(10.0); // Simulate time to prepare tea
            }
            else if(llSubStringIndex(llToLower(message), "announce") != -1)
            {
                llSay(PUBLIC_CHANNEL, "Whom shall I announce, Your Imperial Majesty?");
                currentState = SERVANT_STATE_ANNOUNCING;
                // Next message will be interpreted as name to announce
            }
            else if(llSubStringIndex(llToLower(message), "dismiss") != -1)
            {
                llSay(PUBLIC_CHANNEL, "*" + servantName + " bows deeply* As you wish, Your Imperial Majesty.");
                currentState = SERVANT_STATE_IDLE;
                llStopAnimation(SERVE_ANIMATION);
                llStartAnimation(IDLE_ANIMATION);
                llSetTimerEvent(45.0);
            }
            else
            {
                // General service
                llSay(PUBLIC_CHANNEL, "I shall see to it immediately, Your Imperial Majesty.");
                llSetTimerEvent(8.0); // Return to normal after brief service
            }
        }
        // Handle state-specific responses for announcing
        else if(currentState == SERVANT_STATE_ANNOUNCING && id == TSAR_UUID)
        {
            // Tsar has given name to announce
            llShout(PUBLIC_CHANNEL, "*" + servantName + " strikes the floor with his staff* Now entering the Imperial presence: " + message);
            llSetTimerEvent(5.0);
        }
        // Player with service request
        else if(llSubStringIndex(llToLower(message), "servant") != -1 || 
                llSubStringIndex(llToLower(message), servantType) != -1 ||
                llSubStringIndex(llToLower(message), llToLower(servantName)) != -1)
        {
            // Skip if attending to Tsar
            if(tsarDetected && (currentState == SERVANT_STATE_ATTENDING || currentState == SERVANT_STATE_SERVING))
            {
                llSay(PUBLIC_CHANNEL, "Forgive me, but I am currently attending to His Imperial Majesty.");
                return;
            }
            
            currentState = SERVANT_STATE_ATTENDING;
            
            // Determine player's rank (would integrate with HUD)
            integer noble_address_index = (integer)llFrand(llGetListLength(nobleAddresses));
            string playerRankAddress = llList2String(nobleAddresses, noble_address_index);
            
            llSay(PUBLIC_CHANNEL, "How may I be of service, " + playerRankAddress + "?");
            
            // Process specific service requests
            if(llSubStringIndex(llToLower(message), "tea") != -1 || 
               llSubStringIndex(llToLower(message), "drink") != -1 ||
               llSubStringIndex(llToLower(message), "refreshment") != -1)
            {
                currentState = SERVANT_STATE_SERVING;
                llStopAnimation(IDLE_ANIMATION);
                llStartAnimation(SERVE_ANIMATION);
                llSay(PUBLIC_CHANNEL, "*" + servantName + " bows* Right away, " + playerRankAddress + ". I shall bring refreshments.");
                llSetTimerEvent(10.0);
            }
            else if(llSubStringIndex(llToLower(message), "announce") != -1)
            {
                llSay(PUBLIC_CHANNEL, "Whom shall I announce, " + playerRankAddress + "?");
                currentState = SERVANT_STATE_ANNOUNCING;
                // Next message will be interpreted as name to announce
            }
            else
            {
                llSetTimerEvent(8.0); // Return to normal after brief interaction
            }
        }
        
        // Special case for announcement follow-up
        else if(currentState == SERVANT_STATE_ANNOUNCING && id != TSAR_UUID)
        {
            // Player has given name to announce
            // Check if Tsar is present - announcements are different
            if(tsarDetected)
            {
                llSay(PUBLIC_CHANNEL, "*" + servantName + " speaks quietly* I shall inform His Imperial Majesty of your arrival.");
                // Simulate going to inform Tsar
                llSetTimerEvent(5.0);
            }
            else
            {
                // Regular announcement
                llShout(PUBLIC_CHANNEL, "*" + servantName + " announces* Now entering: " + message);
                llSetTimerEvent(5.0);
            }
        }
    }
    
    // Timer for various behaviors and state transitions
    timer()
    {
        // Handle different states
        if(currentState == SERVANT_STATE_ATTENDING)
        {
            // Return to normal state after attending
            if(tsarDetected)
            {
                currentState = SERVANT_STATE_TSAR_PRESENT;
                llStopAnimation(BOW_ANIMATION);
                llStopAnimation(CURTSY_ANIMATION);
                llStartAnimation(IDLE_ANIMATION);
            }
            else
            {
                currentState = SERVANT_STATE_IDLE;
                llStopAnimation(BOW_ANIMATION);
                llStopAnimation(CURTSY_ANIMATION);
                llStartAnimation(IDLE_ANIMATION);
            }
            llSetTimerEvent(45.0);
        }
        else if(currentState == SERVANT_STATE_SERVING)
        {
            // Complete service
            if(tsarDetected)
            {
                llSay(PUBLIC_CHANNEL, "*" + servantName + " returns with a silver tray* Your refreshments, Your Imperial Majesty.");
                currentState = SERVANT_STATE_TSAR_PRESENT;
            }
            else
            {
                llSay(PUBLIC_CHANNEL, "*" + servantName + " returns with a tray* Your refreshments, as requested.");
                currentState = SERVANT_STATE_IDLE;
            }
            
            llStopAnimation(SERVE_ANIMATION);
            llStartAnimation(IDLE_ANIMATION);
            llSetTimerEvent(45.0);
        }
        else if(currentState == SERVANT_STATE_ANNOUNCING)
        {
            // Finish announcement duty
            llSay(PUBLIC_CHANNEL, "*" + servantName + " returns to his position*");
            
            if(tsarDetected)
            {
                currentState = SERVANT_STATE_TSAR_PRESENT;
            }
            else
            {
                currentState = SERVANT_STATE_IDLE;
            }
            
            llStartAnimation(IDLE_ANIMATION);
            llSetTimerEvent(45.0);
        }
        else if(currentState == SERVANT_STATE_TSAR_PRESENT)
        {
            // Remain attentive but return to more idle state
            currentState = SERVANT_STATE_IDLE;
            
            // Reset animation
            llStopAnimation(BOW_ANIMATION);
            llStopAnimation(CURTSY_ANIMATION);
            llStartAnimation(IDLE_ANIMATION);
            
            // Tsar-appropriate idle behavior
            if(tsarDetected && llFrand(1.0) < 0.3) // 30% chance
            {
                integer service_index = (integer)llFrand(llGetListLength(tsarServices));
                string serviceOffer = llList2String(tsarServices, service_index);
                
                llSay(PUBLIC_CHANNEL, "*" + servantName + " approaches discreetly* " + serviceOffer);
                tsarAttended = TRUE;
                lastTsarAttendanceTime = llGetUnixTime();
            }
            
            llSetTimerEvent(45.0);
        }
        else if(currentState == SERVANT_STATE_IDLE)
        {
            // Random servant behaviors
            float randomBehavior = llFrand(1.0);
            
            if(randomBehavior < 0.2) // 20% chance
            {
                // Straighten items
                llSay(PUBLIC_CHANNEL, "*" + servantName + " straightens items in the room*");
            }
            else if(randomBehavior < 0.3) // 10% chance
            {
                // Check if area needs attention
                llSay(PUBLIC_CHANNEL, "*" + servantName + " inspects the area for any needs*");
            }
            
            llSetTimerEvent(45.0 + llFrand(30.0)); // Random timing for next behavior
        }
        
        // Reset Tsar attendance after cooldown
        float currentTime = llGetUnixTime();
        if(tsarAttended && (currentTime - lastTsarAttendanceTime > tsarAttendanceCooldown))
        {
            tsarAttended = FALSE;
        }
    }
    
    // Handle touches - will respond differently based on who touches
    touch_start(integer total_number)
    {
        key toucher = llDetectedKey(0);
        
        // If the Tsar touches the servant
        if(toucher == TSAR_UUID)
        {
            llSay(PUBLIC_CHANNEL, "*" + servantName + " bows deeply* How may I serve you, Your Imperial Majesty?");
            
            // Display a dialog menu for the Tsar
            list tsarOptions = ["Bring Refreshments", "Announce Visitor", "Prepare Room", "Dismiss"];
            llDialog(TSAR_UUID, "Your commands, Your Imperial Majesty?", tsarOptions, servantChannel);
        }
        // If another player touches the servant
        else
        {
            // Skip if attending to Tsar
            if(tsarDetected && (currentState == SERVANT_STATE_ATTENDING || currentState == SERVANT_STATE_SERVING))
            {
                llSay(PUBLIC_CHANNEL, "Forgive me, but I am currently attending to His Imperial Majesty.");
                return;
            }
            
            // Determine player's rank (would integrate with HUD)
            integer noble_address_index = (integer)llFrand(llGetListLength(nobleAddresses));
            string playerRankAddress = llList2String(nobleAddresses, noble_address_index);
            
            llSay(PUBLIC_CHANNEL, "How may I assist you, " + playerRankAddress + "?");
            
            // Display options for regular nobles
            list playerOptions = ["Request Refreshments", "Request Announcement", "Ask About Court"];
            llDialog(toucher, "How may I be of service?", playerOptions, servantChannel);
        }
    }
    
    // Handle changed events - for attachments and permissions
    changed(integer change)
    {
        if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}