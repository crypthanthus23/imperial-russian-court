/**
 * Imperial Court Etiquette Module
 * 
 * Provides personalized protocol guidance for players in the Imperial Russian Court roleplay system.
 * This module helps players navigate the complex social rules and expectations of the 1905 
 * Russian Imperial Court through context-sensitive tooltips and advice.
 * 
 * Author: [Your Name] for Imperial Russian Court RP System (1905)
 * Last Updated: April 2025
 */

// System configuration
string VERSION = "1.0.0";
string AUTHENTICATION_KEY = "ImperialCourtAuth1905"; // Must match the key in core system
integer SYSTEM_CHANNEL = -89827631;
integer ETIQUETTE_CHANNEL = -98019;
integer HUD_CHANNEL = -76543219;
integer MODULE_MENU_CHANNEL;
integer CONTEXT_MENU_CHANNEL;
integer ROYALTY_MENU_CHANNEL;
integer SITUATION_MENU_CHANNEL;

// Player data
key ownerID;
string playerName = "";
string playerRank = "";
string playerTitle = "";
string playerContext = ""; // Current context for advice (greeting, conversation, dining, etc.)
string targetRoyalty = ""; // Current royal personage for advice

// Listener tracking
list activeListeners = [];

// Menus
list mainMenuItems = ["Addressing Royalty", "Court Situations", "Personal Advice", "Quick Reference", "Historical Context", "Close"];
list royaltyMenuItems = ["Tsar", "Tsarina", "Tsarevich", "Grand Duchess", "Grand Duke", "Prince/Princess", "Count/Countess", "Baron/Baroness", "Foreign Dignitary", "Back"];
list contextMenuItems = ["Greeting", "Conversation", "Dining", "Back"];
list situationMenuItems = ["Ball", "Church Service", "Military Review", "Court Procession", "Formal Dining", "Tea Ceremony", "Court Presentation", "Imperial Audience", "Back"];

// ===== UTILITY FUNCTIONS =====

// Initialize the script
initialize() {
    // Clear existing listeners
    integer i;
    for (i = 0; i < llGetListLength(activeListeners); i++) {
        llListenRemove(llList2Integer(activeListeners, i));
    }
    activeListeners = [];
    
    // Set up random channels for menus
    MODULE_MENU_CHANNEL = -(integer)("0x" + llGetSubString(llMD5String((string)llGetKey(), 0), 0, 7));
    CONTEXT_MENU_CHANNEL = MODULE_MENU_CHANNEL - 1;
    ROYALTY_MENU_CHANNEL = MODULE_MENU_CHANNEL - 2;
    SITUATION_MENU_CHANNEL = MODULE_MENU_CHANNEL - 3;
    
    // Set up listeners
    activeListeners += [llListen(MODULE_MENU_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(CONTEXT_MENU_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(ROYALTY_MENU_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(SITUATION_MENU_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(SYSTEM_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(ETIQUETTE_CHANNEL, "", NULL_KEY, "")];
    activeListeners += [llListen(HUD_CHANNEL, "", NULL_KEY, "")];
    
    // Store owner
    ownerID = llGetOwner();
    
    // Set default floating text
    llSetText("Imperial Court Etiquette Advisor\nTouch for protocol guidance", <0.8, 0.6, 0.8>, 1.0);
}

// Show the appropriate menu based on a command
showMenu(string command, key id) {
    if (command == "MAIN") {
        llDialog(id, "Welcome to the Imperial Court Etiquette Advisor.\n\nHow may I assist you with court protocol today?", mainMenuItems, MODULE_MENU_CHANNEL);
    }
    else if (command == "ROYALTY") {
        llDialog(id, "Select which royal or noble personage you wish to address:", royaltyMenuItems, ROYALTY_MENU_CHANNEL);
    }
    else if (command == "CONTEXT") {
        llDialog(id, "Select the context of your interaction with " + targetRoyalty + ":", contextMenuItems, CONTEXT_MENU_CHANNEL);
    }
    else if (command == "SITUATIONS") {
        llDialog(id, "Select a court situation or event for protocol guidance:", situationMenuItems, SITUATION_MENU_CHANNEL);
    }
}

// Process the player's rank information
processPlayerRank(string rankInfo) {
    playerRank = rankInfo;
    
    // Set appropriate title based on rank
    if (rankInfo == "Tsar" || rankInfo == "Tsarina") {
        playerTitle = "Your Imperial Majesty";
    }
    else if (rankInfo == "Tsarevich" || rankInfo == "Tsarevna" || rankInfo == "Grand Duke" || rankInfo == "Grand Duchess") {
        playerTitle = "Your Imperial Highness";
    }
    else if (rankInfo == "Prince" || rankInfo == "Princess") {
        playerTitle = "Your Serene Highness";
    }
    else if (rankInfo == "Count" || rankInfo == "Countess") {
        playerTitle = "Your Excellency";
    }
    else if (rankInfo == "Baron" || rankInfo == "Baroness") {
        playerTitle = "Your Honor";
    }
    else if (rankInfo == "General" || rankInfo == "Colonel" || rankInfo == "Captain") {
        playerTitle = "Sir";
    }
    else if (rankInfo == "Metropolitan" || rankInfo == "Archbishop" || rankInfo == "Bishop") {
        playerTitle = "Your Grace";
    }
    else if (rankInfo == "Priest") {
        playerTitle = "Father";
    }
    else {
        playerTitle = "Sir/Madam";
    }
}

// Get a proper address for a given rank
string getProperAddress(string rank) {
    if (rank == "Tsar" || rank == "Tsarina") {
        return "Your Imperial Majesty (Vashe Imperatorskoye Velichestvo)";
    }
    else if (rank == "Tsarevich" || rank == "Grand Duke" || rank == "Grand Duchess") {
        return "Your Imperial Highness (Vashe Imperatorskoye Vysochestvo)";
    }
    else if (rank == "Prince" || rank == "Princess") {
        return "Your Highness (Vashe Vysochestvo)";
    }
    else if (rank == "Count" || rank == "Countess") {
        return "Your Excellency (Vashe Siyatelstvo)";
    }
    else if (rank == "Baron" || rank == "Baroness") {
        return "Your Honor (Vashe Blagorodiye)";
    }
    else if (rank == "Foreign Dignitary") {
        return "Your Excellency (varies by country of origin)";
    }
    return "Sir/Madam";
}

// Get etiquette advice for greeting situations
string getGreetingAdvice(string rank) {
    if (rank == "Tsar") {
        return "When greeting the Tsar: Bow deeply and address as 'Your Imperial Majesty' (Vashe Imperatorskoye Velichestvo). Never speak unless spoken to first. Men should bow from the waist, women should curtsy deeply. Maintain at least 3 paces distance until invited to approach.";
    }
    else if (rank == "Tsarina") {
        return "When greeting the Tsarina: Bow/curtsy deeply and address as 'Your Imperial Majesty' (Vashe Imperatorskoye Velichestvo). Women should curtsy with the right foot behind, men bow deeply from the waist. Never turn your back to Her Imperial Majesty when departing.";
    }
    else if (rank == "Tsarevich") {
        return "When greeting the Tsarevich: Bow/curtsy and address as 'Your Imperial Highness' (Vashe Imperatorskoye Vysochestvo). As heir to the throne, the Tsarevich deserves nearly the same level of deference as the Tsar himself.";
    }
    else if (rank == "Grand Duchess") {
        return "When greeting a Grand Duchess: Bow/curtsy and address as 'Your Imperial Highness' (Vashe Imperatorskoye Vysochestvo). For the Tsar's daughters, you should be particularly respectful and formal.";
    }
    else if (rank == "Grand Duke") {
        return "When greeting a Grand Duke: Bow/curtsy and address as 'Your Imperial Highness' (Vashe Imperatorskoye Vysochestvo). Male Grand Dukes may offer their hand to shake - wait for this gesture rather than initiating.";
    }
    else if (rank == "Prince/Princess") {
        return "When greeting a Prince/Princess: Bow/curtsy and address as 'Your Highness' (Vashe Vysochestvo). Note that Russian princes (knyaz) are addressed differently from foreign princes or Imperial family princes.";
    }
    else if (rank == "Count/Countess") {
        return "When greeting a Count/Countess: A slight bow/curtsy is appropriate. Address as 'Your Excellency' (Vashe Siyatelstvo). Counts and Countesses are high nobility but do not receive the deep deference of Imperial family.";
    }
    else if (rank == "Baron/Baroness") {
        return "When greeting a Baron/Baroness: A slight nod is appropriate. Address as 'Your Honor' (Vashe Blagorodiye). While still nobility, the formality is somewhat reduced for this rank.";
    }
    else if (rank == "Foreign Dignitary") {
        return "When greeting Foreign Dignitaries: Address according to their rank in their home country. For ambassadors, 'Your Excellency' is appropriate. Pay special attention to their country's customs while balancing Russian court etiquette.";
    }
    return "Remember to greet nobles with appropriate formality according to their rank.";
}

// Get etiquette advice for conversation situations
string getConversationAdvice(string rank) {
    if (rank == "Tsar") {
        return "When conversing with the Tsar: Only speak when directly addressed. Keep answers brief and respectful. Use 'Your Imperial Majesty' at the beginning of your response and when addressing Him. Never discuss politics unless He explicitly asks for your opinion.";
    }
    else if (rank == "Tsarina") {
        return "When conversing with the Tsarina: Speak only when addressed. Topics of art, literature, and family are most appropriate. Use 'Your Imperial Majesty' frequently. Never discuss political controversies or scandals. If asked about your family, keep the response modest.";
    }
    else if (rank == "Tsarevich") {
        return "When conversing with the Tsarevich: Keep topics light and appropriate for the young heir. Military matters, sports, and education are suitable topics if he initiates them. Never mention his health condition. Address as 'Your Imperial Highness' throughout.";
    }
    else if (rank == "Grand Duchess") {
        return "When conversing with a Grand Duchess: Acceptable topics include art, literature, charity work, and court events. Avoid political matters unless she specifically inquires. Address as 'Your Imperial Highness' throughout. The older daughters may engage on more serious topics.";
    }
    else if (rank == "Grand Duke") {
        return "When conversing with a Grand Duke: Military matters, hunting, and foreign travels are typically welcome topics. Some Grand Dukes have specific interests or military positions - researching these beforehand is advisable. Address as 'Your Imperial Highness' throughout.";
    }
    else if (rank == "Prince/Princess") {
        return "When conversing with a Prince/Princess: Address as 'Your Highness' periodically throughout conversation. Permissible topics are broader, including society events, common acquaintances, and cultural matters.";
    }
    else if (rank == "Count/Countess") {
        return "When conversing with a Count/Countess: Address as 'Your Excellency' at the start of the conversation and periodically. Conversation can flow more naturally with less restriction on topics, though political controversies should still be approached cautiously.";
    }
    else if (rank == "Baron/Baroness") {
        return "When conversing with a Baron/Baroness: Address as 'Your Honor' initially, then conversation can proceed more casually. Discussions about society, business, and non-controversial current events are acceptable.";
    }
    else if (rank == "Foreign Dignitary") {
        return "When conversing with Foreign Dignitaries: Show interest in their home country without making unfavorable comparisons. Address according to their rank. Be aware that diplomatic representatives may be gathering information, so discretion about Russian affairs is wise.";
    }
    return "Maintain appropriate conversational topics according to the rank of the person you're addressing. When in doubt, let them lead the conversation.";
}

// Get etiquette advice for dining situations
string getDiningAdvice(string rank) {
    if (rank == "Tsar") {
        return "When dining with the Tsar present: Never begin eating before the Tsar. If He addresses you during dinner, immediately stop eating to respond. Never leave the table before the Imperial family, regardless of the hour. Wine should be consumed moderately. Use 'Your Imperial Majesty' if addressing Him directly.";
    }
    else if (rank == "Tsarina") {
        return "When dining with the Tsarina present: Women should be particularly attentive to the Tsarina's cues. No one should eat before she begins. If she engages you in conversation, set down utensils completely. When she finishes a course, servers will begin removing plates whether you are finished or not.";
    }
    else if (rank == "Tsarevich") {
        return "When dining with the Tsarevich present: The young heir is treated with deference similar to his father, though the atmosphere may be somewhat less formal depending on the occasion. Adults should engage him respectfully if he initiates conversation.";
    }
    else if (rank == "Grand Duchess") {
        return "When dining with Grand Duchesses present: The formal Russian service à la russe will be observed. If seated near a Grand Duchess, assist with her chair if appropriate. Conversation should be polite and not overly familiar. Use 'Your Imperial Highness' when addressing her.";
    }
    else if (rank == "Grand Duke") {
        return "When dining with Grand Dukes present: Service follows formal Russian style with multiple courses. Toast protocols are important - never toast before a senior Grand Duke unless explicitly invited to do so. Military officers may discuss appropriate military matters if the Grand Duke has a military position.";
    }
    else if (rank == "Prince/Princess") {
        return "When dining with a Prince/Princess: Formal dining etiquette applies, though atmosphere may be somewhat relaxed compared to Imperial family meals. Toast protocols remain important - observe the hierarchy of who toasts first.";
    }
    else if (rank == "Count/Countess") {
        return "When dining with a Count/Countess: Russian aristocratic dining customs apply. Wait for host/hostess to begin. Fork and knife remain in hand while eating (Continental style). Multiple glasses for different beverages will be arranged in order of use from right to left.";
    }
    else if (rank == "Baron/Baroness") {
        return "When dining with a Baron/Baroness: While still formal, these dinners may be somewhat more relaxed. Toasts may be more frequent and conversation more varied. European dining customs are followed scrupulously.";
    }
    else if (rank == "Foreign Dignitary") {
        return "When dining with Foreign Dignitaries: Russian hosts will typically incorporate elements of the visitor's national cuisine as a courtesy. Be prepared for both Russian and international dining customs. Diplomatic dinners have strict protocols for toast order and conversation.";
    }
    return "Imperial Russian dining follows elaborate formal protocols. Multiple courses are served à la russe (dishes presented sequentially). Observe and follow the lead of higher-ranking nobles.";
}

// Generate personalized etiquette advice based on player rank
string getPersonalEtiquetteAdvice(string playerRank) {
    string advice = "";
    
    // Introduction based on rank
    advice += "Personalized Etiquette Guidance for " + playerName + "\n\n";
    
    // Add rank-specific advice
    if (playerRank == "Tsar" || playerRank == "Tsarina") {
        advice += "As " + playerRank + ", you are the center of court life. All eyes are upon you at all times. Your highest etiquette duty is to maintain the dignity of the Imperial Crown through perfect deportment.\n\n";
        advice += "- Your words carry immense weight – speak deliberately\n";
        advice += "- Your timing sets the schedule for all court functions\n";
        advice += "- You need not bow to anyone except religious icons\n";
        advice += "- When you rise, all must rise; when you sit, all may sit\n";
    }
    else if (playerRank == "Tsarevich" || playerRank == "Grand Duke" || playerRank == "Grand Duchess") {
        advice += "As an Imperial Highness, you stand at the apex of Russian society, second only to the Tsar and Tsarina themselves.\n\n";
        advice += "- Others must address you as 'Your Imperial Highness'\n";
        advice += "- You bow/curtsy only to the Tsar and Tsarina\n";
        advice += "- You may initiate conversation with anyone at court\n";
        advice += "- At formal functions, you enter immediately after the Imperial couple\n";
    }
    else if (playerRank == "Prince" || playerRank == "Princess") {
        advice += "As a Prince/Princess, you hold an esteemed position in the aristocratic hierarchy of the Russian Empire.\n\n";
        advice += "- You are addressed as 'Your Highness' or 'Your Serene Highness'\n";
        advice += "- You bow/curtsy to Imperial family members\n";
        advice += "- You may be seated in the presence of Imperial family after they sit\n";
        advice += "- You have precedence over lower nobility at all court functions\n";
    }
    else if (playerRank == "Count" || playerRank == "Countess") {
        advice += "As a Count/Countess, you are among the highest ranks of the hereditary nobility outside the Imperial family.\n\n";
        advice += "- You are addressed as 'Your Excellency'\n";
        advice += "- You must bow/curtsy to all Imperial family and higher-ranking nobles\n";
        advice += "- You may host significant social functions but must invite higher ranks first\n";
        advice += "- In processions, you take precedence after princes/princesses\n";
    }
    else if (playerRank == "Baron" || playerRank == "Baroness") {
        advice += "As a Baron/Baroness, you hold a respectable position within the noble hierarchy.\n\n";
        advice += "- You are addressed as 'Your Honor'\n";
        advice += "- At court functions, you are announced after counts/countesses\n";
        advice += "- You must show appropriate deference to all higher ranks\n";
        advice += "- You may be required to wait in antechambers before Imperial audiences\n";
    }
    else if (playerRank == "General" || playerRank == "Colonel" || playerRank == "Captain") {
        advice += "As a military officer of rank " + playerRank + ", you represent the might of the Imperial Russian military.\n\n";
        advice += "- You must salute superior officers and Imperial family members\n";
        advice += "- Your uniform must be impeccable at all court functions\n";
        advice += "- You stand at attention when addressed by the Tsar or higher-ranking officers\n";
        advice += "- Your precedence at court depends on both your military rank and any noble titles\n";
    }
    else if (playerRank == "Metropolitan" || playerRank == "Archbishop" || playerRank == "Bishop") {
        advice += "As a high-ranking Orthodox clergyman, you represent the spiritual authority of the Church.\n\n";
        advice += "- Even the Tsar shows deference to your religious office\n";
        advice += "- You bless rather than bow in many circumstances\n";
        advice += "- You are addressed as 'Your Grace' or 'Your Eminence'\n";
        advice += "- At state functions with religious elements, you have a prominent role\n";
    }
    else {
        advice += "As a " + playerRank + " in Imperial Russia, proper etiquette is essential for navigating court society.\n\n";
        advice += "- Always address nobles by their proper titles\n";
        advice += "- Bow or curtsy appropriately based on the rank of those you encounter\n";
        advice += "- Speak only when addressed by those of significantly higher rank\n";
        advice += "- Dress according to your station and the formality of the occasion\n";
    }
    
    // Add general court etiquette advice for everyone
    advice += "\nGeneral Court Protocol:\n";
    advice += "- Never turn your back to the Imperial family\n";
    advice += "- Arrive before, never after, those of higher rank\n";
    advice += "- Observe the proper order of precedence in all processions\n";
    advice += "- Request permission before leaving any Imperial presence\n";
    
    return advice;
}

// Get situation-specific etiquette advice
string getSituationAdvice(string situation) {
    if (situation == "Ball") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓑𝓪𝓵𝓵 𝓔𝓽𝓲𝓺𝓾𝓮𝓽𝓽𝓮\n\nNever refuse a dance with a member of the Imperial family. Dance cards should be prepared in advance. The order of dances is predetermined: polonaise, waltz, quadrille, mazurka. Ladies must wear long white gloves. Gentlemen must wear appropriate uniform or formal attire with decorations. The Tsar and Tsarina open the ball with the polonaise, followed by specific pairs according to rank.";
    }
    else if (situation == "Church Service") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓡𝓮𝓵𝓲𝓰𝓲𝓸𝓾𝓼 𝓞𝓫𝓼𝓮𝓻𝓿𝓪𝓷𝓬𝓮\n\nDuring Orthodox services, worshippers stand rather than sit. The Imperial family occupies designated positions. Never stand ahead of the Imperial family. Cross yourself with three fingers of the right hand, right to left (Eastern Orthodox style). Women must cover their heads with veils or scarves. Non-Orthodox observers may attend but should remain respectful and follow the movements of those around them. Services may last several hours.";
    }
    else if (situation == "Military Review") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓜𝓲𝓵𝓲𝓽𝓪𝓻𝔂 𝓡𝓮𝓿𝓲𝓮𝔀 𝓟𝓻𝓸𝓽𝓸𝓬𝓸𝓵\n\nWhen the Tsar enters, all officers salute and troops present arms. Military personnel remain at attention until ordered otherwise. The Tsar inspects troops as Supreme Commander. Civilians should stand respectfully throughout. After the review, the Tsar may address officers or distribute honors. Ladies may present regimental colors on special occasions. Regimental bands play specific marches according to tradition.";
    }
    else if (situation == "Court Procession") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓟𝓻𝓸𝓬𝓮𝓼𝓼𝓲𝓸𝓷𝓪𝓵\n\nCourt processions follow strict order of precedence. The Tsar and Tsarina lead, followed by the Tsarevich, Grand Duchesses by age, Grand Dukes by proximity to throne, and then nobles by rank. Spectators should bow or curtsy as the Imperial family passes. Never cross the processional route. Masters of Ceremony with staffs coordinate the movement. Special costumes and regalia are worn according to the occasion (court dress, parade uniforms, etc.).";
    }
    else if (situation == "Formal Dining") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓕𝓸𝓻𝓶𝓪𝓵 𝓓𝓲𝓷𝓲𝓷𝓰\n\nFormal Imperial dinners follow service à la russe - courses served sequentially. Up to 12 courses may be presented. Each diner has a footman assigned. Plates are removed even if not finished when the Imperial family completes a course. The Tsar or highest-ranking person proposes the first toast. Wine glasses are refilled before each toast. Conversation is conducted primarily with those seated immediately adjacent. Salt is transferred to your plate with a small spoon, never touched directly.";
    }
    else if (situation == "Tea Ceremony") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓣𝓮𝓪 𝓒𝓮𝓻𝓮𝓶𝓸𝓷𝔂\n\nRussian tea (chai) is served in glass cups with silver holders (podstakanniki) for men and porcelain cups for ladies. Tea is traditionally served with lemon, never milk. Nobles may be invited to the Tsarina's private tea gatherings - a significant honor. Tea is poured from a samovar, with jam occasionally served as a sweet to be dissolved in the tea or eaten separately. When finished, place your spoon across the saucer rather than in the cup.";
    }
    else if (situation == "Court Presentation") {
        return "𝓒𝓸𝓾𝓻𝓽 𝓟𝓻𝓮𝓼𝓮𝓷𝓽𝓪𝓽𝓲𝓸𝓷 𝓒𝓮𝓻𝓮𝓶𝓸𝓷𝔂\n\nFormal presentation at court requires invitation and sponsorship. Ladies must wear the Russian court dress with the distinctive kokoshnik headdress and long train. Men wear appropriate court uniform or diplomatic dress. When presented, approach with three distinct bows/curtsies. Speak only if addressed directly. Back away from Imperial presence without turning your back. Ladies may be invited to kiss the Tsarina's hand - this is done without actually touching lips to hand.";
    }
    else if (situation == "Imperial Audience") {
        return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓐𝓾𝓭𝓲𝓮𝓷𝓬𝓮 𝓟𝓻𝓸𝓽𝓸𝓬𝓸𝓵\n\nPrivate audiences with the Tsar are conducted in the appropriate state room. Enter only when announced, bow immediately upon entering. Remain standing unless explicitly invited to sit. Address the Tsar as 'Your Imperial Majesty' at first address and periodically throughout. Present any documents by holding with both hands. Never take seat before the Tsar, and rise immediately if He stands. The audience concludes when the Tsar indicates, never before.";
    }
    return "Court situations have specific protocols that must be observed according to tradition and hierarchy.";
}

// Get personalized role-based advice for the player
string getPersonalAdvice() {
    // Process based on rank
    if (playerRank == "Tsar" || playerRank == "Tsarina") {
        return "As the Tsar/Tsarina, you set the standard for court etiquette. Your preferences become protocol. Remember that your subjects will follow your lead in all matters of etiquette. When you rise from the table, all dining ceases. When you exit a room, all must bow/curtsy. Be mindful of the immense ceremonial power you wield through even the smallest gestures.";
    }
    else if (playerRank == "Tsarevich" || playerRank == "Grand Duke" || playerRank == "Grand Duchess") {
        return "As a member of the Imperial family, your behavior reflects directly on the Tsar. You must exemplify perfect Russian court etiquette at all times. Remember that you are constantly observed, and deviations from protocol are noted. Maintain appropriate distance from lesser nobles while showing perfect courtesy. You may initiate conversation with those of lower rank, but they should not approach you first.";
    }
    else if (playerRank == "Prince" || playerRank == "Princess" || playerRank == "Count" || playerRank == "Countess") {
        return "As high nobility, you should be thoroughly versed in court etiquette and help guide lesser nobles. Be especially attentive to Imperial family protocols. Know the appropriate forms of address for every rank. Remember that your status requires exemplary manners, but you must always defer to the Imperial family. Never show familiarity with Imperial family members in public, even if you enjoy personal friendship.";
    }
    else if (playerRank == "Baron" || playerRank == "Baroness") {
        return "As titled nobility, you occupy a middle position at court. You should be thoroughly familiar with all protocols while recognizing the significant gap between yourself and higher nobles. Pay special attention to precedence in processions and seating. Never initiate conversation with anyone of significantly higher rank unless clearly invited to do so. Focus on cultivating relationships with peers and slightly higher ranks.";
    }
    else if (playerRank == "General" || playerRank == "Colonel" || playerRank == "Captain") {
        return "As a military officer at court, you must balance military bearing with court etiquette. Always appear in proper uniform with decorations correctly placed. Show special deference to the Tsar as Commander-in-Chief. Stand at attention when Imperial family members enter unless directed otherwise. Military bearing is expected - maintain excellent posture and discipline. When addressed on military matters, respond concisely and professionally.";
    }
    else if (playerRank == "Metropolitan" || playerRank == "Archbishop" || playerRank == "Bishop" || playerRank == "Priest") {
        return "As clergy at court, you occupy a unique position. Your religious authority is respected while still observing Imperial protocols. The Imperial family will kiss your hand and receive blessing in religious contexts, but in court settings, you must show appropriate deference to them. Wear appropriate ecclesiastical dress for all court functions. You may be called upon to offer prayers or blessings at state occasions.";
    }
    else if (playerRank == "Merchant" || playerRank == "Doctor" || playerRank == "Artisan") {
        return "As a non-noble at court, you must be especially careful to observe all protocols. Study the precedence and forms of address thoroughly. Speak only when addressed directly by nobles. Dress conservatively but well within your station. Show deeper bows and longer curtsies than nobles would. If you have been invited to court, it is a significant honor - be especially attentive to the behavior of those around you.";
    }
    return "Regardless of rank, always observe proper courtly etiquette. Watch higher-ranking individuals for cues on proper behavior.";
}

// Get quick reference etiquette rules
string getQuickReference() {
    return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓔𝓽𝓲𝓺𝓾𝓮𝓽𝓽𝓮 - 𝓠𝓾𝓲𝓬𝓴 𝓡𝓮𝓯𝓮𝓻𝓮𝓷𝓬𝓮\n\n1. Never turn your back to the Imperial family\n2. Use proper forms of address at all times\n3. Bow/curtsy when Imperial family members enter or exit\n4. Never sit in the presence of standing Imperial family\n5. Observe the order of precedence in all processions\n6. Never initiate physical contact with Imperial family\n7. Begin no action (dining, dancing, etc.) before the Imperial family\n8. Women must curtsy, men must bow - depth varies by rank\n9. Request permission to be excused from Imperial presence\n10. Wear appropriate attire for every court function";
}

// Get historical context for court etiquette
string getHistoricalContext() {
    return "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓗𝓲𝓼𝓽𝓸𝓻𝓲𝓬𝓪𝓵 𝓒𝓸𝓷𝓽𝓮𝔁𝓽 (𝟭𝟵𝟬𝟱)\n\nRussian court etiquette in 1905 represents a blend of traditional Muscovite practices and European influences introduced since Peter the Great. Nicholas II's court maintained elaborate ceremonial despite his personal preference for simplicity. Court etiquette was strictly observed at official functions while family life at Tsarskoye Selo was relatively informal. The Empress Alexandra, of German origin, found Russian court etiquette challenging and introduced some changes. The Dowager Empress Maria Feodorovna remained an influential guardian of traditional protocols. Revolutionary tensions outside the court made adherence to tradition even more important as a symbol of stability.";
}

// Show personalized etiquette advice to the player
showEtiquetteAdvice(string adviceType, key id) {
    // Default header and advice text
    string headerText = "𝓘𝓶𝓹𝓮𝓻𝓲𝓪𝓵 𝓒𝓸𝓾𝓻𝓽 𝓔𝓽𝓲𝓺𝓾𝓮𝓽𝓽𝓮";
    string adviceText = "";
    string footerText = "";
    
    // Set the appropriate advice based on type
    if (adviceType == "GREETING") {
        adviceText = getGreetingAdvice(targetRoyalty);
        footerText = "\nProper Address: " + getProperAddress(targetRoyalty);
    }
    else if (adviceType == "CONVERSATION") {
        adviceText = getConversationAdvice(targetRoyalty);
        footerText = "\nProper Address: " + getProperAddress(targetRoyalty);
    }
    else if (adviceType == "DINING") {
        adviceText = getDiningAdvice(targetRoyalty);
    }
    else if (adviceType == "SITUATION") {
        adviceText = getSituationAdvice(playerContext);
        headerText = ""; // Situation advice includes its own header
    }
    else if (adviceType == "PERSONAL") {
        headerText = "𝓟𝓮𝓻𝓼𝓸𝓷𝓪𝓵𝓲𝔃𝓮𝓭 𝓔𝓽𝓲𝓺𝓾𝓮𝓽𝓽𝓮 𝓐𝓭𝓿𝓲𝓬𝓮";
        adviceText = getPersonalAdvice();
    }
    else if (adviceType == "REFERENCE") {
        adviceText = getQuickReference();
        headerText = ""; // Reference includes its own header
    }
    else if (adviceType == "HISTORICAL") {
        adviceText = getHistoricalContext();
        headerText = ""; // Historical context includes its own header
    }
    
    // Combine all parts
    string messageText = "";
    if (headerText != "") {
        messageText += headerText + "\n\n";
    }
    messageText += adviceText;
    if (footerText != "") {
        messageText += footerText;
    }
    
    // Display the advice
    llDialog(id, messageText, ["Return to Main Menu", "Close"], MODULE_MENU_CHANNEL);
}

// Query the player's rank from the HUD system
queryPlayerRank(key id) {
    llRegionSay(SYSTEM_CHANNEL, "QUERY_PLAYER_RANK|" + AUTHENTICATION_KEY + "|" + (string)id);
}

// ===== MAIN SCRIPT =====

default {
    state_entry() {
        initialize();
        llOwnerSay("Imperial Court Etiquette Module initialized.\nVersion " + VERSION);
    }
    
    touch_start(integer total_number) {
        key id = llDetectedKey(0);
        
        // Query the player's rank for personalized advice
        queryPlayerRank(id);
        
        // Show the main menu (rank will be used when available)
        showMenu("MAIN", id);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Process system channel messages (from HUD system)
        if (channel == SYSTEM_CHANNEL) {
            list msgParts = llParseString2List(message, ["|"], []);
            string command = llList2String(msgParts, 0);
            string authKey = llList2String(msgParts, 1);
            
            if (authKey == AUTHENTICATION_KEY) {
                if (command == "QUERY_PLAYER_RANK_RESPONSE") {
                    key playerID = (key)llList2String(msgParts, 2);
                    string rankInfo = llList2String(msgParts, 3);
                    
                    // Process the player's rank information
                    processPlayerRank(rankInfo);
                    
                    // Store player name
                    playerName = llKey2Name(playerID);
                    
                    // Debug message
                    //llOwnerSay("Player " + playerName + " has rank: " + rankInfo);
                }
                else if (command == "HUD_ETIQUETTE_REQUEST") {
                    key playerID = (key)llList2String(msgParts, 2);
                    
                    // Generate appropriate etiquette advice based on player rank
                    string personalAdvice = getPersonalEtiquetteAdvice(playerRank);
                    
                    // Send response back to the HUD
                    llRegionSay(SYSTEM_CHANNEL, "ETIQUETTE_REQUEST_RESPONSE|" + AUTHENTICATION_KEY + "|" + 
                               (string)playerID + "|" + personalAdvice);
                    
                    // Also display the main etiquette menu for this player
                    showMenu("MAIN", playerID);
                }
            }
            
            return;
        }
        
        // Process module menu channel
        if (channel == MODULE_MENU_CHANNEL) {
            if (message == "Addressing Royalty") {
                targetRoyalty = ""; // Clear previous selection
                showMenu("ROYALTY", id);
            }
            else if (message == "Court Situations") {
                showMenu("SITUATIONS", id);
            }
            else if (message == "Personal Advice") {
                showEtiquetteAdvice("PERSONAL", id);
            }
            else if (message == "Quick Reference") {
                showEtiquetteAdvice("REFERENCE", id);
            }
            else if (message == "Historical Context") {
                showEtiquetteAdvice("HISTORICAL", id);
            }
            else if (message == "Return to Main Menu") {
                showMenu("MAIN", id);
            }
            else if (message == "Close") {
                llOwnerSay("Thank you for consulting the Imperial Court Etiquette Advisor.");
            }
        }
        // Process royalty menu channel
        else if (channel == ROYALTY_MENU_CHANNEL) {
            if (message == "Back") {
                showMenu("MAIN", id);
            }
            else {
                // Store the selected royalty and show context menu
                targetRoyalty = message;
                showMenu("CONTEXT", id);
            }
        }
        // Process context menu channel
        else if (channel == CONTEXT_MENU_CHANNEL) {
            if (message == "Back") {
                showMenu("ROYALTY", id);
            }
            else {
                // Store the selected context and show etiquette advice
                playerContext = message;
                
                if (message == "Greeting") {
                    showEtiquetteAdvice("GREETING", id);
                }
                else if (message == "Conversation") {
                    showEtiquetteAdvice("CONVERSATION", id);
                }
                else if (message == "Dining") {
                    showEtiquetteAdvice("DINING", id);
                }
            }
        }
        // Process situation menu channel
        else if (channel == SITUATION_MENU_CHANNEL) {
            if (message == "Back") {
                showMenu("MAIN", id);
            }
            else {
                // Store the selected situation and show etiquette advice
                playerContext = message;
                showEtiquetteAdvice("SITUATION", id);
            }
        }
    }
}