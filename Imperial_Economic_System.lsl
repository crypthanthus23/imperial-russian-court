// Imperial Russian Court RP - Economic System
// This script manages the Russian Ruble currency system
// For use with the Imperial Russian Court roleplay system

// Communication Channels
integer ECONOMY_CHANNEL = -7000001;
integer TRANSACTION_CHANNEL;
integer BANK_MENU_CHANNEL;
integer listenHandle;

// Economic Constants
float RUBLE_EXCHANGE_RATE = 0.5152; // 1905 rate to USD
string CURRENCY_SYMBOL = "₽"; // Ruble symbol

// Bank Settings
string BANK_NAME = "Imperial State Bank";
float INTEREST_RATE = 0.05; // 5% annual interest
float LOAN_INTEREST_RATE = 0.10; // 10% for loans
integer MIN_DEPOSIT = 5; // Minimum deposit amount
integer MIN_WITHDRAWAL = 1; // Minimum withdrawal amount
integer MAX_TRANSACTION = 10000; // Maximum single transaction
integer STARTING_CASH = 100; // Default starting cash

// Security
key ownerID;
string ownerName;
integer isInitialized = FALSE;
integer isATM = FALSE; // If TRUE, functions as banking terminal

// Economic Stats
integer playerRubles = 0; // Cash on hand
integer bankBalance = 0; // Bank account balance
integer transactionCount = 0; // Number of transactions
integer lastTransactionAmount = 0;
string lastTransactionType = "None";
string lastTransactionPartner = "None";

// Class-based settings
string playerClass = "Commoner"; // Default
string playerRank = "None"; // Noble rank
integer creditLimit = 0; // How much can be borrowed
integer transactionTaxPercent = 5; // Tax on transactions

// Initialize the system
initialize() {
    // Set up random channels
    TRANSACTION_CHANNEL = ECONOMY_CHANNEL - (integer)llFrand(10000);
    BANK_MENU_CHANNEL = ECONOMY_CHANNEL - 10000 - (integer)llFrand(10000);
    
    // Get owner name
    ownerName = llKey2Name(ownerID);
    
    // Set up listening
    llListen(ECONOMY_CHANNEL, "", NULL_KEY, "");
    
    // Check if this is an ATM
    if (llGetObjectName() == "Imperial Bank Terminal" || 
        llSubStringIndex(llGetObjectDesc(), "Bank Terminal") >= 0) {
        isATM = TRUE;
        setupBankTerminal();
    }
    else {
        // Regular wallet/currency object
        playerRubles = STARTING_CASH;
        updateDisplay();
    }
}

// Setup appearance and function for bank terminal
setupBankTerminal() {
    if (isATM) {
        // Set bank terminal appearance
        llSetText(BANK_NAME + "\nTouch to access banking services", <0.2, 0.5, 0.8>, 1.0);
        llOwnerSay("Bank terminal initialized. Ready to serve customers.");
    }
}

// Update HUD display (if this is a personal wallet)
updateDisplay() {
    if (!isATM) {
        // Show wallet and bank status
        string displayText = "=== FINANCIAL STATUS ===\n";
        displayText += "Cash: " + CURRENCY_SYMBOL + " " + (string)playerRubles + " rubles\n";
        displayText += "Bank: " + CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles\n";
        
        if (lastTransactionAmount > 0) {
            displayText += "Last: " + lastTransactionType + " " + 
                          CURRENCY_SYMBOL + " " + (string)lastTransactionAmount + 
                          " with " + lastTransactionPartner + "\n";
        }
        
        // Different colors based on financial status
        vector textColor;
        if (playerRubles + bankBalance > 1000) {
            textColor = <0.1, 0.7, 0.2>; // Wealthy - green
        }
        else if (playerRubles + bankBalance > 100) {
            textColor = <0.7, 0.7, 0.1>; // Moderate - yellow
        }
        else {
            textColor = <0.7, 0.2, 0.1>; // Poor - red
        }
        
        llSetText(displayText, textColor, 1.0);
    }
}

// Show main bank menu
showBankMenu(key userID) {
    string menuText = "\n=== " + BANK_NAME + " ===\n\n";
    menuText += "Welcome to the Imperial State Bank.\n";
    menuText += "How may we assist you today?\n\n";
    
    list buttons = [
        "Balance", "Deposit", "Withdraw",
        "Transfer", "Currency", "About",
        "Exit"
    ];
    
    // Add loan option for eligible customers
    if (creditLimit > 0) {
        buttons = llListInsertList(buttons, ["Loans"], 4);
    }
    
    llListenRemove(listenHandle);
    listenHandle = llListen(BANK_MENU_CHANNEL, "", userID, "");
    llDialog(userID, menuText, buttons, BANK_MENU_CHANNEL);
}

// Show deposit menu
showDepositMenu(key userID) {
    string menuText = "\n=== MAKE A DEPOSIT ===\n\n";
    menuText += "Cash on hand: " + CURRENCY_SYMBOL + " " + (string)playerRubles + " rubles\n";
    menuText += "Bank balance: " + CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles\n\n";
    menuText += "How much would you like to deposit?\n";
    
    // Create buttons with different deposit amounts
    list buttons = [];
    
    // Add appropriate deposit options based on cash on hand
    if (playerRubles >= 5) buttons += ["₽5"];
    if (playerRubles >= 10) buttons += ["₽10"];
    if (playerRubles >= 25) buttons += ["₽25"];
    if (playerRubles >= 50) buttons += ["₽50"];
    if (playerRubles >= 100) buttons += ["₽100"];
    if (playerRubles >= 500) buttons += ["₽500"];
    
    // Add "All" option if player has cash
    if (playerRubles > 0) buttons += ["All"];
    
    // Add custom option and back button
    buttons += ["Custom", "Back"];
    
    llListenRemove(listenHandle);
    listenHandle = llListen(BANK_MENU_CHANNEL, "", userID, "");
    llDialog(userID, menuText, buttons, BANK_MENU_CHANNEL);
}

// Show withdraw menu
showWithdrawMenu(key userID) {
    string menuText = "\n=== MAKE A WITHDRAWAL ===\n\n";
    menuText += "Cash on hand: " + CURRENCY_SYMBOL + " " + (string)playerRubles + " rubles\n";
    menuText += "Bank balance: " + CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles\n\n";
    menuText += "How much would you like to withdraw?\n";
    
    // Create buttons with different withdrawal amounts
    list buttons = [];
    
    // Add appropriate withdrawal options based on bank balance
    if (bankBalance >= 5) buttons += ["₽5"];
    if (bankBalance >= 10) buttons += ["₽10"];
    if (bankBalance >= 25) buttons += ["₽25"];
    if (bankBalance >= 50) buttons += ["₽50"];
    if (bankBalance >= 100) buttons += ["₽100"];
    if (bankBalance >= 500) buttons += ["₽500"];
    
    // Add "All" option if player has bank balance
    if (bankBalance > 0) buttons += ["All"];
    
    // Add custom option and back button
    buttons += ["Custom", "Back"];
    
    llListenRemove(listenHandle);
    listenHandle = llListen(BANK_MENU_CHANNEL, "", userID, "");
    llDialog(userID, menuText, buttons, BANK_MENU_CHANNEL);
}

// Process a deposit
processDeposit(integer amount) {
    if (amount <= 0) {
        llOwnerSay("Invalid deposit amount.");
        return;
    }
    
    if (amount > playerRubles) {
        llOwnerSay("You do not have " + (string)amount + " rubles to deposit.");
        return;
    }
    
    // Process the deposit
    playerRubles -= amount;
    bankBalance += amount;
    
    // Update transaction info
    transactionCount++;
    lastTransactionAmount = amount;
    lastTransactionType = "Deposit";
    lastTransactionPartner = BANK_NAME;
    
    // Success message
    llOwnerSay("You have deposited " + CURRENCY_SYMBOL + " " + (string)amount + 
              " rubles into your account. Your new balance is " + 
              CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles.");
    
    // Role-play message
    llSay(0, ownerName + " completes a transaction at the Imperial State Bank.");
    
    // Update display
    updateDisplay();
}

// Process a withdrawal
processWithdrawal(integer amount) {
    if (amount <= 0) {
        llOwnerSay("Invalid withdrawal amount.");
        return;
    }
    
    if (amount > bankBalance) {
        llOwnerSay("You do not have " + (string)amount + " rubles in your account.");
        return;
    }
    
    // Process the withdrawal
    bankBalance -= amount;
    playerRubles += amount;
    
    // Update transaction info
    transactionCount++;
    lastTransactionAmount = amount;
    lastTransactionType = "Withdrawal";
    lastTransactionPartner = BANK_NAME;
    
    // Success message
    llOwnerSay("You have withdrawn " + CURRENCY_SYMBOL + " " + (string)amount + 
              " rubles from your account. Your new balance is " + 
              CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles.");
    
    // Role-play message
    llSay(0, ownerName + " completes a transaction at the Imperial State Bank.");
    
    // Update display
    updateDisplay();
}

// Show transfer menu
showTransferMenu(key userID) {
    string menuText = "\n=== TRANSFER FUNDS ===\n\n";
    menuText += "Cash on hand: " + CURRENCY_SYMBOL + " " + (string)playerRubles + " rubles\n";
    menuText += "Bank balance: " + CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles\n\n";
    menuText += "To send money to another person, they must be nearby.\n";
    menuText += "A " + (string)transactionTaxPercent + "% transaction tax will be applied.\n";
    
    list buttons = [
        "Send from Cash", "Send from Bank", 
        "Back"
    ];
    
    llListenRemove(listenHandle);
    listenHandle = llListen(BANK_MENU_CHANNEL, "", userID, "");
    llDialog(userID, menuText, buttons, BANK_MENU_CHANNEL);
}

// Process a transfer from cash
processTransferFromCash(key recipientID, integer amount) {
    // Calculate tax
    integer taxAmount = (amount * transactionTaxPercent) / 100;
    integer transferAmount = amount - taxAmount;
    
    if (amount <= 0) {
        llOwnerSay("Invalid transfer amount.");
        return;
    }
    
    if (amount > playerRubles) {
        llOwnerSay("You do not have " + (string)amount + " rubles to transfer.");
        return;
    }
    
    // Process the transfer
    playerRubles -= amount;
    
    // Send transaction message on economy channel
    string transactionMessage = "TRANSFER|" + (string)ownerID + "|" + 
                               ownerName + "|" + (string)transferAmount + "|" +
                               (string)recipientID;
    llRegionSay(ECONOMY_CHANNEL, transactionMessage);
    
    // Update transaction info
    transactionCount++;
    lastTransactionAmount = amount;
    lastTransactionType = "Transfer Out";
    lastTransactionPartner = llKey2Name(recipientID);
    
    // Success message
    llOwnerSay("You have sent " + CURRENCY_SYMBOL + " " + (string)transferAmount + 
              " rubles to " + llKey2Name(recipientID) + ". (Tax: " + 
              CURRENCY_SYMBOL + " " + (string)taxAmount + ")");
    
    // Role-play message
    llSay(0, ownerName + " hands some money to " + llKey2Name(recipientID) + ".");
    
    // Update display
    updateDisplay();
}

// Process a transfer from bank
processTransferFromBank(key recipientID, integer amount) {
    // Calculate tax
    integer taxAmount = (amount * transactionTaxPercent) / 100;
    integer transferAmount = amount - taxAmount;
    
    if (amount <= 0) {
        llOwnerSay("Invalid transfer amount.");
        return;
    }
    
    if (amount > bankBalance) {
        llOwnerSay("You do not have " + (string)amount + " rubles in your account to transfer.");
        return;
    }
    
    // Process the transfer
    bankBalance -= amount;
    
    // Send transaction message on economy channel
    string transactionMessage = "TRANSFER|" + (string)ownerID + "|" + 
                               ownerName + "|" + (string)transferAmount + "|" +
                               (string)recipientID;
    llRegionSay(ECONOMY_CHANNEL, transactionMessage);
    
    // Update transaction info
    transactionCount++;
    lastTransactionAmount = amount;
    lastTransactionType = "Bank Transfer";
    lastTransactionPartner = llKey2Name(recipientID);
    
    // Success message
    llOwnerSay("You have transferred " + CURRENCY_SYMBOL + " " + (string)transferAmount + 
              " rubles from your account to " + llKey2Name(recipientID) + 
              ". (Tax: " + CURRENCY_SYMBOL + " " + (string)taxAmount + ")");
    
    // Role-play message
    llSay(0, ownerName + " arranges a bank transfer to " + llKey2Name(recipientID) + ".");
    
    // Update display
    updateDisplay();
}

// Set player class and adjust settings accordingly
setPlayerClass(string newClass, string newRank) {
    playerClass = newClass;
    playerRank = newRank;
    
    // Set economic parameters based on class
    if (newClass == "Aristocracy") {
        if (newRank == "Tsar" || newRank == "Tsarina") {
            creditLimit = 1000000; // Unlimited for practical purposes
            transactionTaxPercent = 0; // No tax for imperial family
        }
        else if (newRank == "Grand Duke" || newRank == "Grand Duchess") {
            creditLimit = 500000;
            transactionTaxPercent = 0; // No tax for imperial family
        }
        else if (newRank == "Prince" || newRank == "Princess") {
            creditLimit = 100000;
            transactionTaxPercent = 1;
        }
        else if (newRank == "Duke" || newRank == "Duchess") {
            creditLimit = 50000;
            transactionTaxPercent = 1;
        }
        else if (newRank == "Count" || newRank == "Countess") {
            creditLimit = 25000;
            transactionTaxPercent = 2;
        }
        else if (newRank == "Baron" || newRank == "Baroness") {
            creditLimit = 10000;
            transactionTaxPercent = 3;
        }
        else {
            creditLimit = 5000;
            transactionTaxPercent = 3;
        }
    }
    else if (newClass == "Bourgeoisie") {
        creditLimit = 7500;
        transactionTaxPercent = 4;
    }
    else if (newClass == "Intelligentsia") {
        creditLimit = 2000;
        transactionTaxPercent = 5;
    }
    else if (newClass == "Clergy") {
        creditLimit = 1000;
        transactionTaxPercent = 3;
    }
    else if (newClass == "Military") {
        creditLimit = 1500;
        transactionTaxPercent = 4;
    }
    else { // Peasantry or default
        creditLimit = 250;
        transactionTaxPercent = 5;
    }
}

// Show currency exchange information
showCurrencyInfo(key userID) {
    string menuText = "\n=== CURRENCY INFORMATION ===\n\n";
    menuText += "The Russian Empire uses the ruble (" + CURRENCY_SYMBOL + ") as its currency.\n\n";
    
    menuText += "Current Exchange Rates (1905):\n";
    menuText += "1 Ruble = $" + (string)RUBLE_EXCHANGE_RATE + " USD\n";
    menuText += "1 Ruble = 2.16 German Marks\n";
    menuText += "1 Ruble = 0.11 British Pounds\n\n";
    
    menuText += "Sample Prices (1905):\n";
    menuText += "- Worker's daily wage: 1-2 rubles\n";
    menuText += "- Loaf of bread: 0.02 rubles\n";
    menuText += "- Bottle of vodka: 0.40 rubles\n";
    menuText += "- Men's suit: 15-30 rubles\n";
    menuText += "- Train ticket (3rd class): 3-5 rubles\n";
    
    llListenRemove(listenHandle);
    listenHandle = llListen(BANK_MENU_CHANNEL, "", userID, "");
    llDialog(userID, menuText, ["Back"], BANK_MENU_CHANNEL);
}

// Load player data from notecard
loadPlayerData() {
    if (llGetInventoryType("character_data") == INVENTORY_NOTECARD) {
        llOwnerSay("Loading financial data from notecard...");
        llGetNotecardLine("character_data", 0);
    }
}

default {
    state_entry() {
        // Initialize
        ownerID = llGetOwner();
        initialize();
        
        // Load data
        loadPlayerData();
        
        // Welcome message
        if (!isATM) {
            llOwnerSay("Imperial Russian Economic System Initialized");
            llOwnerSay("Your current finances: " + CURRENCY_SYMBOL + " " + 
                      (string)playerRubles + " rubles in cash, " + 
                      CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles in bank");
        }
    }
    
    touch_start(integer total_number) {
        key toucherID = llDetectedKey(0);
        
        if (isATM) {
            // This is a bank terminal - show services to all users
            showBankMenu(toucherID);
        }
        else if (toucherID == ownerID) {
            // Personal wallet - only owner can access
            showBankMenu(toucherID);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Bank Menu
        if (channel == BANK_MENU_CHANNEL) {
            if (message == "Balance") {
                // Show balance information
                string balanceMsg = "\n=== ACCOUNT BALANCE ===\n\n";
                
                if (isATM) {
                    // Identify the user
                    balanceMsg += "Account Holder: " + llKey2Name(id) + "\n\n";
                }
                
                balanceMsg += "Cash on hand: " + CURRENCY_SYMBOL + " " + (string)playerRubles + " rubles\n";
                balanceMsg += "Bank balance: " + CURRENCY_SYMBOL + " " + (string)bankBalance + " rubles\n";
                balanceMsg += "Total assets: " + CURRENCY_SYMBOL + " " + (string)(playerRubles + bankBalance) + " rubles\n";
                
                if (creditLimit > 0) {
                    balanceMsg += "Credit limit: " + CURRENCY_SYMBOL + " " + (string)creditLimit + " rubles\n";
                }
                
                balanceMsg += "\nInterest rate: " + (string)(INTEREST_RATE * 100) + "% per annum";
                
                llDialog(id, balanceMsg, ["Back"], BANK_MENU_CHANNEL);
            }
            else if (message == "Deposit") {
                showDepositMenu(id);
            }
            else if (message == "Withdraw") {
                showWithdrawMenu(id);
            }
            else if (message == "Transfer") {
                showTransferMenu(id);
            }
            else if (message == "Currency") {
                showCurrencyInfo(id);
            }
            else if (message == "Loans") {
                // For now, just show a message about loans
                string loanMsg = "\n=== LOANS DEPARTMENT ===\n\n";
                loanMsg += "Your credit limit: " + CURRENCY_SYMBOL + " " + (string)creditLimit + " rubles\n";
                loanMsg += "Interest rate: " + (string)(LOAN_INTEREST_RATE * 100) + "% per annum\n\n";
                loanMsg += "Please speak to a bank official for loan arrangements.";
                
                llDialog(id, loanMsg, ["Back"], BANK_MENU_CHANNEL);
            }
            else if (message == "About") {
                // Show information about the bank
                string aboutMsg = "\n=== " + BANK_NAME + " ===\n\n";
                aboutMsg += "Founded in 1860, the Imperial State Bank is the central bank of the Russian Empire.\n\n";
                aboutMsg += "Services offered:\n";
                aboutMsg += "- Deposits and Withdrawals\n";
                aboutMsg += "- Fund Transfers\n";
                aboutMsg += "- Loans for Eligible Customers\n";
                aboutMsg += "- Financial Information\n\n";
                aboutMsg += "The bank is under the direct authority of the Imperial Ministry of Finance.";
                
                llDialog(id, aboutMsg, ["Back"], BANK_MENU_CHANNEL);
            }
            else if (message == "Exit") {
                llListenRemove(listenHandle);
                llOwnerSay("Thank you for using the " + BANK_NAME + ".");
            }
            else if (message == "Send from Cash") {
                // Ask user to select recipient
                llSensor("", NULL_KEY, AGENT, 10.0, PI);
                llOwnerSay("Please select a recipient for your transfer.");
            }
            else if (message == "Send from Bank") {
                // Ask user to select recipient
                llSensor("", NULL_KEY, AGENT, 10.0, PI);
                llOwnerSay("Please select a recipient for your bank transfer.");
            }
            else if (message == "Back") {
                showBankMenu(id);
            }
            // Handle deposit amounts
            else if (llSubStringIndex(message, "₽") == 0) {
                // Extract amount from ₽X format
                integer amount = (integer)llGetSubString(message, 1, -1);
                processDeposit(amount);
                showDepositMenu(id);
            }
            else if (message == "All" && llGetListLength(llParseString2List(message, ["Deposit"], [])) > 0) {
                // Deposit all cash
                if (playerRubles > 0) {
                    processDeposit(playerRubles);
                }
                showDepositMenu(id);
            }
            else if (message == "Custom" && channel == BANK_MENU_CHANNEL) {
                // Ask for custom amount
                llTextBox(id, "Enter the amount you wish to deposit:", TRANSACTION_CHANNEL);
            }
            // Handle withdrawal amounts - these messages come from the withdrawal menu
            else if (llSubStringIndex(message, "₽") == 0 && channel == BANK_MENU_CHANNEL) {
                // Extract amount from ₽X format
                integer amount = (integer)llGetSubString(message, 1, -1);
                processWithdrawal(amount);
                showWithdrawMenu(id);
            }
            else if (message == "All" && channel == BANK_MENU_CHANNEL) {
                // Withdraw all from bank
                if (bankBalance > 0) {
                    processWithdrawal(bankBalance);
                }
                showWithdrawMenu(id);
            }
        }
        
        // Economy Channel
        else if (channel == ECONOMY_CHANNEL) {
            // Handle incoming transfers
            if (llSubStringIndex(message, "TRANSFER|") == 0) {
                list parts = llParseString2List(message, ["|"], []);
                
                if (llGetListLength(parts) >= 5) {
                    key senderID = (key)llList2String(parts, 1);
                    string senderName = llList2String(parts, 2);
                    integer amount = (integer)llList2String(parts, 3);
                    key recipientID = (key)llList2String(parts, 4);
                    
                    // Check if we are the recipient
                    if (recipientID == ownerID) {
                        // Add money to cash
                        playerRubles += amount;
                        
                        // Update transaction info
                        transactionCount++;
                        lastTransactionAmount = amount;
                        lastTransactionType = "Transfer In";
                        lastTransactionPartner = senderName;
                        
                        // Notify owner
                        llOwnerSay("You have received " + CURRENCY_SYMBOL + " " + 
                                  (string)amount + " rubles from " + senderName + ".");
                        
                        // Update display
                        updateDisplay();
                    }
                }
            }
            // Handle bank data update requests
            else if (message == "UPDATE_BANK_DATA|" + (string)ownerID) {
                // User is requesting their bank data
                // This is not needed in a standalone system
            }
        }
        
        // Transaction Channel - for custom amounts
        else if (channel == TRANSACTION_CHANNEL) {
            // Try to parse amount
            integer amount = (integer)message;
            
            if (amount > 0) {
                // Check context - what transaction are we doing?
                if (llGetSubString(lastAction, 0, 6) == "deposit") {
                    processDeposit(amount);
                    showDepositMenu(id);
                }
                else if (llGetSubString(lastAction, 0, 7) == "withdraw") {
                    processWithdrawal(amount);
                    showWithdrawMenu(id);
                }
                else if (llGetSubString(lastAction, 0, 15) == "transfer_cash_to") {
                    // Extract recipient ID from lastAction
                    key recipientID = (key)llGetSubString(lastAction, 17, -1);
                    processTransferFromCash(recipientID, amount);
                    showTransferMenu(id);
                }
                else if (llGetSubString(lastAction, 0, 15) == "transfer_bank_to") {
                    // Extract recipient ID from lastAction
                    key recipientID = (key)llGetSubString(lastAction, 17, -1);
                    processTransferFromBank(recipientID, amount);
                    showTransferMenu(id);
                }
            }
            else {
                llOwnerSay("Invalid amount. Please enter a positive number.");
            }
        }
    }
    
    sensor(integer num_detected) {
        // Show list of nearby people for transfers
        if (num_detected > 0) {
            string sensorType = llGetSubString(lastAction, 0, 7);
            
            list buttons = [];
            integer i;
            for (i = 0; i < num_detected && i < 9; i++) {
                if (llDetectedKey(i) != ownerID) {
                    buttons += [llDetectedName(i)];
                }
            }
            
            buttons += ["Cancel"];
            
            // Determine if this is cash or bank transfer
            string transferType;
            if (lastAction == "transfer_cash") {
                transferType = "cash";
            }
            else {
                transferType = "bank account";
            }
            
            llDialog(ownerID, "Select a recipient to transfer from your " + transferType + ":", 
                   buttons, TRANSACTION_CHANNEL);
                   
            // Set up listener for selection
            llListenRemove(listenHandle);
            listenHandle = llListen(TRANSACTION_CHANNEL, "", ownerID, "");
        }
        else {
            llOwnerSay("No one detected nearby. Please try again when someone is present.");
        }
    }
    
    no_sensor() {
        llOwnerSay("No one detected nearby. Please try again when someone is present.");
    }
    
    dataserver(key request_id, string data) {
        // Process notecard data
        if (data != EOF) {
            // Parse each line
            list dataParts = llParseString2List(data, ["="], []);
            
            if (llGetListLength(dataParts) == 2) {
                string field = llList2String(dataParts, 0);
                string value = llList2String(dataParts, 1);
                
                // Look for financial data
                if (field == "RUBLES") {
                    playerRubles = (integer)value;
                }
                else if (field == "BANK_BALANCE") {
                    bankBalance = (integer)value;
                }
                else if (field == "CLASS") {
                    playerClass = value;
                }
                else if (field == "RANK") {
                    playerRank = value;
                }
                
                // Set class-based settings
                setPlayerClass(playerClass, playerRank);
            }
            
            // Get next line
            llGetNotecardLine("character_data", llGetNotecardLine("character_data", 0) + 1);
        }
        else {
            // Finished reading notecard
            llOwnerSay("Financial data loaded successfully.");
            updateDisplay();
        }
    }
    
    changed(integer change) {
        if (change & CHANGED_INVENTORY) {
            // If notecard changed, reload
            if (llGetInventoryType("character_data") == INVENTORY_NOTECARD) {
                loadPlayerData();
            }
        }
    }
}