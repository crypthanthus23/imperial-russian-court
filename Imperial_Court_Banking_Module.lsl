// Imperial Russian Court HUD - Banking Module
// Handles banking, loans, investments, and economic functions
// This module communicates with the main HUD

// ============= CONSTANTS =============
// Communication Channels
integer MAIN_HUD_CHANNEL = -9876543; // Channel to communicate with main HUD
integer BANK_CHANNEL = -98016;       // Channel for banking menus
integer BANK_DATABASE_CHANNEL = -987654323; // Channel for bank database communications

// ============= VARIABLES =============
// Basic Character Data
key ownerID;
string firstName = "";
string familyName = "";
integer playerClass = -1; 
integer rank = 0;
integer rubles = 0; // Currency on hand (synced from main HUD)

// Banking and Economics 
integer bankAccount = 0; // Rubles in bank
float interestRate = 0.03; // 3% interest rate on deposits
list loans = []; // List of active loans (format: amount|interest|due_date)
integer creditRating = 50; // Credit rating (0-100)
integer hasBankAccount = FALSE; // Whether player has opened a bank account
integer bankingRights = 0; // 0=none, 1=deposits, 2=loans, 3=investments
list investments = []; // List of investments and returns
integer medicalDebt = 0; // Medical debt (synced from main HUD)

// System Variables
list activeListeners = []; // Track active listeners
string currentState = "INIT"; // Track current menu/state
integer lastBankUpdate = 0; // Timestamp of last bank update
integer dayInSeconds = 86400; // 24 hours in seconds

// ============= FUNCTIONS =============
// Function to show banking menu
showBankMenu() {
    string menuText = "\n=== IMPERIAL BANK ===\n\n";
    menuText += "Rubles on hand: " + (string)rubles + "\n";
    menuText += "Bank Account: " + (string)bankAccount + "\n";
    
    if (medicalDebt > 0) {
        menuText += "Medical Debt: " + (string)medicalDebt + "\n";
    }
    
    if (llGetListLength(loans) > 0) {
        menuText += "Active Loans: " + (string)llGetListLength(loans) + "\n";
    }
    
    menuText += "\nWhat would you like to do?";
    
    list buttons = ["Deposit", "Withdraw", "View Loans", "Back"];
    
    // Add loan option if credit rating is sufficient
    if (creditRating >= 60) {
        buttons += ["Request Loan"];
    }
    
    // Special options for bankers
    if (playerClass == 4 && rank <= 1) { // Banker
        buttons += ["Bank Ledger"];
    }
    
    llDialog(ownerID, menuText, buttons, BANK_CHANNEL);
    currentState = "BANK_MENU";
}

// Function to handle deposits
handleDeposit() {
    string menuText = "\n=== BANK DEPOSIT ===\n\n";
    menuText += "Rubles on hand: " + (string)rubles + "\n";
    menuText += "How much would you like to deposit?";
    
    list buttons = ["10", "50", "100", "500", "1000", "All", "Cancel"];
    
    llDialog(ownerID, menuText, buttons, BANK_CHANNEL);
    currentState = "DEPOSIT";
}

// Function to handle withdrawals
handleWithdraw() {
    string menuText = "\n=== BANK WITHDRAWAL ===\n\n";
    menuText += "Bank Account: " + (string)bankAccount + "\n";
    menuText += "How much would you like to withdraw?";
    
    list buttons = ["10", "50", "100", "500", "1000", "All", "Cancel"];
    
    llDialog(ownerID, menuText, buttons, BANK_CHANNEL);
    currentState = "WITHDRAW";
}

// Process deposit
processDeposit(string amount) {
    integer depositAmount;
    
    if (amount == "All") {
        depositAmount = rubles;
    } else {
        depositAmount = (integer)amount;
    }
    
    if (depositAmount <= 0) {
        llOwnerSay("Please enter a valid amount to deposit.");
        handleDeposit();
        return;
    }
    
    if (depositAmount > rubles) {
        llOwnerSay("You don't have that many rubles to deposit.");
        handleDeposit();
        return;
    }
    
    // Update account
    bankAccount += depositAmount;
    rubles -= depositAmount;
    
    // Update on main HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_RUBLES|" + (string)rubles, NULL_KEY);
    
    // Send bank account update to Core HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_BANK_ACCOUNT|" + (string)bankAccount, NULL_KEY);
    
    // Send update to bank database (in a real implementation)
    llRegionSay(BANK_DATABASE_CHANNEL, "DEPOSIT|" + (string)ownerID + "|" + (string)depositAmount);
    
    llOwnerSay("You have deposited " + (string)depositAmount + " rubles into your account.");
    showBankMenu();
}

// Process withdrawal
processWithdrawal(string amount) {
    integer withdrawAmount;
    
    if (amount == "All") {
        withdrawAmount = bankAccount;
    } else {
        withdrawAmount = (integer)amount;
    }
    
    if (withdrawAmount <= 0) {
        llOwnerSay("Please enter a valid amount to withdraw.");
        handleWithdraw();
        return;
    }
    
    if (withdrawAmount > bankAccount) {
        llOwnerSay("You don't have that much in your account.");
        handleWithdraw();
        return;
    }
    
    // Update account
    bankAccount -= withdrawAmount;
    rubles += withdrawAmount;
    
    // Update on main HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_RUBLES|" + (string)rubles, NULL_KEY);
    
    // Send bank account update to Core HUD
    llMessageLinked(LINK_SET, 0, "UPDATE_BANK_ACCOUNT|" + (string)bankAccount, NULL_KEY);
    
    // Send update to bank database (in a real implementation)
    llRegionSay(BANK_DATABASE_CHANNEL, "WITHDRAW|" + (string)ownerID + "|" + (string)withdrawAmount);
    
    llOwnerSay("You have withdrawn " + (string)withdrawAmount + " rubles from your account.");
    showBankMenu();
}

// Function to view loans
viewLoans() {
    string menuText = "\n=== ACTIVE LOANS ===\n\n";
    
    if (llGetListLength(loans) == 0) {
        menuText += "You have no active loans.\n";
    } else {
        integer i;
        for (i = 0; i < llGetListLength(loans); i++) {
            list loanInfo = llParseString2List(llList2String(loans, i), ["|"], []);
            
            if (llGetListLength(loanInfo) >= 3) {
                integer amount = (integer)llList2String(loanInfo, 0);
                float interest = (float)llList2String(loanInfo, 1);
                string dueDate = llList2String(loanInfo, 2);
                
                menuText += "Loan #" + (string)(i + 1) + ":\n";
                menuText += "  Amount: " + (string)amount + " rubles\n";
                menuText += "  Interest: " + (string)(interest * 100) + "%\n";
                menuText += "  Due: " + dueDate + "\n\n";
            }
        }
    }
    
    list buttons = ["Pay Loan", "Back"];
    
    llDialog(ownerID, menuText, buttons, BANK_CHANNEL);
    currentState = "VIEW_LOANS";
}

// Check for daily interest
checkDailyInterest() {
    integer currentTime = llGetUnixTime();
    
    // Check for bank interest (once a day)
    if (currentTime - lastBankUpdate >= dayInSeconds) {
        if (bankAccount > 0) {
            // Calculate interest
            integer interestAmount = (integer)(bankAccount * interestRate / 365.0); // Daily interest
            
            if (interestAmount > 0) {
                bankAccount += interestAmount;
                llOwnerSay("You have earned " + (string)interestAmount + " rubles in bank interest.");
                
                // Send bank account update to Core HUD
                llMessageLinked(LINK_SET, 0, "UPDATE_BANK_ACCOUNT|" + (string)bankAccount, NULL_KEY);
            }
        }
        
        // Check loan payments due
        checkLoans();
        
        lastBankUpdate = currentTime;
    }
}

// Check loans for payments due
checkLoans() {
    // This would implement loan payment checks
    // For now, simplified version
}

// Initialize the module
initialize() {
    // Get owner key
    ownerID = llGetOwner();
    
    // Reset dialog listeners
    integer i;
    for (i = 0; i < llGetListLength(activeListeners); i++) {
        llListenRemove(llList2Integer(activeListeners, i));
    }
    activeListeners = [];
    
    // Set up listeners
    activeListeners += [llListen(BANK_CHANNEL, "", NULL_KEY, "")];
    
    // Request data from main HUD
    llMessageLinked(LINK_SET, 0, "REQUEST_BANK_DATA", NULL_KEY);
    
    // Start timer for interest calculations
    llSetTimerEvent(300.0); // Check every 5 minutes
    
    llOwnerSay("Banking Module initialized.");
}

default {
    state_entry() {
        initialize();
    }
    
    touch_start(integer total_number) {
        if (llDetectedKey(0) == llGetOwner()) {
            showBankMenu();
        }
    }
    
    timer() {
        checkDailyInterest();
    }
    
    listen(integer channel, string name, key id, string message) {
        if (id != ownerID) return;
        
        if (channel == BANK_CHANNEL) {
            if (currentState == "BANK_MENU") {
                if (message == "Deposit") {
                    handleDeposit();
                }
                else if (message == "Withdraw") {
                    handleWithdraw();
                }
                else if (message == "View Loans") {
                    viewLoans();
                }
                else if (message == "Back") {
                    // Tell main HUD to show main menu
                    llMessageLinked(LINK_SET, 0, "SHOW_MAIN_MENU", NULL_KEY);
                }
            }
            else if (currentState == "DEPOSIT") {
                if (message == "Cancel") {
                    showBankMenu();
                } else {
                    processDeposit(message);
                }
            }
            else if (currentState == "WITHDRAW") {
                if (message == "Cancel") {
                    showBankMenu();
                } else {
                    processWithdrawal(message);
                }
            }
            else if (currentState == "VIEW_LOANS") {
                if (message == "Back") {
                    showBankMenu();
                }
            }
        }
    }
    
    link_message(integer sender_num, integer num, string message, key id) {
        list msgParts = llParseString2List(message, ["|"], []);
        string command = llList2String(msgParts, 0);
        
        if (command == "BANK_DATA") {
            // Receiving bank data from main HUD
            if (llGetListLength(msgParts) >= 7) {
                firstName = llList2String(msgParts, 1);
                familyName = llList2String(msgParts, 2);
                playerClass = (integer)llList2String(msgParts, 3);
                rank = (integer)llList2String(msgParts, 4);
                rubles = (integer)llList2String(msgParts, 5);
                bankAccount = (integer)llList2String(msgParts, 6);
                medicalDebt = (integer)llList2String(msgParts, 7);
                
                // Process loans if present
                if (llGetListLength(msgParts) >= 9) {
                    string loanString = llList2String(msgParts, 8);
                    loans = llParseString2List(loanString, [";"], []);
                }
            }
        }
        else if (command == "SHOW_BANK_MENU") {
            showBankMenu();
        }
        else if (command == "UPDATE_RUBLES_BANK") {
            // Update rubles from main HUD
            if (llGetListLength(msgParts) >= 2) {
                rubles = (integer)llList2String(msgParts, 1);
            }
        }
    }
}