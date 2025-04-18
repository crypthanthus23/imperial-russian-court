// Imperial Court Relationship System Connector
// A lightweight script to coordinate between relationship and reputation modules
// This connector ensures the modules can update each other without direct linking

// Constants
integer COURT_RELATIONSHIPS_CHANNEL = -100;
integer REPUTATION_UPDATE_CHANNEL = -103;
integer CONNECTOR_CHANNEL = -104;
integer CONNECTOR_DIALOG_CHANNEL = -104456; // New dedicated channel for dialog menus

// Shared key for authenticating messages between scripts
string AUTHENTICATION_KEY = "ImperialCourtAuth1905";

// Basic information
key ownerKey;
string ownerName;

// Forward relationship updates to reputation system and vice versa
forwardRelationshipUpdates(string message) {
    // Forward to reputation channel
    llRegionSay(REPUTATION_UPDATE_CHANNEL, message);
}

forwardReputationUpdates(string message) {
    // Forward to relationship channel
    llRegionSay(COURT_RELATIONSHIPS_CHANNEL, message);
}

// Show status menu dialog
showStatusMenu(key id) {
    list buttons = [
        "View Status",
        "Test Connection",
        "Module Info",
        "Close Menu"
    ];
    
    llDialog(id, "Imperial Court Relationship System Connector\n\nSelect an option:", buttons, CONNECTOR_DIALOG_CHANNEL);
}

// Show connector status
showConnectorStatus(key id) {
    string status = "Imperial Court System Connector Status:\n\n";
    status += "Owner: " + ownerName + "\n";
    status += "Status: Active and Running\n";
    status += "Connected Channels: \n";
    status += " - Court Relationships (CH: " + (string)COURT_RELATIONSHIPS_CHANNEL + ")\n";
    status += " - Court Reputation (CH: " + (string)REPUTATION_UPDATE_CHANNEL + ")\n";
    status += " - Direct Commands (CH: " + (string)CONNECTOR_CHANNEL + ")\n";
    
    llDialog(id, status, ["Back to Menu"], CONNECTOR_DIALOG_CHANNEL);
}

// Show module information
showModuleInfo(key id) {
    string info = "Imperial Court Connector Information:\n\n";
    info += "This module coordinates communication between the\n";
    info += "Relationship System and Reputation Module, enabling\n";
    info += "these components to work together without direct linking.\n\n";
    info += "Updates from one system are automatically forwarded to the other,\n";
    info += "ensuring consistent social dynamics throughout the court.\n";
    
    llDialog(id, info, ["Back to Menu"], CONNECTOR_DIALOG_CHANNEL);
}

// Test connections to other modules
testConnections(key id) {
    llOwnerSay("Testing connections to relationship and reputation modules...");
    
    // Send test messages to both systems
    string testMessage = llList2CSV([AUTHENTICATION_KEY, "TEST_CONNECTION", (string)ownerKey]);
    llRegionSay(COURT_RELATIONSHIPS_CHANNEL, testMessage);
    llRegionSay(REPUTATION_UPDATE_CHANNEL, testMessage);
    
    // Notify owner
    llDialog(id, "Test signals sent to both modules. If they're active, they will respond with a confirmation message.", ["Back to Menu"], CONNECTOR_DIALOG_CHANNEL);
}

// Handle dialog responses
handleDialogResponse(key id, string message) {
    if(message == "View Status") {
        showConnectorStatus(id);
    }
    else if(message == "Test Connection") {
        testConnections(id);
    }
    else if(message == "Module Info") {
        showModuleInfo(id);
    }
    else if(message == "Back to Menu") {
        showStatusMenu(id);
    }
    else if(message == "Close Menu") {
        llOwnerSay("Imperial Court Connector menu closed.");
    }
}

// Default state
default {
    state_entry() {
        ownerKey = llGetOwner();
        ownerName = llKey2Name(ownerKey);
        
        // Listen for updates from both systems
        llListen(COURT_RELATIONSHIPS_CHANNEL, "", NULL_KEY, "");
        llListen(REPUTATION_UPDATE_CHANNEL, "", NULL_KEY, "");
        llListen(CONNECTOR_CHANNEL, "", NULL_KEY, "");
        llListen(CONNECTOR_DIALOG_CHANNEL, "", NULL_KEY, "");
        
        llOwnerSay("Imperial Court Relationship System Connector initialized.");
        llOwnerSay("Coordinating communication between relationship and reputation modules.");
        llOwnerSay("Touch this HUD to access connector status and tests.");
    }
    
    touch_start(integer total_number) {
        key toucherId = llDetectedKey(0);
        
        // Only respond to owner's touch
        if(toucherId == llGetOwner()) {
            showStatusMenu(toucherId);
            llOwnerSay("Opening connector menu...");
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Handle dialog responses
        if(id == llGetOwner() && channel == CONNECTOR_DIALOG_CHANNEL) {
            handleDialogResponse(id, message);
            return;
        }
        
        // Listen for and forward messages between the relationship and reputation systems
        list params = llCSV2List(message);
        
        // Verify authentication key to prevent spoofing
        if(llList2String(params, 0) == AUTHENTICATION_KEY) {
            if(channel == COURT_RELATIONSHIPS_CHANNEL) {
                // Forward relationship updates to reputation system
                forwardRelationshipUpdates(message);
                
                // Check for test connection responses
                if(llList2String(params, 1) == "TEST_CONNECTION_RESPONSE") {
                    llOwnerSay("✓ Relationship system connection confirmed.");
                }
            }
            else if(channel == REPUTATION_UPDATE_CHANNEL) {
                // Forward reputation updates to relationship system
                forwardReputationUpdates(message);
                
                // Check for test connection responses
                if(llList2String(params, 1) == "TEST_CONNECTION_RESPONSE") {
                    llOwnerSay("✓ Reputation system connection confirmed.");
                }
            }
            else if(channel == CONNECTOR_CHANNEL) {
                // Handle direct commands to the connector
                string command = llList2String(params, 1);
                if(command == "STATUS") {
                    llOwnerSay("Imperial Court System Connector is active and running.");
                }
                else if(command == "TEST_CONNECTION") {
                    // Send response
                    string response = llList2CSV([AUTHENTICATION_KEY, "TEST_CONNECTION_RESPONSE", (string)ownerKey]);
                    llRegionSay(channel, response);
                }
            }
        }
    }
    
    changed(integer change) {
        if(change & CHANGED_OWNER) {
            // Reset for new owner
            ownerKey = llGetOwner();
            ownerName = llKey2Name(ownerKey);
            
            llOwnerSay("Imperial Court System Connector reset for new owner.");
        }
    }
}